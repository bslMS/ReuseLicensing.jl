# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# Return the token at current position or `nothing`.
peek(ts::SPDXTokenStream) = ts.pos <= length(ts.tokens) ? ts.tokens[ts.pos] : nothing

# Return whether the token stream cursor has reached the end.
isdone(ts::SPDXTokenStream) = ts.pos > length(ts.tokens)

# Return the token at the current position or `nothing`, then advance the cursor.
function consume!(ts::SPDXTokenStream)
    tok = peek(ts)
    tok === nothing && return nothing
    ts.pos += 1
    return tok
end

# Return the token at the current position if it matches `kind`, then advance the cursor.
function expect!(ts::SPDXTokenStream, kind::Symbol)
    tok = consume!(ts)
    tok === nothing && throw(ArgumentError("Unexpected end of SPDX expression."))
    tok.kind === kind && return tok
    throw(ArgumentError("Expected token $kind, got $(tok.kind)."))
end

# Return a vector of tokens and catch invalid operator spellings early.
function tokenize_spdx(expr::AbstractString)
    tokens = SPDXToken[]
    i = firstindex(expr)
    last = lastindex(expr)

    while i <= last
        c = expr[i]

        if isspace(c)
            i = nextind(expr, i)
        elseif c == '('
            push!(tokens, SPDXToken(:LPAREN, "("))
            i = nextind(expr, i)
        elseif c == ')'
            push!(tokens, SPDXToken(:RPAREN, ")"))
            i = nextind(expr, i)
        else
            j = i
            while j <= last
                cj = expr[j]
                if isspace(cj) || cj == '(' || cj == ')'
                    break
                end
                j = nextind(expr, j)
            end

            word = String(expr[i:prevind(expr, j)])
            # SPDX operators are accepted only as all-uppercase or all-lowercase.
            kind = if word == "AND" || word == "and"
                :AND
            elseif word == "OR" || word == "or"
                :OR
            elseif word == "WITH" || word == "with"
                :WITH
            elseif ncodeunits(word) in (2, 3, 4) &&
                   lowercase(word) in ("or", "and", "with")
                throw(
                    ArgumentError(
                    "SPDX operators must be all-uppercase or all-lowercase, got '$word'",
                ),
                )
            else
                :ATOM
            end
            push!(tokens, SPDXToken(kind, word))
            i = j
        end
    end
    return tokens
end

# Construct SPDXTokenStream from SPDX expression.
SPDXTokenStream(expr::AbstractString) = SPDXTokenStream(tokenize_spdx(expr))
