<!--
SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Contributing

Bug reports, failing test cases, documentation fixes, and small improvements are welcome.
Please discuss larger changes or new APIs in an issue first. The maintainer may decline
changes outside the project’s scope or that add too much maintenance work.

## Commit sign-off

Sign off every commit using the Developer Certificate of Origin (DCO):

```sh
git commit -s
```

This adds `Signed-off-by: Your Name <your.email@example.org>` to the commit
message and certifies your right to submit the contribution under the
applicable license.

## Licensing and REUSE

Contribute under the license of the file you modify. Julia source files
normally use `EUPL-1.2+`, documentation uses `CC-BY-SA-4.0`, and project
infrastructure uses `0BSD`. Follow the file's SPDX metadata where it differs.

New Julia source files should normally include:

```julia
# SPDX-FileCopyrightText: <YEAR> <YOUR NAME>
# SPDX-License-Identifier: EUPL-1.2+
```

All new files need copyright and license information through SPDX headers,
`.license` sidecars, or `REUSE.toml`, following the
[REUSE specification](https://reuse.software/spec/).

Keep shipped templates under `templates/*.mustache` covered by `REUSE.toml`.

Unless you are changing package-level licensing, leave the root `LICENSE`
and `[reuse_licensing]` table in `Project.toml` alone. Use ReuseLicensing tooling for
package-level licensing changes so these declarations stay consistent.

## Code and tests

Add or update tests for code changes and documentation for changes to public
behavior. Keep unrelated formatting changes out of functional pull requests.

Use the repository's SciML formatting settings: `.JuliaFormatter.toml` for
JuliaFormatter.jl and `JuliaFormat.toml` for the Julia VS Code extension.

## Documentation

Sources are in `docs/src/`; API documentation comes from Julia docstrings.

### Build locally

From the repository root:

```sh
julia --project=docs docs/make.jl
```

The script prepares the environment and builds HTML in `docs/build/`.
No deployment credentials are needed. Do not commit the generated files.

To preview:

```sh
python3 -m http.server 8000 --bind localhost --directory docs/build
```

Open <http://localhost:8000/>. Rebuild after edits and refresh the browser.
Stop the server with Ctrl+C.

### Publishing

GitHub Actions builds documentation for pull requests. Branches in this
repository also get previews at:

`https://bslms.github.io/ReuseLicensing.jl/previews/PR<number>/`

Fork pull requests are built without published previews. Contributors need
no SSH access or deployment credentials.

Pushes to `main` publish `/dev/`. Release tags matching `v*` publish versioned
documentation, with `/stable/` pointing to the latest release.

Closing or merging a PR removes its preview from `gh-pages`; the website
reflects the removal on the next Pages deployment.

### Maintainer setup

Configure GitHub Pages to serve `gh-pages` from `/ (root)`. Publishing uses
a write-enabled SSH deploy key stored as the `DOCUMENTER_KEY` Actions secret,
plus the automatically provided `GITHUB_TOKEN`. Never commit credentials.

The workflows are `.github/workflows/documentation.yml` and
`.github/workflows/doc-preview-cleanup.yml`.

## Third-party material

Record the source, copyright holder, license, and any modifications for
third-party images and other assets. Include readable attribution where
appropriate, for example in `docs/src/assets/ATTRIBUTION.md`.
