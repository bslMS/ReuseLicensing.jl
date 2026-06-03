```@meta
CurrentModule = ReuseLicensing
```

# ReuseLicensing.jl

`ReuseLicensing.jl` provides core infrastructure for working with REUSE and SPDX
licensing metadata in [Julia](https://julialang.org/) projects.
It parses SPDX license expressions, extracts referenced licenses, exceptions, and
`LicenseRef-*` identifiers, checks whether an expression has an approved licensing
path, and supports REUSE compliance workflows based on `reuse lint --json` and
`reuse spdx`.

The package is developed by [BSL Management Support](https://bsl-support.de) as part of a
broader commitment to transparent open source infrastructure, clear licensing
metadata, responsible software stewardship, and practical software independence.

## Scope

ReuseLicensing is intended to support:

- parsing and normalizing SPDX license expressions,
- querying a checked-in SPDX License List snapshot,
- checking SPDX expressions against explicit approval policies,
- consuming `reuse lint --json` and `reuse spdx` output,
- validating and updating package-level licensing metadata for Julia packages,
- recording `Manifest.toml` snapshots as licensing evidence.

The package is general Julia infrastructure. It is not specific to BSL Management
Support's modeling and simulation work.

## Package-Level Licensing

ReuseLicensing distinguishes package-level licensing from file-level licensing.

Package-level functions, such as `set_package_license!()`,
`set_package_copyright!()`, and `adopt_package_licensing!()`, manage the
authoritative package-level licensing state recorded in the root `LICENSE` file and
in the `[reuse_licensing]` table of `Project.toml`.

## File-Level Licensing

File-level licensing remains repository-owned. SPDX notices, `REUSE.toml`,
`LICENSES/`, and related repository layout choices can be edited directly by package
authors according to the REUSE specification.

ReuseLicensing can consume REUSE tool output and support repository-level checks, but
it does not treat `REUSE.toml` or README prose as the source of truth for the package-level
outbound license declaration.

## Status

The package is in active development. Public APIs may still change while the core
abstractions are refined.

## Installation

```julia
using Pkg
Pkg.add("ReuseLicensing")
```

The source code and issue tracker are available in the
[GitHub repository](https://github.com/bslMS/ReuseLicensing.jl).

ReuseLicensing can parse SPDX expressions and inspect its checked-in SPDX
snapshot without external tools. Functions that inspect repository-level REUSE
metadata or check REUSE compliance call the `reuse` executable from the
[`reuse-tool`](https://codeberg.org/fsfe/reuse-tool) project, so `reuse` must be
available on `PATH` for those workflows.

For example, on macOS with Homebrew:

```shell
brew install reuse
```

In Python-based environments and CI jobs:

```shell
python -m pip install "reuse[charset-normalizer]"
```

## Documentation

- [SPDX Core](spdx.md): parse SPDX license expressions and query bundled
  SPDX License List data.
- [Approval Layers](approval.md): check SPDX expressions against explicit
  approval policies.
- [Package Licensing](package.md): manage package-level license declarations
  in `Project.toml` and `LICENSE`.

## REUSE Specification Version

ReuseLicensing records the REUSE specification version it is based on.

```@docs
reuse_specification_version()
```

```@example version
using ReuseLicensing
reuse_specification_version()
```

## Index

```@index
```
