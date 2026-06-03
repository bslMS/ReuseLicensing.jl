# Licensing Evidence

This directory contains release-scoped licensing evidence generated or collected
for this package.

The files in this directory are not license grants. The authoritative licensing
information remains:

- the package-level declaration in `LICENSE`,
- the file-level SPDX information in source files and `REUSE.toml`,
- the license texts under `LICENSES/`,
- and the package-level metadata in `Project.toml`.

Stored Manifest snapshots record the Julia dependency resolution considered when
a package-level licensing assessment was made. They do not license third-party
dependencies and do not imply that other dependency resolutions are compatible
with the package-level license declaration.

Dependency license reports are generated artifacts. They should be regenerated
for each release, Julia version, platform, and relevant tooling context.

## Naming Convention

Release evidence is stored under:

```text
.licensing/manifests/vX.Y.Z/<filename>.toml
```

When a named evidence profile is used, it is stored below the package version:

```text
.licensing/manifests/vX.Y.Z/<profile>/<filename>.toml
```

where `<filename>` is the Julia host triplet with the Julia version normalized
for use as a file name:

```julia
replace(Base.BinaryPlatforms.host_triplet(), r"_version\+" => "-") * ".toml"
```

Profile names are user-defined labels for selected dependency resolutions. They
are normalized to lowercase path components. Whitespace and underscores are
replaced by `-`; path components may contain lowercase ASCII letters, digits,
`.`, and `-`, and must not be empty, hidden, absolute, or contain `.` or `..`.

Examples:

```text
.licensing/manifests/vX.Y.Z/gpu/<filename>.toml
.licensing/manifests/vX.Y.Z/plotting/<filename>.toml
.licensing/manifests/vX.Y.Z/extensions/fooext/<filename>.toml
```

## Profile Evidence

For packages using Julia package extensions or optional dependency sets, release
evidence may be split into profiles.

The unprofiled path records the default dependency resolution considered for the
package. Named profiles record additional selected environments, such as
`plotting`, `gpu`, `full`, or `extensions/FooExt`.

These profiles are licensing evidence for the environments they record. They do
not imply that all possible combinations of weak dependencies, extensions,
artifacts, preferences, load paths, or local modifications have been assessed.
