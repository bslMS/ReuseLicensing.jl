# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

module ReuseLicensing

using TOML: TOML

# SPDX core exports.
export parse_spdx_expression, ParsedSPDXExpression
export spdx_license_list_version, reuse_specification_version
export spdx_license_text_path, spdx_license_text
export spdx_license_exception_text_path, spdx_license_exception_text
export canonical_spdx_license_id, canonical_spdx_license_exception_id
export is_spdx_osi_approved, is_spdx_fsf_libre

# Expression approval exports.
export OSIApproved, FSFLibre, UnconjoinedOSIApproval, OpenContentApproval
export AllOf, AnyOf, ValidSPDX
export has_approved_license_path

# Package licensing exports.
export set_package_license!, record_manifest_evidence!

const REUSE_SPECIFICATION_VERSION = "3.3"

"""
    reuse_specification_version()

Return the REUSE specification version used by this package.
"""
reuse_specification_version() = REUSE_SPECIFICATION_VERSION

# SPDX core functions.
include("spdx/types.jl")
include("spdx/generated/snapshot.jl")
include("spdx/snapshot.jl")
include("spdx/normalize.jl")
include("spdx/tokenizer.jl")
include("spdx/render_collect.jl")
include("spdx/parser.jl")

# Expression approval.
include("approval/types.jl")
include("approval/predicates.jl")

# File evaluation.
include("file/types.jl")
include("file/evaluate.jl")

# REUSE CLI interaction.
include("reuse_tool/types.jl")
include("reuse_tool/cli.jl")

# Package level functions.
include("package/types.jl")
include("package/project_toml.jl")
include("package/licensing.jl")
include("package/manifest_evidence.jl")

end
