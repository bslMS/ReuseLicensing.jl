<!--
SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Contributing

ReuseLicensing.jl is currently developed as a controlled early-stage project.

The preferred forms of contribution at this stage are:

- issue reports
- failing test cases
- documentation corrections
- small, well-scoped improvements

Pull requests are considered selectively. Larger changes, new APIs, or architectural
changes should be discussed in an issue before implementation.

All contributions must fit the technical scope, licensing policy, and long-term
direction of the project. Pull requests may be accepted at the sole discretion of
the maintainer.

## Developer Certificate of Origin

All commits contributed to this project must be signed off using the Developer
Certificate of Origin (DCO). By adding a `Signed-off-by` line to a commit message, you
certify that you have the right to submit the contribution under the applicable license
terms.

Use:

```sh
git commit -s
```

This adds a line such as:

```text
Signed-off-by: Your Name <your.email@example.org>
```

Contributions without a valid sign-off may be rejected.

## Licensing of contributions

By submitting a signed-off contribution, you agree that your contribution may be distributed
under the licensing terms applicable to the files you modify. Code contributions to files
licensed under `EUPL-1.2+` must be contributed under `EUPL-1.2+`, unless the file-level
SPDX metadata clearly states a different applicable license.

New Julia source files should normally use:

```julia
# SPDX-FileCopyrightText: <YEAR> <YOUR NAME>
# SPDX-License-Identifier: EUPL-1.2+
```

Documentation files are generally licensed under `CC-BY-SA-4.0`, unless stated
otherwise by file-level SPDX metadata. Project tooling, configuration files,
templates, and other project infrastructure files may be licensed under `0BSD`,
where appropriate.

Do not edit the root `LICENSE` file or the `[reuse_licensing]` table in
`Project.toml` by hand unless the change is specifically about package-level
licensing. Package-level declarations should be changed with ReuseLicensing
tooling so that `LICENSE` and `Project.toml` remain coherent.

When modifying existing files, follow the existing licensing domain of the file.

## REUSE compliance

This project follows the [REUSE specification](https://reuse.software/spec/). All new
files must include appropriate SPDX licensing information, either as file headers or, where
necessary, through `.license` sidecar files or `REUSE.toml`.

Do not add files with unclear or missing copyright or licensing information.

## Julia collaboration and code style

This project draws on selected Julia community practices where they fit a
controlled early-stage project. In particular, contributors should keep pull
requests small and focused, add or update tests for code changes, and update
public documentation when changing public APIs.

Pull requests that only reformat code should not also change functionality.
Conversely, functional changes should avoid unrelated formatting churn. Julia code should
follow the formatting configuration used in this repository. The intended style follows the
[SciML Style Guide for Julia](https://docs.sciml.ai/SciMLStyle/) and is enforced via
JuliaFormatter.jl using `style = "sciml"`.

## Assets and third-party material

Third-party assets, including logos, images, diagrams, screenshots, and other
media files, must only be added if their source, author or copyright holder,
license, and modification status are known.

Human-readable attribution should also be added to the relevant attribution file,
for example:

```text
docs/src/assets/ATTRIBUTION.md
```

Do not add third-party material under assumptions such as "probably free to use"
or "found online".

## Maintainer discretion

The maintainer may decline contributions even if they are technically correct,
for example if they increase maintenance burden, complicate licensing, broaden the
scope too early, or conflict with the intended architecture of the package.
