# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

abstract type AbstractExpressionApprovalPolicy end

"""
    OSIApproved()

Approval policy that accepts SPDX license identifiers marked as OSI approved in
the checked-in SPDX snapshot.
"""
struct OSIApproved <: AbstractExpressionApprovalPolicy end

"""
    FSFLibre()

Approval policy that accepts SPDX license identifiers marked as FSF libre in
the checked-in SPDX snapshot.
"""
struct FSFLibre <: AbstractExpressionApprovalPolicy end

"""
    AllOf(policies...)

Approval policy combinator requiring every nested policy to approve a simple
SPDX license expression.
"""
struct AllOf{P<:Tuple} <: AbstractExpressionApprovalPolicy
    policies::P
end

"""
    AnyOf(policies...)

Approval policy combinator requiring at least one nested policy to approve a
simple SPDX license expression.
"""
struct AnyOf{P<:Tuple} <: AbstractExpressionApprovalPolicy
    policies::P
end

AllOf(policies::AbstractExpressionApprovalPolicy...) = AllOf(policies)
AnyOf(policies::AbstractExpressionApprovalPolicy...) = AnyOf(policies)
