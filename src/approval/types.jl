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
    GeneralRegistryCodeApproval()

Approval policy for Julia package source code intended for acceptance by the
General registry.

This policy models the registry-relevant question whether the package code that users
load, precompile, compile, and depend on has an acceptable OSI-approved licensing path.

The policy accepts single OSI-approved SPDX license identifiers and `OR` expressions
with at least one acceptable OSI-approved branch. It deliberately does not treat
conjunctive `AND` expressions as approved package-code licenses, even if all conjuncts
are individually OSI-approved. Such expressions may be valid SPDX expressions for file
sets or combined distributions, but they do not represent a clean license path for
ordinary package-code acceptance.
"""
struct GeneralRegistryCodeApproval <: AbstractExpressionApprovalPolicy end

"""
    GeneralRegistryContentApproval()

Approval policy for non-code repository content intended to coexist with Julia packages
accepted by the General registry.

This policy models acceptable licensing for documentation, examples, metadata,
configuration files, assets, and other non-code material in a REUSE/SPDX-aware
repository. It is intended to complement [`GeneralRegistryCodeApproval`](@ref),
which applies to the package source code that users load and depend on.

The policy accepts common open-content and public-domain-style licenses such as
`CC0-1.0`, `CC-BY-4.0`, and `CC-BY-SA-4.0`, which are approved by FSF,
[Debian](https://wiki.debian.org/DFSGLicenses#DFSG-compatible_Licenses),
[Fedora](https://docs.fedoraproject.org/en-US/legal/allowed-licenses/), and the
[Eclipse](https://www.eclipse.org/legal/licenses/) Foundation.
"""
struct GeneralRegistryContentApproval <: AbstractExpressionApprovalPolicy end
