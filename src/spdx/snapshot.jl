# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

_normalize_identifier(identifier::AbstractString) = lowercase(String(identifier))

"""
    spdx_license_list_version()

Return the SPDX License List version used by this package's checked-in snapshot.
"""
spdx_license_list_version() = SPDX_LICENSE_LIST_VERSION

# Return `SPDXLicenseInfo` for a current SPDX license identifier, or `nothing`.
function spdx_license_info(identifier::AbstractString)
    return get(SPDX_LICENSES, _normalize_identifier(identifier), nothing)
end

# Return whether `identifier` is a current SPDX license identifier.
is_spdx_license_id(identifier::AbstractString) = haskey(
    SPDX_LICENSES, _normalize_identifier(identifier))

# Return whether `identifier` is a deprecated SPDX license identifier.
is_deprecated_spdx_license_id(identifier::AbstractString) = haskey(
    SPDX_DEPRECATED_LICENSES, _normalize_identifier(identifier))

"""
    canonical_spdx_license_id(identifier; include_deprecated = false)

Return the canonical spelling for an SPDX license identifier, or `nothing` when
`identifier` is unknown. Deprecated identifiers are only included when
`include_deprecated` is `true`.
"""
function canonical_spdx_license_id(
        identifier::AbstractString; include_deprecated::Bool = false)
    key = _normalize_identifier(identifier)
    info = get(SPDX_LICENSES, key, nothing)
    if info !== nothing
        return info.id
    end
    if include_deprecated
        return get(SPDX_DEPRECATED_LICENSES, key, nothing)
    end
    return nothing
end

"""
    canonical_spdx_license_exception_id(identifier; include_deprecated = false)

Return the canonical spelling for an SPDX license exception identifier, or
`nothing` when `identifier` is unknown.
"""
function canonical_spdx_license_exception_id(
        identifier::AbstractString; include_deprecated::Bool = false)
    key = _normalize_identifier(identifier)
    exception = get(SPDX_LICENSE_EXCEPTIONS, key, nothing)
    if exception !== nothing
        return exception
    end
    if include_deprecated
        return get(SPDX_DEPRECATED_LICENSE_EXCEPTIONS, key, nothing)
    end
    return nothing
end

# Return whether `identifier` is a current SPDX license exception identifier.
is_spdx_license_exception_id(identifier::AbstractString) = haskey(
    SPDX_LICENSE_EXCEPTIONS, _normalize_identifier(identifier))

# Return whether `identifier` is a deprecated SPDX license exception identifier.
is_deprecated_spdx_license_exception_id(identifier::AbstractString) = haskey(
    SPDX_DEPRECATED_LICENSE_EXCEPTIONS, _normalize_identifier(identifier))

"""
    is_spdx_osi_approved(identifier)

Return whether `identifier` is a current SPDX license identifier marked as OSI
approved in the checked-in SPDX snapshot.

Unknown and deprecated identifiers return `false`.
"""
function is_spdx_osi_approved(identifier::AbstractString)
    info = spdx_license_info(identifier)
    return info !== nothing && info.is_osi_approved
end

"""
    is_spdx_fsf_libre(identifier)

Return whether `identifier` is a current SPDX license identifier marked as FSF
libre in the checked-in SPDX snapshot.

Unknown and deprecated identifiers return `false`.
"""
function is_spdx_fsf_libre(identifier::AbstractString)
    info = spdx_license_info(identifier)
    return info !== nothing && info.is_fsf_libre
end

function _spdx_text_path(canonical_id::AbstractString)
    return pkgdir(
        @__MODULE__,
        "data",
        "spdx-license-list-data",
        "text",
        "$canonical_id.txt"
    )
end

"""
    spdx_license_text_path(identifier; include_deprecated = false)

Return the path to the checked-in SPDX license text for `identifier`, or
`nothing` when `identifier` is unknown or no text file is available.
"""
function spdx_license_text_path(
        identifier::AbstractString; include_deprecated::Bool = false
)
    canonical = canonical_spdx_license_id(identifier; include_deprecated)
    canonical === nothing && return nothing

    path = _spdx_text_path(canonical)
    return isfile(path) ? path : nothing
end

"""
    spdx_license_text(identifier; include_deprecated = false)

Return the checked-in SPDX license text for `identifier`, or `nothing` when
`identifier` is unknown or no text file is available.
"""
function spdx_license_text(
        identifier::AbstractString; include_deprecated::Bool = false
)
    path = spdx_license_text_path(identifier; include_deprecated)
    path === nothing && return nothing
    return read(path, String)
end

"""
    spdx_license_exception_text_path(identifier; include_deprecated = false)

Return the path to the checked-in SPDX license exception text for `identifier`,
or `nothing` when `identifier` is unknown or no text file is available.
"""
function spdx_license_exception_text_path(
        identifier::AbstractString; include_deprecated::Bool = false
)
    canonical = canonical_spdx_license_exception_id(identifier; include_deprecated)
    canonical === nothing && return nothing

    path = _spdx_text_path(canonical)
    return isfile(path) ? path : nothing
end

"""
    spdx_license_exception_text(identifier; include_deprecated = false)

Return the checked-in SPDX license exception text for `identifier`, or `nothing`
when `identifier` is unknown or no text file is available.
"""
function spdx_license_exception_text(
        identifier::AbstractString; include_deprecated::Bool = false
)
    path = spdx_license_exception_text_path(identifier; include_deprecated)
    path === nothing && return nothing
    return read(path, String)
end
