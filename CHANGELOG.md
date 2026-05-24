<!--
SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]



## [0.1.3] - 2026-05-23

- Updated installation instructions to use the Julia General Registry in README and docs.
- Replace the static REUSE badge with a live GitHub Actions workflow badge.
- Split REUSE compliance checking into a dedicated GitHub Actions workflow.
- Make the documentation build use the local package checkout.
- Licensed `codecov.yml` under `CC0-1.0`.
- Added `CHANGELOG.md`.

## [0.1.2] - 2026-05-20

- Added `UnconjoinedOSIApproval()` for OSI-approved package-code license paths without conjunctions.
- Added `OpenContentApproval()` for selected non-code content licenses: `CC0-1.0`, `CC-BY-4.0`, and `CC-BY-SA-4.0`.
- Clarified that generic approval policies such as `OSIApproved()` and `FSFLibre()` may approve `AND` expressions when all branches are approved.
- Documented that stricter approval regimes should reject conjunctions.

## [0.1.1] - 2026-05-20

- Added `scripts/` to dependabot scope.
- Added codecov to CI workflows and added codecov badge to `README.md`.
- Added `EUPL-1.2` license text to `LICENSES`.
- Added compatibility boundaries for `SHA.jl` and `TOML.jl`.

## [0.1.0] - 2026-05-14

- Initial public version.


[Unreleased]: https://github.com/bslMS/ReuseLicensing.jl/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/bslMS/ReuseLicensing.jl/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/bslMS/ReuseLicensing.jl/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/bslMS/ReuseLicensing.jl/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bslMS/ReuseLicensing.jl/tree/v0.1.0
