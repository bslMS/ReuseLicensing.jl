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
expression has an approved licensing path, and supports repository-level
verification workflows based on `reuse lint --json` and `reuse spdx`.

The package is intended as a small, reusable foundation for tooling that needs to
reason about project licensing rather than merely copy license texts into a
repository.

This package is under active development, and public APIs may still change.

## Installation

```julia
using Pkg
Pkg.add("ReuseLicensing")
```

<!-- PkgTemplates: REUSE licensing section start -->
## Licensing

<img src="docs/src/assets/Logo_EUPL.svg" alt="EUPL logo" width="84" align="right">

Copyright © 2026 Guido Wolf Reichert and contributors

This package is made available under the package-level outbound license expression
`EUPL-1.2+`. The package-level license declaration and the corresponding license
text are provided in [`LICENSE`](LICENSE). The
[European Union Public Licence v1.2](https://eur-lex.europa.eu/eli/dec_impl/2017/863/oj)
is available in 23 official EU language versions.

Individual files may carry separate file-level license expressions, as recorded by their
SPDX notices or by [`REUSE.toml`](REUSE.toml).

This project follows the [REUSE specification](https://reuse.software/spec/) for file-level
copyright and licensing information. License texts used for file-level REUSE licensing are
stored in [`LICENSES/`](LICENSES/).

> Recorded `Manifest.toml` files under `.licensing/manifests/`, where provided,
> document dependency resolutions considered when choosing the package-level
> license expression. They are evidence for that licensing decision, not guarantees
> about every environment that users may create under different Julia versions,
> platforms, dependency resolutions, extensions, artifacts, load paths, or local
> modifications.

To verify the repository-level REUSE metadata:

```bash
reuse lint
reuse spdx
```
<!-- PkgTemplates: REUSE licensing section end -->
