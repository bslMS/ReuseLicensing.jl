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

struct PackageLicensingIssue
    code::Symbol
    message::String
end

struct PackageLicensingCheck
    root::String
    issues::Vector{PackageLicensingIssue}
end

issue(code::Symbol, err) = PackageLicensingIssue(code, sprint(showerror, err))
issue(code::Symbol, message::AbstractString) = PackageLicensingIssue(code, String(message))

is_ok(check::PackageLicensingCheck) = isempty(check.issues)

normalize_line_endings(text::AbstractString) = replace(replace(text, "\r\n" => "\n"), "\r" => "\n")
