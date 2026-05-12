```@meta
CurrentModule = ReuseLicensing
```

# SPDX Core

ReuseLicensing.jl provides the package's core SPDX functionality: parsing SPDX
license expressions, collecting referenced identifiers, and using a checked-in
snapshot of the [SPDX License List Data](https://github.com/spdx/license-list-data)
for lookup and bundled license texts.

## SPDX license expressions

[SPDX license expressions](https://spdx.github.io/spdx-spec/v2.3/SPDX-license-expressions/) can be parsed into a compact result object that contains
the normalized expression string, referenced SPDX license identifiers, referenced
exception identifiers, and `LicenseRef-*` identifiers.

```@example spdx-parsing
using ReuseLicensing

parsed = parse_spdx_expression("(MIT OR Apache-2.0) AND LicenseRef-Custom.1")
parsed.expression
```

```@example spdx-parsing
sort(collect(parsed.licenses))
```

```@example spdx-parsing
sort(collect(parsed.licenserefs))
```

Legacy SPDX license identifiers with current replacements are normalized by
default. Pass `legacy = :error` to reject them instead.

```@example spdx-parsing
parse_spdx_expression("GPL-2.0+").expression
```

```@docs
ParsedSPDXExpression
parse_spdx_expression
```

## SPDX license data

Accessor functions are available to query SPDX license information and canonical
identifier spellings.

```@docs
spdx_license_list_version
is_spdx_osi_approved
is_spdx_fsf_libre
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
