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
struct AllOf{P <: Tuple} <: AbstractExpressionApprovalPolicy
    policies::P
end

"""
    AnyOf(policies...)

Approval policy combinator requiring at least one nested policy to approve a
simple SPDX license expression.
"""
struct AnyOf{P <: Tuple} <: AbstractExpressionApprovalPolicy
    policies::P
end

AllOf(policies::AbstractExpressionApprovalPolicy...) = AllOf(policies)
AnyOf(policies::AbstractExpressionApprovalPolicy...) = AnyOf(policies)

"""
    UnconjoinedOSIApproval()

Approval policy for OSI-approved license paths without conjunctions.

This policy is useful when an expression is expected to provide at least one clear
OSI-approved license path, rather than a conjunctive set of simultaneously applicable
license obligations.

The policy accepts single OSI-approved SPDX license identifiers and `OR` expressions
with at least one acceptable OSI-approved branch. It deliberately does not approve
conjunctive `AND` expressions, even if all conjuncts are individually OSI-approved.
Such expressions may be valid SPDX expressions for file sets or combined distributions,
but they are not accepted by this stricter path-oriented policy.
"""
struct UnconjoinedOSIApproval <: AbstractExpressionApprovalPolicy end

"""
    OpenContentApproval()

Approval policy for selected open-content and public-domain-style licenses.

This policy is useful for documentation, examples, metadata, configuration files,
assets, and other non-code material in REUSE/SPDX-aware repositories. It is intended
as a reusable content-licensing building block and can be combined with software
license policies such as [`UnconjoinedOSIApproval`](@ref) where a broader file-level
approval rule is needed.

The policy accepts selected open-content and public-domain-style licenses such as
`CC0-1.0`, `CC-BY-4.0`, and `CC-BY-SA-4.0`. These licenses are accepted by major
free/open-source policy references, including the FSF, Debian, Fedora, and the
Eclipse Foundation:

- [FSF](https://www.gnu.org/licenses/license-list.html)
- [Debian](https://wiki.debian.org/DFSGLicenses#DFSG-compatible_Licenses)
- [Fedora](https://docs.fedoraproject.org/en-US/legal/allowed-licenses/)
- [Eclipse Foundation](https://www.eclipse.org/legal/licenses/)

The accepted set is intentionally narrow and does not include non-commercial or
no-derivatives Creative Commons variants.
"""
struct OpenContentApproval <: AbstractExpressionApprovalPolicy end

"""
    ValidSPDX()

Null-level approval policy that accepts any valid SPDX license expression.

This policy checks only SPDX syntax and identifier validity. It does not make a
legal, compatibility, Free Software, Open Source, registry, or project-specific
approval judgment.
"""
struct ValidSPDX <: AbstractExpressionApprovalPolicy end
