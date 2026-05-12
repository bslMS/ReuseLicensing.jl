#!/usr/bin/env julia
# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# Maintainer-only script to refresh the vendored SPDX license-list snapshot.

using Dates: Dates
using CodecZlib: GzipDecompressorStream
using Downloads: Downloads
using JSON: JSON
using SHA: sha256
using Tar: Tar
using TOML: TOML

# GitHub's API is only needed to resolve `--latest` to a concrete release tag.
const SPDX_API_REPO = "https://api.github.com/repos/spdx/license-list-data"

const REPO_ROOT = normpath(joinpath(@__DIR__, ".."))
const DATA_DIR = joinpath(REPO_ROOT, "data", "spdx-license-list-data")
const TEXT_DIR = joinpath(DATA_DIR, "text")
const GENERATED_DIR = joinpath(REPO_ROOT, "src", "spdx", "generated")
const GENERATED_SNAPSHOT_PATH = joinpath(GENERATED_DIR, "snapshot.jl")
const SNAPSHOT_PATH = joinpath(DATA_DIR, "SNAPSHOT.toml")
const METADATA_HEADER = """
# This file is primarily maintained by scripts/update_spdx_snapshot.jl
# Manual edits may be overwritten.
"""

function parse_args(args::Vector{String})
    selector = nothing
    force = false
    for arg in args
        if arg == "--latest"
            selector === nothing ||
                error("Only one of --latest, --version, or --ref may be given")
            selector = (; kind=:latest, value=nothing)
        elseif startswith(arg, "--version=")
            selector === nothing ||
                error("Only one of --latest, --version, or --ref may be given")
            selector = (; kind=:version, value=split(arg, '='; limit=2)[2])
        elseif startswith(arg, "--ref=")
            selector === nothing ||
                error("Only one of --latest, --version, or --ref may be given")
            selector = (; kind=:ref, value=split(arg, '='; limit=2)[2])
        elseif arg in ("-f", "--force")
            force = true
        elseif arg in ("-h", "--help")
            print_usage()
            exit(0)
        else
            error("Unknown argument: $arg")
        end
    end
    selector === nothing && (selector = (; kind=:latest, value=nothing))
    return (; selector, force)
end

function print_usage()
    return println("""
           Usage: julia --project=scripts scripts/update_spdx_snapshot.jl
                  [--latest | --version=<version> | --ref=<git-ref>] [--force]

           Refresh vendored SPDX JSON summaries, license texts, and generated
           Julia lookup constants from `spdx/license-list-data`.

           At most one selector may be given. If no selector is provided, `--latest`
           is used. `--version=<ver>` resolves to tag `v<ver>` unless the `v` prefix
           is already present.

           Options:
             --latest          Fetch the latest SPDX release tag (default)
             --version=<ver>   Fetch SPDX release tag `v<ver>` or the exact tag given
             --ref=<git-ref>   Fetch from an explicit Git ref or tag
             -f, --force       Refresh even if the selected ref matches local metadata
             -h, --help        Show this message
           """)
end

tarball_url(ref::AbstractString) = "$SPDX_API_REPO/tarball/$ref"

function fetch_json(url::AbstractString)
    path = Downloads.download(url)
    return JSON.parse(read(path, String))
end

function latest_release_ref()
    release = fetch_json("$SPDX_API_REPO/releases/latest")
    return String(release.tag_name)
end

function version_ref(version::AbstractString)
    # SPDX release tags are prefixed with `v`, but accept the bare version too.
    return startswith(version, 'v') ? version : "v$version"
end

function resolve_ref(selector)
    selector.kind == :latest && return latest_release_ref()
    selector.kind == :version && return version_ref(selector.value)
    selector.kind == :ref && return selector.value
    return error("Unsupported selector kind: $(selector.kind)")
end

function current_snapshot()
    path = joinpath(DATA_DIR, "SNAPSHOT.toml")
    isfile(path) || return nothing
    return TOML.parsefile(path)
end

function extracted_repo_dir(parent::AbstractString)
    entries = filter(name -> isdir(joinpath(parent, name)), readdir(parent))
    length(entries) == 1 || error("Expected one extracted repository directory in $parent")
    return joinpath(parent, only(entries))
end

function resolve_commit(ref::AbstractString)
    ref_info = fetch_json("$SPDX_API_REPO/commits/$ref")
    return String(ref_info.sha)
end

