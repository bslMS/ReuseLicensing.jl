# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# Internal simple-license approval predicate for concrete policies.
function _license_is_approved(
        policy::AbstractExpressionApprovalPolicy,
        expr::AbstractSPDXSimpleLicenseExpression
)
    throw(ArgumentError(
        "Cannot evaluate approval for simple SPDX expression type " *
        "$(typeof(expr)) under policy type $(typeof(policy))."
    ))
end

function _license_is_approved(policy::AnyOf, expr::AbstractSPDXSimpleLicenseExpression)
    for pol in policy.policies
        _license_is_approved(pol, expr) && return true
    end
    return false
end

function _license_is_approved(policy::AllOf, expr::AbstractSPDXSimpleLicenseExpression)
    for pol in policy.policies
        _license_is_approved(pol, expr) || return false
    end
    return true
end

function _license_is_approved(::OSIApproved, expr::SPDXLicenseId)
    return is_spdx_osi_approved(base_license_identifier(expr.identifier))
end

function _license_is_approved(::FSFLibre, expr::SPDXLicenseId)
    return is_spdx_fsf_libre(base_license_identifier(expr.identifier))
end

# UnconjoinedOSIApproval accepts OSI-approved licenses for code.
function _license_is_approved(::UnconjoinedOSIApproval, expr::SPDXLicenseId)
    return _license_is_approved(OSIApproved(), expr)
end

# OpenContentApproval will accept a subset of FSF libre approved content licenses.
function _license_is_approved(::OpenContentApproval, expr::SPDXLicenseId)
    return expr.identifier in ("CC0-1.0", "CC-BY-4.0", "CC-BY-SA-4.0")
end

# Custom licenses cannot be verified from snapshot metadata.
_license_is_approved(::OSIApproved, expr::SPDXLicenseRef) = false
_license_is_approved(::FSFLibre, expr::SPDXLicenseRef) = false

# Custom licenses are not approved by conservative regimes.
_license_is_approved(::UnconjoinedOSIApproval, expr::SPDXLicenseRef) = false
_license_is_approved(::OpenContentApproval, expr::SPDXLicenseRef) = false

function _has_approved_license_path(
        expr::AbstractSPDXSimpleLicenseExpression,
        policy::AbstractExpressionApprovalPolicy
)
    return _license_is_approved(policy, expr)
end

function _has_approved_license_path(
        expr::SPDXDisjunctiveExpression,
        policy::AbstractExpressionApprovalPolicy
)
    return _has_approved_license_path(expr.left, policy) ||
           _has_approved_license_path(expr.right, policy)
end

# In conservative acceptance regimes we will not reason for conjunctions.
function _has_approved_license_path(
        expr::SPDXConjunctiveExpression,
        policy::UnconjoinedOSIApproval
)
    return false
end

# In conservative acceptance regimes we will not reason for conjunctions.
function _has_approved_license_path(
        expr::SPDXConjunctiveExpression,
        policy::OpenContentApproval
)
    return false
end

function _has_approved_license_path(
        expr::SPDXConjunctiveExpression,
        policy::AbstractExpressionApprovalPolicy
)
    return _has_approved_license_path(expr.left, policy) &&
           _has_approved_license_path(expr.right, policy)
end

# Conservatively, we cannot deduce approval for a license with an exception.
function _has_approved_license_path(
        expr::SPDXWithExceptionExpression,
        policy::AbstractExpressionApprovalPolicy
)
    return false
end

"""
    has_approved_license_path(expr, policy; legacy = :normalize)

Return whether an SPDX license expression has at least one license path approved
by `policy`.

String inputs are parsed with [`parse_spdx_expression`](@ref). `OR` expressions
require one approved branch; `AND` expressions require all branches. `WITH`
expressions are currently treated conservatively as not approved.
"""
function has_approved_license_path(
        parsed::ParsedSPDXExpression,
        policy::AbstractExpressionApprovalPolicy
)
    return _has_approved_license_path(parsed.ast, policy)
end

function has_approved_license_path(
        expr::AbstractString,
        policy::AbstractExpressionApprovalPolicy;
        legacy = :normalize
)
    return has_approved_license_path(parse_spdx_expression(expr; legacy), policy)
end
