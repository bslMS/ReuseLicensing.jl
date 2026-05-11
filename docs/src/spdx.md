```@meta
CurrentModule = ReuseLicensing
```

# SPDX Snapshot

```@contents
Pages = ["spdx.md"]
```

ReuseLicensing.jl includes a checked-in snapshot of the
[SPDX License List Data](https://github.com/spdx/license-list-data).

## SPDX license information

Accessor functions are available to query SPDX license information.

```@docs
SPDXLicenseInfo
spdx_license_list_version
spdx_license_info
is_spdx_license_id
is_deprecated_spdx_license_id
is_spdx_osi_approved
is_spdx_fsf_libre
is_spdx_license_exception_id
is_deprecated_spdx_license_exception_id
canonical_spdx_license_id
canonical_spdx_license_exception_id
```

## Accessing texts and paths

ReuseLicensing.jl provides direct access to texts as well as to path information for controlled loading at the call site.

```@docs
spdx_license_text_path
spdx_license_text
spdx_license_exception_text_path
spdx_license_exception_text
```
