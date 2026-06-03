```@meta
CurrentModule = ReuseLicensing
```

# Approval Layers

ReuseLicensing separates license approval into layers. The lowest layer works
only on SPDX license expressions. Later layers will build on that result when
checking file metadata and complete repositories.

## Expression-Level Approval

Expression-level approval answers one narrow question: does an SPDX license
expression contain at least one licensing path accepted by a policy?

This layer is deliberately agnostic about files, file contents, copyright
statements, license text placement, and repository layout. It only evaluates the
normalized SPDX expression tree returned by [`parse_spdx_expression`](@ref).

### Approval Policies

Approval is policy-dependent. ReuseLicensing currently provides policies based on
the checked-in SPDX License List snapshot:

- [`OSIApproved`](@ref): accepts SPDX license identifiers marked as OSI approved.
- [`FSFLibre`](@ref): accepts SPDX license identifiers marked as FSF libre.
- [`UnconjoinedOSIApproval`](@ref): accepts OSI-approved package license expressions
  without conjunctions.
- [`OpenContentApproval`](@ref): accepts selected non-code content licenses, currently
  `CC0-1.0`, `CC-BY-4.0`, and `CC-BY-SA-4.0`.

Policies can be combined:

- [`AnyOf`](@ref): accepts a simple license expression when at least one nested
  policy accepts it.
- [`AllOf`](@ref): accepts a simple license expression only when every nested
  policy accepts it.

### Approved License Paths

The main predicate is [`has_approved_license_path`](@ref). For composite SPDX
expressions it follows the structure of the expression:

- `A OR B`: approved if either branch has an approved path (disjunction).
- `A AND B`: approved if both branches are approved (conjunction).
- `LicenseRef-*`: not approved by policies based on SPDX License List data.
- `A WITH exception`: currently treated conservatively as not approved.

The name "license path" is intentional. For an `OR` expression, an expression can
be approved even when one branch is not accepted, as long as another branch
provides an accepted path.

!!! note "Stricter Approval Policies"
    [`UnconjoinedOSIApproval`](@ref) and [`OpenContentApproval`](@ref)
    currently do not approve conjunctions of license identifiers. This is a
    stricter rule than the generic expression-level semantics
    used by policies such as [`OSIApproved`](@ref) and [`FSFLibre`](@ref), where
    an `AND` expression is approved when all branches are approved.

### Examples

An expression with two OSI-approved licenses is accepted:

```@example approval
using ReuseLicensing

has_approved_license_path("MIT OR Apache-2.0", OSIApproved())
```

The generic [`OSIApproved`](@ref) policy also accepts a conjunction when all
branches are OSI-approved:

```@example approval
has_approved_license_path("MIT AND Apache-2.0", OSIApproved())
```

The stricter [`UnconjoinedOSIApproval`](@ref) policy does not approve such
conjunctions as package-level code license expressions:

```@example approval
has_approved_license_path("MIT AND Apache-2.0", UnconjoinedOSIApproval())
```

For `OR`, one accepted branch is enough:

```@example approval
has_approved_license_path("MIT OR LicenseRef-Internal", OSIApproved())
```

Under the generic expression-level semantics, an `AND` expression is rejected if
one branch is not approved:

```@example approval
has_approved_license_path("MIT AND LicenseRef-Internal", OSIApproved())
```

Policies can be composed when a project accepts more than one approval source:

```@example approval
policy = AnyOf(OSIApproved(), FSFLibre())

has_approved_license_path("CC0-1.0 OR 0BSD", policy)
```

`WITH` expressions are parsed, but approval is intentionally conservative for
now:

```@example approval
has_approved_license_path(
    "GPL-2.0-only WITH Classpath-exception-2.0",
    OSIApproved(),
)
```

Use `ValidSPDX` to accept any valid SPDX license expression without applying an
additional approval policy:

```@example approval
has_approved_license_path("MIT AND LicenseRef-Internal", ValidSPDX())
```

### API Reference

```@docs
has_approved_license_path
OSIApproved
FSFLibre
UnconjoinedOSIApproval
OpenContentApproval
AnyOf
AllOf
ValidSPDX
```

## File-Level Approval

File-level approval is planned as a separate layer. It will build on
expression-level approval and add file-level licensing concerns such as discovered
SPDX license expressions, where they were found, and file-specific issues.

## Repository-Level Approval

Repository-level approval is planned as an aggregation layer over file-level
results and repository checks such as REUSE lint output and required license
texts. It is distinct from package-level licensing, which records and validates
the outbound package-level declaration in `Project.toml` and `LICENSE`.
