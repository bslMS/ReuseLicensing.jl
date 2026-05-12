# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# SPDX License List metadata.

# Metadata for a current SPDX license identifier.
struct SPDXLicenseInfo
    id::String
    is_osi_approved::Bool
    is_fsf_libre::Bool
end

# SPDX Tokens and TokenStream for the tokenizer.

struct SPDXToken
    kind::Symbol
    text::String
end

mutable struct SPDXTokenStream
    tokens::Vector{SPDXToken}
    pos::Int
end

SPDXTokenStream(tokens::Vector{SPDXToken}) = SPDXTokenStream(tokens, 1)

# SPDX Abstract Syntax Tree for parsing expressions.

abstract type AbstractSPDXLicenseExpression end
abstract type AbstractSPDXSimpleLicenseExpression <: AbstractSPDXLicenseExpression end
abstract type AbstractSPDXCompositeLicenseExpression <: AbstractSPDXLicenseExpression end

struct SPDXLicenseRef <: AbstractSPDXSimpleLicenseExpression
    identifier::String
end

# Stores a canonical SPDX license identifier; a trailing `+` is preserved when used.
struct SPDXLicenseId <: AbstractSPDXSimpleLicenseExpression
    identifier::String
end

struct SPDXLicenseExceptionId
    identifier::String
end

struct SPDXWithExceptionExpression{
    L <: AbstractSPDXSimpleLicenseExpression
} <: AbstractSPDXCompositeLicenseExpression
    license::L
    exception::SPDXLicenseExceptionId
end

struct SPDXDisjunctiveExpression{
    L <: AbstractSPDXLicenseExpression,
    R <: AbstractSPDXLicenseExpression
} <: AbstractSPDXCompositeLicenseExpression
    left::L
    right::R
end

struct SPDXConjunctiveExpression{
    L <: AbstractSPDXLicenseExpression,
    R <: AbstractSPDXLicenseExpression
} <: AbstractSPDXCompositeLicenseExpression
    left::L
    right::R
end

"""
    ParsedSPDXExpression{T<:AbstractSPDXLicenseExpression}

Result of [`parse_spdx_expression`](@ref).

Fields:
- `ast::T`: The parsed SPDX abstract syntax tree.
- `expression::String`: The normalized SPDX expression string reconstructed from `ast`.
- `licenses::Set{String}`: Set of referenced SPDX license identifiers used for license-text lookup.
- `exceptions::Set{String}`: Set of referenced SPDX license exception identifiers.
- `licenserefs::Set{String}`: Set of lowercase `LicenseRef` identifiers used for lookup.
"""
struct ParsedSPDXExpression{T <: AbstractSPDXLicenseExpression}
    ast::T
    expression::String
    licenses::Set{String}
    exceptions::Set{String}
    licenserefs::Set{String} # lowercase identifier payloads for lookup
end

# Construct the public parsed-expression wrapper and derive cached identifier sets.
function ParsedSPDXExpression(ast::T) where {T <: AbstractSPDXLicenseExpression}
    expression, licenses, exceptions, licenserefs = render_and_collect_spdx(ast)
    return ParsedSPDXExpression{T}(ast, expression, licenses, exceptions, licenserefs)
end
