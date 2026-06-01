# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# Validate package licensing setup and return setup struct.
function check_package_license_setup(
        root::AbstractString,
        package_license::AbstractString;
        license_policy::AbstractExpressionApprovalPolicy,
        multiprocessing::Bool
)
    licenses_dir = joinpath(root, "LICENSES")
    license_file_path = joinpath(root, PACKAGE_LICENSE_FILE)

    # Validate that root exists and has valid Julia package structure.
    isdir(root) || throw(ArgumentError("Package root `$root` is not a directory."))
    project = read_package_project(root)
    isdir(licenses_dir) || throw(ArgumentError(
        "No `LICENSES/` directory found in `$root`."))

    # Validate that the project in root is REUSE-compliant
    is_reuse_compliant(; root, multiprocessing) || throw(ArgumentError(
        "Project in `$root` is not REUSE-compliant. Run `reuse lint -l` for errors."
    ))

    # Validate that no other license file(s) exist.
    for f in AMBIGUOUS_PACKAGE_LICENSE_FILE_ALTERNATIVES
        isfile(joinpath(root, f)) && throw(ArgumentError(
            "Found $f. Please check and possibly remove to avoid ambiguous " *
            "package-license statement."
        ))
    end

    # Parse package_license expression and check approval.
    parsed = parse_spdx_expression(package_license; legacy = :normalize)
    has_approved_license_path(parsed, license_policy) || throw(ArgumentError(
        "Package-license `$package_license` cannot be approved."
    ))
    return PackageLicenseSetup(
        String(root),
        joinpath(root, "Project.toml"),
        project,
        license_file_path,
        parsed
    )
end

# Validate LICENSE against metadata.
function license_preamble_matches_metadata(
        license_file_path::AbstractString,
        metadata::AbstractDict,
)
    isfile(license_file_path) || throw(ArgumentError(
        "`$license_file_path` does not exist."
    ))

    lines = readlines(license_file_path)
    length(lines) >= 6 || throw(ArgumentError(
        "`$license_file_path` does not contain the expected package-license preamble."
    ))

    copyright_notice = metadata["package_copyright_notice"]
    package_license = metadata["package_license_expression"]

    lines[1] == copyright_notice || throw(ArgumentError(
        "First line of `LICENSE` does not match `[reuse_licensing].package_copyright_notice`."
    ))

    first_lines = join(lines[1:min(end, 10)], "\n")
    occursin(package_license, first_lines) || throw(ArgumentError(
        "`LICENSE` preamble does not match `[reuse_licensing].package_license_expression`."
    ))

    return true
end

"""
    set_package_license!(root, package_license; kwargs...)

"""
function set_package_license!(
        root::AbstractString,
        package_license::AbstractString;
        license_policy::AbstractExpressionApprovalPolicy = ValidSPDX(),
        force::Bool = false,
        multiprocessing::Bool = true
)
    setup = check_package_license_setup(
        root,
        package_license;
        license_policy,
        multiprocessing
    )

    # Exit if Project.toml does not contain metadata and LICENSE does not match.
    metadata = read_reuse_licensing_metadata(setup.project, setup.root)
    is_valid_reuse_licensing_metadata(metadata, setup.root)
    license_preamble_matches_metadata(setup.license_file_path, metadata)

    # Update the metadata in Project.toml
    rendered_metadata = render_project_toml_metadata(
        setup.parsed.expression,
        metadata["package_copyright_notice"]
    )
    project_text = read(setup.project_file, String)
    updated_project_text = replace_reuse_licensing_section(project_text, rendered_metadata)

    # We are all set to write `LICENSE` with force.

    return "TO BE IMPLEMENTED"
end

# function set_package_copyright!(root; year, copyright_holders)

# function adopt_pacakge_licensing!(root; pacakge_license, year, copyright_holders, force)

#
