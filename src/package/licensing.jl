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

"""
    check_package_licensing(root; license_policy = ValidSPDX(), multiprocessing = true)

Check package-level licensing metadata and return a `PackageLicensingCheck`.

The check is non-mutating. It validates the Julia package metadata, the
`[reuse_licensing]` table in `Project.toml`, the package-level `LICENSE`
preamble, ambiguous root license-file names, the recorded package license
expression under `license_policy`, and repository-level REUSE compliance.

Use [`is_ok`](@ref) on the returned value to test whether no issues were found.

# Keyword Arguments

- `license_policy`: Approval policy used to check the recorded package license
  expression.
- `multiprocessing`: Whether the external `reuse` tool may use multiprocessing
  while checking repository-level REUSE compliance.
"""
function check_package_licensing(
        root::AbstractString;
        license_policy::AbstractExpressionApprovalPolicy = ValidSPDX(),
        multiprocessing = true
)
    issues = PackageLicensingIssue[]
    metadata = nothing
    metadata_valid = false

    project = try
        read_package_project(root)
    catch err
        push!(issues, issue(:project_toml, err))
        nothing
    end

    if project !== nothing
        metadata = try
            read_reuse_licensing_metadata(project, root)
        catch err
            push!(issues, issue(:metadata_missing, err))
            nothing
        end

        if metadata !== nothing
            try
                is_valid_reuse_licensing_metadata(metadata, root)
                metadata_valid = true
            catch err
                push!(issues, issue(:metadata_invalid, err))
            end
        end
    end

    if metadata_valid
        package_license = metadata["package_license_expression"]
        # Safe to use required metadata fields here.
        try
            parsed = parse_spdx_expression(package_license; legacy = :error)
            has_approved_license_path(parsed, license_policy) || push!(issues,
                issue(
                    :package_license_not_approved,
                    "`[reuse_licensing].package_license_expression` is " *
                    "not approved by `$(typeof(license_policy))`."
                ))
        catch err
            push!(issues, issue(:package_license_invalid, err))
        end

        try
            license_preamble_matches_metadata(
                joinpath(root, PACKAGE_LICENSE_FILE), metadata)
        catch err
            push!(issues, issue(:license_mismatch, err))
        end
    end

    for f in AMBIGUOUS_PACKAGE_LICENSE_FILE_ALTERNATIVES
        if isfile(joinpath(root, f))
            push!(issues, issue(:ambiguous_license_file, "Found `$f`."))
        end
    end

    try
        is_reuse_compliant(; root, multiprocessing) || push!(
            issues, issue(:reuse_noncompliant,
                "Project in `$root` is not REUSE-compliant. Run `reuse lint -l` for errors."
            ))
    catch err
        push!(issues, issue(:reuse_tool, err))
    end

    return PackageLicensingCheck(root, issues)
end

