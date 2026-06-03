# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# Validate LICENSE against metadata.
function license_preamble_matches_metadata(
        license_file_path::AbstractString,
        metadata::AbstractDict
)
    isfile(license_file_path) || throw(ArgumentError(
        "`$license_file_path` does not exist."
    ))

    text = replace(read(license_file_path, String), "\r\n" => "\n")
    lines = split(text, '\n')
    length(lines) >= 6 || throw(ArgumentError(
        "`$license_file_path` does not contain the expected package-license preamble."
    ))

    copyright_notice = metadata["package_copyright_notice"]
    package_license = metadata["package_license_expression"]

    startswith(text, copyright_notice * "\n\n") || throw(ArgumentError(
        "`LICENSE` does not start with `[reuse_licensing].package_copyright_notice` " *
        "followed by a blank line."
    ))

    first_lines = join(lines[1:min(end, 10)], "\n")
    occursin(package_license, first_lines) || throw(ArgumentError(
        "`LICENSE` preamble does not match `[reuse_licensing].package_license_expression`."
    ))

    return true
end

# Replace only the managed package copyright notice line in canonical LICENSE text.
function replace_license_copyright_notice_text(
        text::AbstractString,
        old_notice::AbstractString,
        new_notice::AbstractString
)
    prefix = old_notice * "\n\n"
    startswith(text, prefix) || throw(ArgumentError(
        "`LICENSE` does not start with the expected package copyright notice " *
        "followed by a blank line."
    ))

    return new_notice * "\n\n" * text[(lastindex(prefix) + 1):end]
end

# Replace only the managed package copyright notice line in LICENSE.
function replace_license_copyright_notice!(
        license_file_path::AbstractString,
        old_notice::AbstractString,
        new_notice::AbstractString
)
    text = replace(read(license_file_path, String), "\r\n" => "\n")
    updated_text = replace_license_copyright_notice_text(text, old_notice, new_notice)
    write(license_file_path, updated_text)
    return license_file_path
end

# Locate the canonical LICENSE template shipped with the package.
function license_template_path()
    return normpath(joinpath(
        @__DIR__,
        "..",
        "..",
        "templates",
        "LICENSE.mustache"
    ))
end

# Return lowercase LicenseRef payloads mapped to their text files.
function licenseref_files(dir::AbstractString)
    isdir(dir) || throw(ArgumentError(
        "Directory `$dir` for LicenseRef text files does not exist."
    ))

    files = Dict{String, String}()
    prefix = "LicenseRef-"
    suffix = ".txt"

    for filename in readdir(dir)
        startswith(filename, prefix) || continue
        endswith(filename, suffix) || continue

        payload = filename[(length(prefix) + 1):(end - length(suffix))]
        isempty(payload) && throw(ArgumentError(
            "`$filename` does not contain a LicenseRef identifier payload."
        ))

        key = lowercase(payload)
        path = joinpath(dir, filename)

        haskey(files, key) && throw(ArgumentError(
            "Multiple LicenseRef text files in `$dir` match `LicenseRef-$payload`."
        ))

        files[key] = path
    end
    return files
end

# Render the LICENSE file from template and license texts.
function render_package_license_file(
        metadata::AbstractDict,
        parsed::ParsedSPDXExpression;
        template_path::AbstractString = license_template_path(),
        license_ref_dir::Union{AbstractString, Nothing} = nothing
)
    template = read(template_path, String)

    preamble = render_template(template,
        (
            COPYRIGHT_NOTICE = metadata["package_copyright_notice"],
            PACKAGE_LICENSE = metadata["package_license_expression"])
    )

    license_parts = String[preamble]

    for id in sort(collect(parsed.licenses))
        license_text = spdx_license_text(id)
        license_text === nothing &&
            throw(ArgumentError("Reuse: no SPDX license text found for `$id`"))
        push!(license_parts, license_text)
    end

    for id in sort(collect(parsed.exceptions))
        exception_text = spdx_license_exception_text(id)
        exception_text === nothing &&
            throw(ArgumentError("Reuse: no SPDX license exception text found for `$id`"))
        push!(license_parts, exception_text)
    end

    files = if isempty(parsed.licenserefs)
        nothing
    else
        license_ref_dir === nothing && throw(ArgumentError(
            "`license_ref_dir` is required when the package license expression " *
            "contains LicenseRef-Identifiers."
        ))
        licenseref_files(license_ref_dir)
    end

    for id in sort(collect(parsed.licenserefs))
        haskey(files, id) || throw(ArgumentError(
            "No license file provided for `LicenseRef-$id`."
        ))
        src = files[id]
        push!(license_parts, read(src, String))
    end
    return join(chomp.(license_parts), "\n\n") * "\n"
end
