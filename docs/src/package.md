```@meta
CurrentModule = ReuseLicensing
```

# Package Licensing

!!! warning "This is not legal advice"
    This section is technical documentation, not a legal opinion. For binding legal
    decisions, especially publication, redistribution, relicensing, or registry policy
    questions, consult a qualified lawyer.

Package licensing is distinct from repository approval. Repository approval is
planned as a policy check over the licenses found in repository files. Package
licensing records and validates the outbound package-level declaration in
`Project.toml` and `LICENSE`. ReuseLicensing does not infer that declaration
from the file-level license set, nor does it decide whether the declared package
license is legally compatible with every file-level license.

## Package-Level Declarations

REUSE records licensing information at file level. This is the correct
foundation for source-code compliance, because different files in the same
repository may have different copyright holders, licenses, or exceptions.

A Julia package, however, is also distributed and consumed as a combined work. For
that purpose, tooling often needs a package-level license declaration: the
license expression under which the package is offered as a package, assuming
the generated or declared package composition is used.

In ReuseLicensing, this package-level declaration is separate from
file-level licensing information. It does not replace SPDX headers, `REUSE.toml`, or
the license texts under `LICENSES/`. Instead, it records the
outbound package license expression that package tooling, registries, documentation,
and users may inspect directly.

A package-level declaration should therefore answer a different question from
file-level REUSE metadata:

- file-level licensing narrowly answers: under which license is this file available?
- package-level licensing answers: under which license is this package offered
  as a combined work?

Package-level declarations are intentionally not treated as a substitute for
legal compatibility analysis. ReuseLicensing can parse and validate SPDX
license expressions and apply explicit approval policies, but it does not infer
that an arbitrary combination of files, dependencies, and licenses forms a
legally valid redistributable whole.

## Root LICENSE File

For repositories generated or adopted by ReuseLicensing, the root `LICENSE`
file is expected to contain a package-level license declaration followed by the
corresponding license texts and, where needed, exception texts. License texts
used for file-level licensing remain available under `LICENSES/` in accordance
with REUSE.

Concretely, ReuseLicensing expects `LICENSE` to start as shown in the following example:

```
Copyright © ...

This package is made available under the following package-level outbound license
expression:

    EUPL-1.2+
```

The `LICENSE` file expected and produced by ReuseLicensing will have the following
overall structure:

```
COPYRIGHT NOTICE

PACKAGE-LEVEL LICENSE EXPRESSION

EXPLANATORY TEXT

---

LICENSE AND EXCEPTION TEXTS (as referenced by the package-level license expression)
```

To avoid ambiguity, ReuseLicensing rejects additional root-level license files
such as `COPYING`, `COPYRIGHT`, or `LICENSE.txt`.

