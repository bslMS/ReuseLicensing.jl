```@meta
CurrentModule = ReuseLicensing
```

# ReuseLicensing.jl

`ReuseLicensing.jl` provides core infrastructure for working with REUSE- and SPDX-based licensing metadata in [Julia programming language](https://julialang.org/) projects.

The package is developed by [BSL Management Support](https://bsl-support.de) as part of a
broader commitment to transparent open source infrastructure, clear licensing
metadata, responsible software stewardship, and practical software independence.

## Scope

`ReuseLicensing.jl` is intended to support:

- parsing SPDX license expressions as used by the REUSE specification,
- collecting normalized license, exception, and `LicenseRef-*` identifiers,
- checking whether a license expression has an acceptable approval path,
- consuming `reuse lint --json` output for project-level license analysis,
- supporting license integrity checks and reporting workflows.

The package is general Julia infrastructure. It is not specific to BSL Management Support's modeling and simulation work.

## Status

The package is in early active development. APIs may still change while the core abstractions are refined.

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/bslMS/ReuseLicensing.jl")
```

The source code and issue tracker are available in the
[GitHub repository](https://github.com/bslMS/ReuseLicensing.jl).

## Index

```@index
```
