<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/src/assets/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="docs/src/assets/logo.svg">
    <img src="docs/src/assets/logo.svg" alt="Reuse Licensing logo" width="56">
  </picture>
  ReuseLicensing.jl
</h1>

[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://bsl-support.de/julia/ReuseLicensing.jl/)
[![Build Status](https://github.com/bslMS/ReuseLicensing.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bslMS/ReuseLicensing.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Codecov](https://codecov.io/gh/bslMS/ReuseLicensing.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/bslMS/ReuseLicensing.jl)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![REUSE](https://github.com/bslMS/ReuseLicensing.jl/actions/workflows/reuse.yml/badge.svg?branch=main)](https://github.com/bslMS/ReuseLicensing.jl/actions/workflows/reuse.yml?query=branch%3Amain)

<p align="center">
  <a href="https://reuse.software/spec/">REUSE Specification</a> ·
  <a href="https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/">SPDX License Expressions</a> ·
  <a href="https://github.com/bslMS/ReuseLicensing.jl/issues">Issues</a>
</p>

ReuseLicensing.jl provides core infrastructure for working with REUSE and SPDX
licensing metadata in Julia projects. It parses SPDX license expressions, extracts
referenced licenses, exceptions, and `LicenseRef-*` identifiers, checks whether an
expression has an approved licensing path, and supports REUSE compliance workflows
based on `reuse lint --json` and `reuse spdx`.

The package is intended as a small, reusable foundation for tooling that needs to
reason about project licensing rather than merely copy license texts into a
repository.

This package is under active development, and public APIs may still change.

## Installation

```julia
using Pkg
Pkg.add("ReuseLicensing")
```

ReuseLicensing.jl can parse SPDX expressions and inspect its checked-in SPDX
snapshot without external tools. Functions that check repository-level REUSE
compliance call the `reuse` executable from the
[`reuse-tool`](https://codeberg.org/fsfe/reuse-tool) project, so `reuse` must be
available on `PATH` for those workflows.

On macOS, one option is Homebrew:

```shell
brew install reuse
```

In Python-based environments and CI jobs, the tool can also be installed with
`pip`:

```shell
python -m pip install "reuse[charset-normalizer]"
```

## What It Does

ReuseLicensing.jl currently supports:

- parsing and normalizing SPDX license expressions,
- querying a checked-in SPDX License List snapshot,
- checking SPDX expressions against approval policies,
- consuming `reuse lint --json` and `reuse spdx` output,
- validating and updating package-level licensing metadata for Julia packages,
- recording `Manifest.toml` snapshots as licensing evidence.

## Quick Start

Currently, SPDX license expressions can be parsed and checked against explicit
approval policies:

```julia
using ReuseLicensing

parsed = parse_spdx_expression("MIT OR Apache-2.0")

has_approved_license_path(parsed, OSIApproved()) # true
has_approved_license_path("MIT AND LicenseRef-Internal", ValidSPDX()) # true
```

Package-level licensing checks operate on a package root. The examples below assume that
Julia's current working directory is the package root:

```julia
using ReuseLicensing

check = check_package_licensing(".")
isempty(check.issues) # true when package licensing checks pass

has_valid_package_licensing(".") # a boolean convenience wrapper
```

Legacy packages that are already REUSE-compliant can be adopted to the format that
ReuseLicensing.jl expects using `adopt_package_licensing!()`. For more information,
turn to the [stable documentation](https://bsl-support.de/julia/ReuseLicensing.jl/).

<!-- PkgTemplates: REUSE licensing section start -->
## Licensing

<img src="docs/src/assets/Logo_EUPL.svg" alt="EUPL logo" width="84" align="right">

ReuseLicensing.jl is offered under the outbound package-level license expression
`EUPL-1.2+`. The authoritative package-level license declaration and copyright notice are
recorded in [`LICENSE`](LICENSE), together with the corresponding license text.

Machine-readable package-level licensing metadata is recorded in the `[reuse_licensing]`
table of [`Project.toml`](Project.toml).

The [European Union Public Licence v1.2](https://eur-lex.europa.eu/eli/dec_impl/2017/863/oj)
is available in 23 official EU language versions.

Individual files may carry separate file-level license expressions, as recorded
by their SPDX notices or by [`REUSE.toml`](REUSE.toml). This project follows the
[REUSE specification](https://reuse.software/spec/) for file-level copyright and
licensing information. License texts used for file-level REUSE licensing are
stored in [`LICENSES/`](LICENSES/).

> Recorded `Manifest.toml` files under `.licensing/manifests/`, where provided,
> document dependency resolutions considered when choosing the package-level
> license expression. They are evidence for that decision, not guarantees for
> other Julia versions, platforms, dependency resolutions, extensions, artifacts,
> load paths, or local modifications.

To verify repository-level REUSE metadata:

```bash
reuse lint
reuse spdx
```
<!-- PkgTemplates: REUSE licensing section end -->
