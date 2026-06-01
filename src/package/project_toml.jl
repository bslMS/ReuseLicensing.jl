# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

# Validate and parse `Project.toml`.
function read_package_project(root::AbstractString)
    project_file = joinpath(root, "Project.toml")
    isfile(project_file) || throw(ArgumentError(
        "There must be a `Project.toml` in `$root`."
    ))

    project = TOML.parsefile(project_file)

    haskey(project, "name") || throw(ArgumentError(
        "`Project.toml` in `$root` must define `name`."
    ))

    haskey(project, "uuid") || throw(ArgumentError(
        "`Project.toml` in `$root` must define `uuid`."
    ))

    name = project["name"]
    uuid = project["uuid"]

    name isa AbstractString &&
        !isempty(strip(name)) || throw(ArgumentError(
        "`Project.toml` in `$root` must define non-empty string `name`."
    ))

    uuid isa AbstractString &&
        !isempty(strip(uuid)) || throw(ArgumentError(
        "`Project.toml` in `$root` must define non-empty string `uuid`."
    ))

    return project
end

# Read [reuse_licensing] metadata from Project.toml
function read_reuse_licensing_metadata(project::AbstractDict, root::AbstractString)
    metadata = get(project, "reuse_licensing", nothing)
    metadata isa AbstractDict || throw(ArgumentError(
        "`Project.toml` in `$root` must contain `[reuse_licensing]` metadata."
    ))
    return metadata
end

# Validate [reuse_licensing] metadata.
function is_valid_reuse_licensing_metadata(
        metadata::AbstractDict, root::AbstractString)
    required = (
        "reuse_specification_version",
        "spdx_license_list_version",
        "package_license_expression",
        "package_copyright_notice",
        "package_license_file"
    )

    for key in required
        value = get(metadata, key, nothing)
        value isa AbstractString && !isempty(strip(value)) || throw(ArgumentError(
            "`[reuse_licensing]` in `$root/Project.toml` must define non-empty " *
            "string `$key`."
        ))
    end
    metadata["package_license_file"] == PACKAGE_LICENSE_FILE || throw(ArgumentError(
        "`[reuse_licensing].package_license_file` in `$root/Project.toml` " *
        "must be `$(PACKAGE_LICENSE_FILE)`."
    ))
    return true
end

function render_template(template::AbstractString, values)
    rendered = template
    for (key, value) in pairs(values)
        rendered = replace(rendered, "{{{$(string(key))}}}" => string(value))
    end

    unresolved = match(r"\{\{\{[A-Z0-9_]+\}\}\}", rendered)
    unresolved === nothing || throw(ArgumentError(
        "Unresolved template placeholder: $(unresolved.match)"
    ))

    return rendered
end

function project_toml_metadata_template_path()
    return normpath(joinpath(
        @__DIR__,
        "..",
        "..",
        "templates",
        "Project.toml.metadata.mustache"
    ))
end

function render_project_toml_metadata(
        package_license_expression::AbstractString,
        copyright_notice::AbstractString
)
    template = read(project_toml_metadata_template_path(), String)
    rendered = render_template(template,
        (
            REUSE_SPECIFICATION_VERSION = REUSE_SPECIFICATION_VERSION,
            SPDX_LICENSE_LIST_VERSION = spdx_license_list_version(),
            PACKAGE_LICENSE = package_license_expression,
            COPYRIGHT_NOTICE = copyright_notice
        ))

    # Validate that the rendered section is TOML.
    TOML.parse(rendered)

    return rendered
end

function replace_reuse_licensing_section(
        project_text::AbstractString,
        rendered_metadata::AbstractString
)
    pattern = r"(?ms)^\[reuse_licensing\]\n.*?(?=^\[|\z)"
    occursin(pattern, project_text) || throw(ArgumentError(
        "`Project.toml` must contain `[reuse_licensing]` metadata."
    ))

    updated_text = replace(
        project_text,
        pattern => chomp(rendered_metadata) * "\n";
        count = 1
    )

    # Validate that the edited file is still TOML.
    TOML.parse(updated_text)

    return updated_text
end
