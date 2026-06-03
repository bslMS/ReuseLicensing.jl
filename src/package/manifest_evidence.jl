# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

function licensing_evidence_readme_path()
    return normpath(joinpath(@__DIR__, "..", "..", ".licensing", "README.md"))
end

function normalized_manifest_profile_components(profile::Nothing)
    return String[]
end

function normalized_manifest_profile_components(profile::AbstractString)
    normalized = lowercase(strip(profile))
    isempty(normalized) && throw(ArgumentError(
        "`profile` must not be empty."
    ))

    normalized = replace(normalized, r"[\s_]+" => "-")
    components = split(normalized, '/')

    for component in components
        isempty(component) && throw(ArgumentError(
            "`profile` must not contain empty path components."
        ))
        component in (".", "..") && throw(ArgumentError(
            "`profile` must not contain `.` or `..` path components."
        ))
        startswith(component, ".") && throw(ArgumentError(
            "`profile` path components must not start with `.`."
        ))
        occursin(r"^[a-z0-9][a-z0-9.-]*$", component) || throw(ArgumentError(
            "`profile` path components may only contain lowercase ASCII " *
            "letters, digits, `.`, and `-`, and must start with a letter or digit."
        ))
    end

    return String.(components)
end

"""
    record_manifest_evidence!(root; profile = nothing, force = false, readme = false)

Copy `Manifest.toml` from `root` to the release-scoped licensing evidence
directory `.licensing/manifests/vX.Y.Z/`, where `X.Y.Z` is read from
`Project.toml`.

The destination filename is derived from the current Julia host triplet. The
function verifies that the manifest's recorded `julia_version` matches the Julia
version running this process. If `profile` is provided, it is normalized to
lowercase filename-safe path components below the version directory. Existing
evidence files are not overwritten unless `force = true`. If `readme = true`,
the function also creates `.licensing/README.md` when it does not already exist.

Returns the destination path.
"""
function record_manifest_evidence!(
        root::AbstractString;
        profile::Union{AbstractString, Nothing} = nothing,
        force::Bool = false,
        readme::Bool = false
)
    project = read_package_project(root)
    version = get(project, "version", nothing)
    version isa AbstractString && !isempty(strip(version)) || throw(ArgumentError(
        "`Project.toml` in `$root` must define non-empty string `version`."
    ))

    manifest_file = joinpath(root, "Manifest.toml")
    isfile(manifest_file) || throw(ArgumentError(
        "There must be a `Manifest.toml` in `$root`."
    ))

    manifest = TOML.parsefile(manifest_file)
    manifest_julia_version = get(manifest, "julia_version", nothing)
    manifest_julia_version == string(VERSION) || throw(ArgumentError(
        "`Manifest.toml` was generated with Julia `$manifest_julia_version`, " *
        "but this process is running Julia `$(VERSION)`."
    ))

    filename = replace(Base.BinaryPlatforms.host_triplet(), r"_version\+" => "-") * ".toml"
    profile_components = normalized_manifest_profile_components(profile)
    dest_dir = joinpath(
        root,
        MANIFEST_SNAPSHOT_DIRECTORY,
        "v$version",
        profile_components...
    )
    dest = joinpath(dest_dir, filename)

    isfile(dest) && !force &&
        throw(ArgumentError(
            "`$dest` already exists. Pass `force = true` to overwrite it."
        ))

    mkpath(dest_dir)
    cp(manifest_file, dest; force)

    if readme
        licensing_dir = joinpath(root, LICENSING_EVIDENCE_DIRECTORY)
        readme_dest = joinpath(licensing_dir, "README.md")
        if !isfile(readme_dest)
            mkpath(licensing_dir)
            cp(licensing_evidence_readme_path(), readme_dest)
        end
    end

    return dest
end
