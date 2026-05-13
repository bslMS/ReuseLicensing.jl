# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

const LEGACY_LICENSE_ID_MAP = Dict{String, String}(
    "gpl-1.0" => "GPL-1.0-only",
    "gpl-1.0+" => "GPL-1.0-or-later",
    "gpl-2.0" => "GPL-2.0-only",
    "gpl-2.0+" => "GPL-2.0-or-later",
    "gpl-3.0" => "GPL-3.0-only",
    "gpl-3.0+" => "GPL-3.0-or-later",
    "lgpl-2.0" => "LGPL-2.0-only",
    "lgpl-2.0+" => "LGPL-2.0-or-later",
    "lgpl-2.1" => "LGPL-2.1-only",
    "lgpl-2.1+" => "LGPL-2.1-or-later",
    "lgpl-3.0" => "LGPL-3.0-only",
    "lgpl-3.0+" => "LGPL-3.0-or-later",
    "agpl-1.0" => "AGPL-1.0-only",
    "agpl-1.0+" => "AGPL-1.0-or-later",
    "agpl-3.0" => "AGPL-3.0-only",
    "agpl-3.0+" => "AGPL-3.0-or-later",
    "gfdl-1.1" => "GFDL-1.1-only",
    "gfdl-1.1+" => "GFDL-1.1-or-later",
    "gfdl-1.2" => "GFDL-1.2-only",
    "gfdl-1.2+" => "GFDL-1.2-or-later",
    "gfdl-1.3" => "GFDL-1.3-only",
    "gfdl-1.3+" => "GFDL-1.3-or-later"
)

# Normalize spdx identifier to lowercase and optionally replace legacy identifiers.
function normalize_legacy_spdx_license_identifier(
        identifier::AbstractString; legacy)
    legacy in (:normalize, :error) || throw(
        ArgumentError("`legacy` must be either `:error` or `:normalize` got `$legacy`."
    ))
    lcidentifier = lowercase(identifier)
    if haskey(LEGACY_LICENSE_ID_MAP, lcidentifier)
        license_id = LEGACY_LICENSE_ID_MAP[lcidentifier]
    else
        license_id = nothing
    end

    if license_id === nothing
        return lcidentifier
    elseif legacy === :error
        throw(ArgumentError(
            "License identifier `$identifier` has been deprecated and should be replaced " *
            "by `$license_id`"
        ))
    else
        return license_id
    end
end

function normalize_spdx_license_identifier(identifier::AbstractString; legacy)
    normid = normalize_legacy_spdx_license_identifier(identifier; legacy)
    if endswith(normid, "+")
        orlater = true
        normid = String(chop(normid))
    else
        orlater = false
    end
    if is_spdx_license_exception_id(normid) ||
       is_deprecated_spdx_license_exception_id(normid)
        throw(ArgumentError(
            "Expected SPDX license identifier, got license exception `$normid`."
        ))
    elseif is_spdx_license_id(normid)
        canonical = canonical_spdx_license_id(normid)
        orlater && return SPDXLicenseId(canonical * "+")
        return SPDXLicenseId(canonical)
    elseif is_deprecated_spdx_license_id(normid)
        throw(ArgumentError(
            "License `$normid` is deprecated."
        ))
    else
        throw(ArgumentError(
            "Unknown SPDX license identifier: `$normid`."
        ))
    end
end

# Return the SPDX license identifier without a trailing `+` operator.
function base_license_identifier(identifier::AbstractString)
    endswith(identifier, "+") ? String(chop(identifier)) : String(identifier)
end
