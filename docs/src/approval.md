```@meta
CurrentModule = ReuseLicensing
```

# Approval Layers

## Expression-Level Approval

Explain that this layer is file-agnostic and repository-agnostic.

## Approval Policies

Document:

- `OSIApproved()`
- `FSFLibre()`
- `AnyOf(...)`
- `AllOf(...)`

## Approved License Paths

Explain the core semantics:

- `A OR B`: approved if either branch has an approved path
- `A AND B`: approved if both branches are approved
- `LicenseRef-*`: not approved by SPDX metadata policies
- `WITH`: currently conservatively rejected

## Examples

Show:

```julia
has_approved_license_path("MIT OR Apache-2.0", OSIApproved())
```
