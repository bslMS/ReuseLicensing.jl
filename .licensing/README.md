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

where `<filename>` is the Julia host triplet with the Julia version normalized
for use as a file name:

```julia
replace(Base.BinaryPlatforms.host_triplet(), r"_version\+" => "-") * ".toml"
```
