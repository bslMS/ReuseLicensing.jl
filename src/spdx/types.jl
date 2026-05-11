# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# SPDX License List metadata.

"""
    SPDXLicenseInfo

Metadata for a current SPDX license identifier.

# Fields

- `id::String`: canonical SPDX license identifier spelling.
- `is_osi_approved::Bool`: whether SPDX marks the license as OSI approved.
- `is_fsf_libre::Bool`: whether SPDX marks the license as FSF libre.
"""
struct SPDXLicenseInfo
    id::String
    is_osi_approved::Bool
    is_fsf_libre::Bool
end

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

# SPDX Tokens and TokenStream for the tokenizer.

struct SPDXToken
    kind::Symbol
    text::String
end

mutable struct SPDXTokenStream
    tokens::Vector{SPDXToken}
    pos::Int
end