function snapshot_hashes(root::AbstractString)
    paths = String[]
    for (dir, _, files) in walkdir(root)
        for file in files
            file == "SNAPSHOT.toml" && continue
            path = joinpath(dir, file)
            rel = relpath(path, root)
            push!(paths, replace(rel, '\\' => '/'))
        end
    end
    sort!(paths)

    hashes = Dict{String,String}()
    for rel in paths
        path = joinpath(root, split(rel, '/')...)
        hashes[rel] = "sha256:" * bytes2hex(sha256(read(path)))
    end
    return hashes
end

function write_snapshot_metadata(
    path::AbstractString;
    ref::AbstractString,
    commit::AbstractString,
    version::AbstractString,
    hashes::Dict{String,String},
)
    open(path, "w") do io
        print(io, METADATA_HEADER)
        println(io, "schema_version = 1")
        println(
            io,
            "generated_at = ",
            repr(Dates.format(Dates.now(Dates.UTC), Dates.dateformat"yyyy-mm-ddTHH:MM:SSZ")),
        )
        println(io)
        println(io, "[source]")
        println(io, "repository = ", repr("https://github.com/spdx/license-list-data"))
        println(io, "source_ref = ", repr(ref))
        println(io, "commit = ", repr(commit))
        println(io, "generated_from = ", repr("https://github.com/spdx/license-list-XML"))
        println(io, "spdx_license_list_version = ", repr(version))
        println(io, "tarball_url = ", repr(tarball_url(ref)))
        println(io)
        println(io, "[hashes]")
        println(io, "algorithm = ", repr("sha256"))
        println(io)
        println(io, "[hashes.files]")
        for file in sort(collect(keys(hashes)))
            println(io, repr(file), " = ", repr(hashes[file]))
        end
    end
end

function spdx_text_ids(licenses_json, exceptions_json)
    ids = String[]
    append!(ids, String.(getproperty.(licenses_json.licenses, :licenseId)))
    append!(ids, String.(getproperty.(exceptions_json.exceptions, :licenseExceptionId)))
    sort!(unique!(ids))
    return ids
end

function spdx_text_source(text_dir::AbstractString, id::AbstractString)
    path = joinpath(text_dir, "$id.txt")
    isfile(path) && return path

    deprecated_path = joinpath(text_dir, "deprecated_$id.txt")
    isfile(deprecated_path) && return deprecated_path

    return nothing
end

function write_string_dict(io::IO, name::AbstractString, values::Vector{String})
    println(io, "const ", name, " = Dict{String,String}(")
    for value in values
        println(io, "    ", repr(lowercase(value)), " => ", repr(value), ",")
    end
    println(io, ")")
    return nothing
end

function write_license_info_dict(io::IO, name::AbstractString, licenses)
    println(io, "const ", name, " = Dict{String,SPDXLicenseInfo}(")
    for license in licenses
        id = String(license.licenseId)
        is_osi_approved = Bool(license.isOsiApproved)
        is_fsf_libre = hasproperty(license, :isFsfLibre) ? Bool(license.isFsfLibre) : false
        println(
            io,
            "    ",
            repr(lowercase(id)),
            " => SPDXLicenseInfo(",
            repr(id),
            ", ",
            is_osi_approved,
            ", ",
            is_fsf_libre,
            "),",
        )
    end
    println(io, ")")
    return nothing
end

function write_generated_snapshot(
    path::AbstractString,
    licenses_json,
    exceptions_json,
    ref::AbstractString,
)
    licenses = []
    deprecated_license_ids = String[]
    for license in licenses_json.licenses
        id = String(license.licenseId)
        if Bool(license.isDeprecatedLicenseId)
            push!(deprecated_license_ids, id)
        else
            push!(licenses, license)
        end
    end
    sort!(licenses; by=license -> String(license.licenseId))
    sort!(deprecated_license_ids)

    exception_ids = String[]
    deprecated_exception_ids = String[]
    for exception in exceptions_json.exceptions
        id = String(exception.licenseExceptionId)
        if Bool(exception.isDeprecatedLicenseId)
            push!(deprecated_exception_ids, id)
        else
            push!(exception_ids, id)
        end
    end
    sort!(exception_ids)
    sort!(deprecated_exception_ids)

    open(path, "w") do io
        print(io, METADATA_HEADER)
        println(io, "# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>")
        println(io, "# SPDX-License-", "Identifier: CC0-1.0")
        println(io)
        println(io, "# Generated from https://github.com/spdx/license-list-data at ref ", repr(ref), ".")
        println(io, "# SPDX license list version: ", repr(String(licenses_json.licenseListVersion)))
        println(io)
        println(io, "const SPDX_LICENSE_LIST_VERSION = ", repr(String(licenses_json.licenseListVersion)))
        println(io)
        write_license_info_dict(io, "SPDX_LICENSES", licenses)
        println(io)
        write_string_dict(io, "SPDX_DEPRECATED_LICENSES", deprecated_license_ids)
        println(io)
        write_string_dict(io, "SPDX_LICENSE_EXCEPTIONS", exception_ids)
        println(io)
        write_string_dict(io, "SPDX_DEPRECATED_LICENSE_EXCEPTIONS", deprecated_exception_ids)
    end
    return nothing
