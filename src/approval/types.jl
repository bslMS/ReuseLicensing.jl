# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

abstract type AbstractExpressionApprovalPolicy end

struct OSIApproved <: AbstractExpressionApprovalPolicy end
struct FSFLibre <: AbstractExpressionApprovalPolicy end

struct AllOf{P<:Tuple} <: AbstractExpressionApprovalPolicy
    policies::P
end

struct AnyOf{P<:Tuple} <: AbstractExpressionApprovalPolicy
    policies::P
end

AllOf(policies::AbstractExpressionApprovalPolicy...) = AllOf(policies)
AnyOf(policies::AbstractExpressionApprovalPolicy...) = AnyOf(policies)
