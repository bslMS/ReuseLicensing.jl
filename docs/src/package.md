```@meta
CurrentModule = ReuseLicensing
```

# Package Licensing

!!! warning "This is not legal advice"
    This section is technical documentation, not a legal opinion. For binding legal decisions, especially publication, redistribution, relicensing, or registry policy questions, consult a qualified lawyer.

## Package-Level Declarations

REUSE records licensing information at file level. This is the correct
foundation for source-code compliance, because different files in the same
repository may have different copyright holders, licenses, or exceptions.

A Julia package, however, is also distributed and consumed as a package. For
that purpose, tooling often needs a package-level license declaration: the
license expression under which the package is offered as a package, assuming
the generated or declared package composition is used.

In ReuseLicensing.jl, this package-level declaration is separate from
file-level SPDX metadata. It does not replace SPDX headers, `REUSE.toml`, or
the license texts under `LICENSES/`. Instead, it records the
outbound package license expression that package tooling, registries, documentation,
and users may inspect directly.

A package-level declaration should therefore answer a different question from
file-level REUSE metadata:

- file-level metadata answers: under which license is this file available?
- package-level metadata answers: under which license is this package offered
  as a package?

For repositories generated or repaired by ReuseLicensing.jl, the root `LICENSE`
file is expected to contain a package-level license declaration followed by the
corresponding license texts and, where needed, exception texts. File-level
license texts remain available under `LICENSES/` according to REUSE.

Concretely, ReuseLicensing.jl expects `LICENSE` to start with:

```Mustache
{{{COPYRIGHT_NOTICE}}}

This package is made available under the following package-level outbound license
expression:

    {{{PACKAGE_LICENSE}}}
```

Package-level declarations are intentionally not treated as a substitute for
legal compatibility analysis. ReuseLicensing.jl can parse and validate SPDX
license expressions and apply explicit approval policies, but it does not infer
that an arbitrary combination of files, dependencies, and licenses forms a
legally valid redistributable whole.

## Project Metadata

### Project.toml

ReuseLicensing.jl records package-level licensing information in a dedicated
`[reuse_licensing]` table in `Project.toml`. This table is intended to make the
package-level declaration machine-readable without duplicating file-level REUSE
metadata.

For example, ReuseLicensing.jl itself records the following package-level
metadata:

```TOML
[reuse_licensing]
reuse_specification_version = "3.3"
spdx_license_list_version = "3.28.0"
package_license_expression = "EUPL-1.2+"
package_copyright_notice = "Copyright © 2026 Guido Wolf Reichert and contributors"
package_license_file = "LICENSE"
```

The first two entries record the specification and license-list versions that
formed the semantic frame when the metadata was created or last repaired. This
matters because validation depends not only on license texts, but also on the
known SPDX identifiers, exception identifiers, approval metadata, and deprecation
status available in a particular SPDX License List version.

The remaining entries record the package-level outbound SPDX license expression,
the copyright notice used for the package-level declaration, and the root file
that contains the human-readable package-level declaration with the corresponding
license and exception texts.

This metadata is not a validation result. It does not state that the repository
is currently compliant, that all files have been checked, or that the declared
package composition is legally redistributable. Validation results should be
recomputed from the repository contents and the selected policy.

### Release Evidence

Package-level metadata records the declared licensing frame, but it is not a
snapshot of every dependency resolution a user may create. For releases,
ReuseLicensing.jl can store additional licensing evidence under `.licensing/`.

Manifest snapshots are stored by package version and Julia host triplet:

```text
.licensing/manifests/vX.Y.Z/<filename>.toml
```

where `<filename>` is derivedfrom a filename-safe normalization of the current
Julia host triplet:

```julia
replace(Base.BinaryPlatforms.host_triplet(), r"_version\+" => "-") * ".toml"
```

These manifest snapshots document the Julia dependency resolution considered
when a package-level licensing assessment was made. They are evidence for that
assessment, not license grants for third-party dependencies and not guarantees
that other Julia versions, platforms, dependency resolutions, extensions,
artifacts, load paths, or local modifications are compatible with the same
package-level license declaration.

ReuseLicensing offers the convenience function [`record_manifest_evidence!`](@ref) to
store the current `Manifest.toml`.

## Manage LICENSE File



## Adoption and Repair

## API Reference

```@docs
check_package_licensing
is_ok
set_package_license!
record_manifest_evidence!
```