end

function update_snapshot(; ref::AbstractString, commit::AbstractString)
    mktempdir() do tmp
        # Build the refreshed snapshot in a temp dir first so local data is
        # only replaced after download, extraction, and writes succeed.
        tarball_path = Downloads.download(tarball_url(ref))
        extract_dir = joinpath(tmp, "extract")
        staged_data_dir = joinpath(tmp, "spdx-license-data")
        staged_generated_dir = joinpath(tmp, "generated")
        mkpath(extract_dir)
        mkpath(staged_data_dir)
        mkpath(staged_generated_dir)

        open(tarball_path) do io
            Tar.extract(GzipDecompressorStream(io), extract_dir)
        end

        repo_dir = extracted_repo_dir(extract_dir)
        licenses_src = joinpath(repo_dir, "json", "licenses.json")
        exceptions_src = joinpath(repo_dir, "json", "exceptions.json")
        text_src = joinpath(repo_dir, "text")
        staged_text_dir = joinpath(staged_data_dir, "text")

        licenses_json = JSON.parse(read(licenses_src, String))
        exceptions_json = JSON.parse(read(exceptions_src, String))
        ids = spdx_text_ids(licenses_json, exceptions_json)
        text_paths = Dict{String,String}()
        for id in ids
            path = spdx_text_source(text_src, id)
            path === nothing &&
                error("Missing SPDX text file for identifier $id in tarball for ref $ref")
            text_paths[id] = path
        end

        cp(licenses_src, joinpath(staged_data_dir, "licenses.json"); force=true)
        cp(exceptions_src, joinpath(staged_data_dir, "exceptions.json"); force=true)
        write_generated_snapshot(
            joinpath(staged_generated_dir, "snapshot.jl"),
            licenses_json,
            exceptions_json,
            ref,
        )
        mkpath(staged_text_dir)
        for (id, path) in text_paths
            cp(path, joinpath(staged_text_dir, "$id.txt"); force=true)
        end

        write_snapshot_metadata(
            joinpath(staged_data_dir, "SNAPSHOT.toml");
            ref,
            commit,
            version=String(licenses_json.licenseListVersion),
            hashes=snapshot_hashes(staged_data_dir),
        )

        rm(DATA_DIR; recursive=true, force=true)
        rm(GENERATED_DIR; recursive=true, force=true)
        mkpath(dirname(DATA_DIR))
        mkpath(dirname(GENERATED_DIR))
        mv(staged_data_dir, DATA_DIR)
        mv(staged_generated_dir, GENERATED_DIR)
    end
end

function cli_main(args::Vector{String})
    opts = parse_args(args)
    ref = resolve_ref(opts.selector)

    commit = resolve_commit(ref)

    snapshot = current_snapshot()
    # Skip the refresh unless explicitly forced when the selected ref already
    # matches the local snapshot metadata.
    source = snapshot === nothing ? nothing : get(snapshot, "source", nothing)
    current_ref = source === nothing ? nothing : get(source, "source_ref", nothing)
    current_commit = source === nothing ? nothing : get(source, "commit", nothing)
    if !opts.force && current_ref == ref && current_commit == commit
        println(
            "SPDX snapshot already at ref $ref ($commit). " *
            "Use --force to refresh $(relpath(DATA_DIR, REPO_ROOT)).",
        )
        return nothing
    end

    update_snapshot(; ref, commit)
    println("Updated SPDX data in $(relpath(DATA_DIR, REPO_ROOT)) from ref $ref ($commit).")
    println("Updated generated snapshot in $(relpath(GENERATED_SNAPSHOT_PATH, REPO_ROOT)).")
    return nothing
end

main(args::AbstractVector{<:AbstractString}) = cli_main(String.(args))
main(arg::AbstractString) = cli_main([String(arg)])

if abspath(PROGRAM_FILE) == @__FILE__
    main(ARGS)
end