"""
    set_package_license!(root, package_license; license_policy = ValidSPDX(),
                         force = false, multiprocessing = true)

Set the package-level license expression for an already adopted package.

The function validates the package licensing setup, preserves the existing
package copyright notice, writes updated `[reuse_licensing]` metadata to
`Project.toml`, and renders the package-level `LICENSE` file.

# Keyword Arguments

- `license_policy::AbstractExpressionApprovalPolicy`: Approval policy used to check
  the new package license expression before writing metadata.
- `license_ref_dir::Union{AbstractString, Nothing}`: Optional directory containing
  user-supplied license texts for `LicenseRef-...` identifiers.
- `multiprocessing::Bool`: Whether the external `reuse` tool may use multiprocessing
  while checking repository-level REUSE compliance. Defaults to `true`.
"""
function set_package_license!(
        root::AbstractString,
        package_license::AbstractString;
        license_policy::AbstractExpressionApprovalPolicy = ValidSPDX(),
        license_ref_dir::Union{AbstractString, Nothing} = nothing,
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

    # Update the metadata in Project.toml.
    updated_metadata = package_licensing_metadata(
        package_license_expression = setup.parsed.expression,
        package_copyright_notice = metadata["package_copyright_notice"]
    )

    # We are all set to write `LICENSE` with force.
    license_text = render_package_license_file(updated_metadata, setup.parsed;
        license_ref_dir
    )

    write_project_toml_metadata!(setup.project_file, updated_metadata)
    write(setup.license_file_path, license_text)

    return (
        project_file = setup.project_file,
        license_file = setup.license_file_path,
        package_license_expression = setup.parsed.expression
    )
end

function join_copyright_holders(holders::Vector{String})
    length(holders) == 1 && return holders[1]
    length(holders) == 2 && return holders[1] * " and " * holders[2]
    return join(holders[1:(end - 1)], ", ") * ", and " * holders[end]
end

# Construct copyright notice without trying to dive into full copyright semantics.
function copyright_notice(
        year::AbstractString,
        copyright_holders::Vector{<:AbstractString}
)
    year = strip(year)
    occursin(r"\d{4}", year) || throw(ArgumentError(
        "`year` must contain at least one four-digit year."
    ))

    holders = strip.(copyright_holders)
    isempty(holders) && throw(ArgumentError(
        "`copyright_holders` must not be empty."
    ))
    any(isempty, holders) && throw(ArgumentError(
        "`copyright_holders` must not contain empty entries."
    ))

    return "Copyright © $year " * join_copyright_holders(String.(holders))
end

"""
    adopt_package_licensing!(root; package_license, year, copyright_holders,
                             license_policy = ValidSPDX(),
                             license_ref_dir = nothing,
                             force = false,
                             multiprocessing = true)

Adopt package-level licensing metadata and canonical package-level `LICENSE` for
an already REUSE-compliant Julia package.

The function first checks that the package is REUSE-compliant. It then requires
that `Project.toml` does not yet contain `[reuse_licensing]` metadata,
constructs a package copyright notice from `year` and `copyright_holders`,
appends canonical `[reuse_licensing]` metadata to `Project.toml`, and renders
the canonical package-level `LICENSE` file.

If `LICENSE` already exists, the function throws unless `force = true`.

# Keyword Arguments

- `package_license::AbstractString`: Package-level outbound SPDX license
  expression to record in `Project.toml` and render into `LICENSE`.
- `year::AbstractString`: Copyright year string. It must contain at least one
  four-digit year.
- `copyright_holders::Vector{<:AbstractString}`: Copyright holders used to
  construct the package copyright notice.
- `license_policy::AbstractExpressionApprovalPolicy`: Approval policy used to
  check the package license expression before writing metadata.
- `license_ref_dir::Union{AbstractString, Nothing}`: Optional directory
  containing user-supplied license texts for `LicenseRef-...` identifiers.
- `force::Bool`: Allow replacing an existing root `LICENSE` file. Defaults to
  `false`.
- `multiprocessing::Bool`: Whether the external `reuse` tool may use
  multiprocessing while checking repository-level REUSE compliance. Defaults to
  `true`.
"""
function adopt_package_licensing!(
        root::AbstractString;
        package_license::AbstractString,
        year::AbstractString,
        copyright_holders::Vector{<:AbstractString},
        license_policy::AbstractExpressionApprovalPolicy = ValidSPDX(),
        license_ref_dir::Union{AbstractString, Nothing} = nothing,
        force::Bool = false,
        multiprocessing::Bool = true
)
    setup = check_package_license_setup(
        root,
        package_license;
        license_policy,
        multiprocessing
    )

    isfile(setup.license_file_path) && !force &&
        throw(ArgumentError(
            "Found existing `LICENSE`. Pass `force = true`."
        ))

    assert_no_reuse_licensing_metadata(setup.project, root)
    notice = copyright_notice(year, copyright_holders)
    metadata = package_licensing_metadata(;
        package_license_expression = setup.parsed.expression,
        package_copyright_notice = notice)

    license_text = render_package_license_file(metadata, setup.parsed; license_ref_dir)

    add_project_toml_metadata!(setup.project_file, metadata)
    write(setup.license_file_path, license_text)
    return (
        project_file = setup.project_file,
        license_file = setup.license_file_path,
        package_license_expression = setup.parsed.expression
    )
end

# function set_package_copyright!(root; year, copyright_holders)

# function repair_package_licensing!(root; ...)
