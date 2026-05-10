<h1>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/src/assets/logo-dark.svg">
    <source media="(prefers-color-scheme: light)" srcset="docs/src/assets/logo.svg">
    <img src="docs/src/assets/logo.svg" alt="Reuse Licensing logo" width="56">
  </picture>
  ReuseLicensing.jl
</h1>

[![Build Status](https://github.com/bslMS/ReuseLicensing.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bslMS/ReuseLicensing.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)
[![REUSE status](https://img.shields.io/badge/REUSE-compliant-brightgreen.svg)](https://reuse.software/)

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
Pkg.add(url = "https://github.com/bslMS/ReuseLicensing.jl")
```

<!-- PkgTemplates: REUSE licensing section start -->
## Licensing

<img src="docs/src/assets/Logo_EUPL.svg" alt="EUPL logo" width="84" align="right">

Copyright © 2026 Guido Wolf Reichert

The source code in this project is licensed under `EUPL-1.2-or-later`; the [EUPL v1.2](https://eur-lex.europa.eu/eli/dec_impl/2017/863/oj) was published in the Official Journal of the European Union and is available in 23 official EU languages. Documentation,
documentation assets, project artifacts, and tooling files may use separate license expressions.

This project follows the [REUSE specification](https://reuse.software/spec/) for copyright
and licensing information. The authoritative license texts are stored in `LICENSES/`.
Copyright and license information for individual files is provided via SPDX headers and,
where applicable, via `REUSE.toml`.

Useful REUSE checks:

```bash
reuse lint
reuse spdx
```

<!-- PkgTemplates: REUSE licensing section end -->