To avoid inconsistencies, package-level declarations should be changed through
ReuseLicensing or ReuseLicensing-aware tooling. An already adopted package can
change its package license expression with [`set_package_license!`](@ref) and
its package copyright notice with [`set_package_copyright!`](@ref). See
[Adoption of Legacy REUSE-compliant Packages](#adoption-of-legacy-reuse-compliant-packages)
for migration into the ReuseLicensing layout.

For example, an adopted package can change its package-level license expression
without editing `Project.toml` or `LICENSE` by hand:

```julia
set_package_license!(
    ".",
    "EUPL-1.2+";
    license_policy = OSIApproved(),
)
```

## Project.toml Metadata

ReuseLicensing records package-level licensing information in a dedicated
`[reuse_licensing]` table in `Project.toml`. This table is intended to make the
package-level declaration machine-readable without duplicating file-level REUSE
metadata.

For example, ReuseLicensing itself records the following package-level
metadata:

```TOML
name = "ReuseLicensing"
uuid = ...
...

[reuse_licensing]
reuse_specification_version = "3.3"
spdx_license_list_version = "3.28.0"
package_license_expression = "EUPL-1.2+"
package_copyright_notice = "Copyright © 2026 Guido Wolf Reichert and contributors"
package_license_file = "LICENSE"
```

The first two entries record the specification and license-list versions that
formed the semantic frame when the metadata was created or last updated.
This matters because validation depends not only on license texts, but also on the
known SPDX identifiers, exception identifiers, approval information, and deprecation
status available in a particular SPDX License List version.

The remaining entries record the package-level outbound SPDX license expression,
the copyright notice used for the package-level declaration, and the root file
that contains the human-readable package-level declaration with the corresponding
license and exception texts.

This metadata is not a validation result. It does not state that the repository
is currently compliant, that all files have been checked, or that the declared
package composition is legally redistributable. Validation results should be
recomputed from the repository contents and the selected policy.

!!! note "Generate package-level metadata instead of editing it by hand"
    Use the functions listed in the [API Reference](#api-reference) to change
    package-level declarations or adopt a package into the ReuseLicensing layout.
    This keeps the `[reuse_licensing]` table and root `LICENSE` file coherent.

## Adoption of Legacy REUSE-compliant Packages

Existing Julia packages can be adopted into the package-level licensing layout
expected by ReuseLicensing when they are already REUSE-compliant and do not yet
contain a `[reuse_licensing]` table in `Project.toml`.

Adoption is intentionally conservative. ReuseLicensing does not infer the
outbound package license expression from the file-level license set. The caller
must provide the package-level SPDX license expression and the package-level
copyright information explicitly:

```julia
adopt_package_licensing!(
    ".";
    package_license = "EUPL-1.2+",
    year = "2026",
    copyright_holders = ["Example Author", "contributors"],
)
```

The function checks REUSE compliance, verifies the package license expression
against the selected `license_policy`, appends the generated `[reuse_licensing]`
table to `Project.toml`, and writes the canonical root `LICENSE` file. If a root
`LICENSE` file already exists, adoption fails unless `force = true` is passed.
This is deliberate: replacing an existing package-level license file should be an
explicit decision.

Adoption is not a repository repair operation. It does not rewrite README
licensing sections, change file-level SPDX notices, or decide whether the chosen
package-level declaration is legally compatible with every file-level license.

## README Licensing Sections

ReuseLicensing does not treat README licensing sections as authoritative
package-level declarations. The authoritative package-level declaration is the
combination of `[reuse_licensing]` metadata in `Project.toml` and the canonical
root `LICENSE` file.

README licensing sections may summarize or point to these files, but
ReuseLicensing does not rewrite them when package-level licensing metadata is
adopted or changed. This avoids duplicating license expressions or copyright
notices in user-editable prose.

## Release Evidence

Package-level metadata records the declared licensing frame, but it is not a
snapshot of every dependency resolution a user may create and eventually distribute.
For releases, ReuseLicensing can store additional licensing evidence under `.licensing/`.

Manifest snapshots are stored by package version and Julia host triplet:

```text
.licensing/manifests/vX.Y.Z/<filename>.toml
```

Optional evidence profiles are stored below the package version:

```text
.licensing/manifests/vX.Y.Z/<profile>/<filename>.toml
```

where `<filename>` is derived from a filename-safe normalization of the current
Julia host triplet:

```julia
replace(Base.BinaryPlatforms.host_triplet(), r"_version\+" => "-") * ".toml"
```

Profile names are user-defined labels for selected dependency resolutions. They
are normalized to lowercase filename-safe path components. This can be used for
advertised environments such as `plotting`, `gpu`, `full`, or
`extensions/FooExt`, without implying that every possible extension, weak
dependency, preference, artifact, load path, or local modification has been
assessed.

These manifest snapshots document the Julia dependency resolution considered
when a package-level licensing assessment was made. They are evidence for that
assessment, not license grants for third-party dependencies and not guarantees
that other Julia versions, platforms, dependency resolutions, extensions,
artifacts, load paths, or local modifications are compatible with the same
package-level license declaration.

ReuseLicensing offers the convenience function [`record_manifest_evidence!`](@ref) to
store the current `Manifest.toml`.

For exampled:

```julia
record_manifest_evidence!("."; force = true)
record_manifest_evidence!("."; profile = "extensions/FooExt", force = true)
```

## API Reference

```@docs
check_package_licensing
has_valid_package_licensing
set_package_license!
set_package_copyright!
adopt_package_licensing!
record_manifest_evidence!
```
