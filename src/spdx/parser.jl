# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

function parse_license_ref_identifier(identifier::AbstractString)
    n = ncodeunits(identifier)
    if n > 11
        @inbounds for i in 12:n
            b = codeunit(identifier, i)
            if !(
                b == UInt8('-') ||
                b == UInt8('.') ||
                (UInt8('0') <= b <= UInt8('9')) ||
                (UInt8('A') <= b <= UInt8('Z')) ||
                (UInt8('a') <= b <= UInt8('z'))
            )
                throw(
                    ArgumentError(
                    "Identifier `$identifier` contains illegal character `$(repr(Char(b)))`."
                )
                )
            end
        end
        return SPDXLicenseRef(String(identifier[nextind(identifier, 11):end]))
    else
        throw(ArgumentError("`LicenseRef-` must be followed by an identifier."))
    end
end

# Parse and normalize one SPDX license identifier token into an AST atom.
function parse_license_token(token::SPDXToken; legacy)
    token.kind === :ATOM || throw(ArgumentError(
        "Expected SPDX license identifier, got $(token.text)."
    ))
    identifier = token.text
    if startswith(identifier, "LicenseRef-")
        return parse_license_ref_identifier(identifier)
    else
        return normalize_spdx_license_identifier(identifier; legacy)
    end
end

function parse_exception_token(token::SPDXToken)
    token.kind === :ATOM || throw(ArgumentError(
        "Expected SPDX license exception identifier, got $(token.text)."
    ))
    identifier = lowercase(token.text)
    if is_spdx_license_exception_id(identifier)
        canonical = canonical_spdx_license_exception_id(identifier)
        return SPDXLicenseExceptionId(canonical)
    elseif is_deprecated_spdx_license_exception_id(identifier)
        canonical = canonical_spdx_license_exception_id(identifier)
        throw(ArgumentError("License exception `$canonical` is deprecated."))
    else
        throw(ArgumentError("Unknown SPDX license exception identifier: `$token`."))
    end# implement analogously here
end

# Parse a primary SPDX expression:
# either a standalone SPDX atom or a parenthesized full expression.
# Standalone license exceptions are rejected here.
function parse_primary(ts::SPDXTokenStream; legacy)
    tok = peek(ts)
    tok === nothing && throw(ArgumentError("Unexpected end of SPDX expression."))

    if tok.kind === :ATOM
        consume!(ts)
        return parse_license_token(tok; legacy)
    elseif tok.kind === :LPAREN
        consume!(ts)
        expr = parse_expression(ts; legacy)
        expect!(ts, :RPAREN)
        return expr
    else
        throw(
            ArgumentError(
            "Expected SPDX license expression or `(`, got `$(tok.text)`.",
        )
        )
    end
end

# Parse a simple SPDX license expression from a single atomic token.
# Only SPDX license identifiers and `LicenseRef-...` are accepted here;
# license exceptions are rejected.
function parse_simple_expression(ts::SPDXTokenStream; legacy)
    tok = peek(ts)
    tok === nothing && throw(ArgumentError("Unexpected end of SPDX expression."))
    tok.kind === :ATOM || throw(
        ArgumentError("Expected simple SPDX license expression, got `$(tok.text)`.")
    )

    consume!(ts)
    return parse_license_token(tok; legacy)
end

# Parse an expression that may serve as an operand of `AND` or `OR`.
# This accepts either a parenthesized full SPDX expression or a `with`-level
# expression, thereby allowing parentheses without permitting composite
# expressions on the left-hand side of `WITH`.
function parse_with_or_primary_expression(ts::SPDXTokenStream; legacy)
    tok = peek(ts)
    tok === nothing && throw(ArgumentError("Unexpected end of SPDX expression."))

    if tok.kind === :LPAREN
        expr = parse_primary(ts; legacy)
        next_tok = peek(ts)
        next_tok !== nothing && next_tok.kind === :WITH &&
            throw(
                ArgumentError(
                "`WITH` must follow a simple SPDX license expression, not a " *
                "parenthesized or composite expression."
            ),
            )
        return expr
    else
        return parse_with_expression(ts; legacy)
    end
end

# Parse a `with`-level SPDX expression.
# This consumes a simple SPDX license expression and, if followed by
# `WITH`/`with`, requires a license exception identifier on the right.
function parse_with_expression(ts::SPDXTokenStream; legacy)
    left = parse_simple_expression(ts; legacy)

    tok = peek(ts)
    if tok !== nothing && tok.kind === :WITH
        consume!(ts)

        rhs_tok = peek(ts)
        rhs_tok === nothing && throw(
            ArgumentError("Expected SPDX license exception after `WITH`."),
        )
        rhs_tok.kind === :ATOM || throw(
            ArgumentError(
            "Expected SPDX license exception after `WITH`, got `$(rhs_tok.text)`."
        ),
        )

        consume!(ts)
        exception = parse_exception_token(rhs_tok)
        return SPDXWithExceptionExpression(left, exception)
    end
    return left
end

# Parse a conjunctive SPDX expression by combining `with`-level expressions
# joined by `AND`/`and`. This precedence level binds more weakly than `WITH`
# and more strongly than `OR`.
function parse_and_expression(ts::SPDXTokenStream; legacy)
    left = parse_with_or_primary_expression(ts; legacy)

    while (tok = peek(ts)) !== nothing && tok.kind === :AND
        consume!(ts)
        right = parse_with_or_primary_expression(ts; legacy)
        left = SPDXConjunctiveExpression(left, right)
    end
    return left
end

# Parse a disjunctive SPDX expression by combining `and`-level expressions
# joined by `OR`/`or`. This is the lowest-precedence binary operator level.
function parse_or_expression(ts::SPDXTokenStream; legacy)
    left = parse_and_expression(ts; legacy)

    while (tok = peek(ts)) !== nothing && tok.kind === :OR
        consume!(ts)
        right = parse_and_expression(ts; legacy)
        left = SPDXDisjunctiveExpression(left, right)
    end
    return left
end

# Parse an SPDX license expression from the current token position.
# This is the internal recursive-descent parser entry point and delegates
# to the lowest-precedence level (`parse_or_expression`).
function parse_expression(ts::SPDXTokenStream; legacy)
    return parse_or_expression(ts; legacy)
end

# Parse a complete SPDX license expression from a string.
# This tokenizes the input, parses it into an AST, and rejects trailing tokens.
function parse_spdx_ast(expr::AbstractString; legacy)
    ts = SPDXTokenStream(tokenize_spdx(expr))
    parsed = parse_expression(ts; legacy)

    tok = peek(ts)
    tok === nothing || throw(
        ArgumentError("Unexpected trailing token `$(tok.text)` in SPDX expression."),
    )
    return parsed
end

"""
    parse_spdx_expression(expr::AbstractString; legacy = :normalize) -> ParsedSPDXExpression

Parse `expr` as an [SPDX license expression](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/)
and return a [`ParsedSPDXExpression`](@ref) containing the parsed AST,
its normalized SPDX string form, and sets of the referenced license, exception, and
`LicenseRef` identifiers.

The `legacy` keyword controls handling of deprecated SPDX license identifiers that
have current replacements. Use `legacy = :normalize` to normalize legacy
identifiers to their current SPDX form, or `legacy = :error` to reject them.

Throws `ArgumentError` if `expr` is not a valid SPDX license expression.
"""
function parse_spdx_expression(expr::AbstractString; legacy = :normalize)
    return ParsedSPDXExpression(parse_spdx_ast(expr; legacy))
end
