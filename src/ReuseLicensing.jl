# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

module ReuseLicensing

# SPDX core exports
export parse_spdx_expression, ParsedSPDXExpression
export spdx_license_list_version
export spdx_license_text_path, spdx_license_text
export spdx_license_exception_text_path, spdx_license_exception_text
export canonical_spdx_license_id, canonical_spdx_license_exception_id
export is_spdx_osi_approved, is_spdx_fsf_libre

# Expression approval exports
export OSIApproved, FSFLibre
export AllOf, AnyOf
export has_approved_license_path

# SPDX core functions
include("spdx/types.jl")
include("spdx/generated/snapshot.jl")
include("spdx/snapshot.jl")
include("spdx/normalize.jl")
include("spdx/tokenizer.jl")
include("spdx/render_collect.jl")
include("spdx/parser.jl")

# Expression approval
include("approval/types.jl")
include("approval/predicates.jl")

# File evaluation
include("file/types.jl")
include("file/evaluate.jl")

end
