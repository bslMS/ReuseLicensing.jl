# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

module ReuseLicensing

export SPDXLicenseInfo
export spdx_license_list_version
export spdx_license_info
export is_spdx_license_id, is_deprecated_spdx_license_id
export is_spdx_license_exception_id, is_deprecated_spdx_license_exception_id
export spdx_license_text_path, spdx_license_text
export spdx_license_exception_text_path, spdx_license_exception_text
export canonical_spdx_license_id, canonical_spdx_license_exception_id
export is_spdx_osi_approved, is_spdx_osi_approved

# SPDX core functions
include("spdx/types.jl")
include("spdx/generated/snapshot.jl")
include("spdx/snapshot.jl")
include("spdx/tokenizer.jl")

end
