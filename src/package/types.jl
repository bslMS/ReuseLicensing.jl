# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

const PACKAGE_LICENSE_FILE = "LICENSE"
const LICENSING_EVIDENCE_DIRECTORY = ".licensing"
const MANIFEST_SNAPSHOT_DIRECTORY = joinpath(LICENSING_EVIDENCE_DIRECTORY, "manifests")

const AMBIGUOUS_PACKAGE_LICENSE_FILE_ALTERNATIVES = (
    "LICENSE.txt",
    "LICENSE.md",
    "COPYING",
    "COPYING.txt",
    "COPYING.md",
    "COPYRIGHT",
    "COPYRIGHT.txt"
)

struct PackageLicenseSetup
    root::String
    project_file::String
    project::Dict{String, Any}
    license_file_path::String
    parsed::ParsedSPDXExpression
end
