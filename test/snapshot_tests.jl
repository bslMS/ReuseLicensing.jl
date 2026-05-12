# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "SPDX snapshot metadata is valid" begin
    using TOML

    snapshot_path = joinpath(
        pkgdir(ReuseLicensing),
        "data",
        "spdx-license-list-data",
        "SNAPSHOT.toml"
    )

    @test isfile(snapshot_path)

    snapshot = TOML.parsefile(snapshot_path)

    @test snapshot["schema_version"] == 1
    @test snapshot["source"]["source_ref"] ==
          "v$(snapshot["source"]["spdx_license_list_version"])"
    @test ReuseLicensing.SPDX_LICENSE_LIST_VERSION ==
          snapshot["source"]["spdx_license_list_version"]
    @test snapshot["hashes"]["algorithm"] == "sha256"
    source_ref = snapshot["source"]["source_ref"]
    @test endswith(snapshot["source"]["tarball_url"],
        "/tarball/$source_ref")
end

@testitem "SPDX snapshot hashes match checked-in files" begin
    using SHA
    using TOML

    data_dir = joinpath(
        pkgdir(ReuseLicensing),
        "data",
        "spdx-license-list-data"
    )
    snapshot = TOML.parsefile(joinpath(data_dir, "SNAPSHOT.toml"))

    @test snapshot["hashes"]["algorithm"] == "sha256"

    for (relpath, expected_hash) in snapshot["hashes"]["files"]
        path = joinpath(data_dir, split(relpath, '/')...)
        @test isfile(path)
        @test "sha256:" * bytes2hex(sha256(read(path))) == expected_hash
    end
end

@testitem "validate generated/snapshot.jl" begin
    let p = ReuseLicensing
        for c in (
            p.SPDX_DEPRECATED_LICENSES,
            p.SPDX_LICENSE_EXCEPTIONS,
            p.SPDX_DEPRECATED_LICENSE_EXCEPTIONS
        )
            @test all(key -> key == lowercase(key), keys(c))
            @test all(key -> key == lowercase(c[key]), keys(c))
        end

        let c = p.SPDX_LICENSES
            @test all(key -> key == lowercase(key), keys(c))
            @test all(key -> key == lowercase(c[key].id), keys(c))
        end

        # Test empty intersections.
        @test isempty(
            intersect(keys(p.SPDX_LICENSES), keys(p.SPDX_DEPRECATED_LICENSES))
        )
        @test isempty(
            intersect(
            keys(p.SPDX_LICENSE_EXCEPTIONS),
            keys(p.SPDX_DEPRECATED_LICENSE_EXCEPTIONS)
        )
        )

        # Representative IDs resolve
        @test p.SPDX_LICENSES["mit"] == p.SPDXLicenseInfo("MIT", true, true)
        @test p.SPDX_LICENSES["gpl-3.0-only"] ==
              p.SPDXLicenseInfo("GPL-3.0-only", true, true)
        @test p.SPDX_LICENSES["apache-2.0"] ==
              p.SPDXLicenseInfo("Apache-2.0", true, true)
        @test p.SPDX_LICENSES["eupl-1.2"] ==
              p.SPDXLicenseInfo("EUPL-1.2", true, true)
        @test haskey(p.SPDX_LICENSE_EXCEPTIONS, "classpath-exception-2.0")
    end
end

@testitem "SPDX snapshot accessors" begin
    let p = ReuseLicensing
        @test p.spdx_license_list_version() == p.SPDX_LICENSE_LIST_VERSION

        @test p.spdx_license_info("MIT") == p.SPDXLicenseInfo("MIT", true, true)
        @test p.spdx_license_info("not-a-license") === nothing

        @test p.is_spdx_license_id("Apache-2.0")
        @test !p.is_spdx_license_id("GPL-2.0")
        @test p.is_deprecated_spdx_license_id("GPL-2.0")

        @test p.canonical_spdx_license_id("eupl-1.2") == "EUPL-1.2"
        @test p.canonical_spdx_license_id("GPL-2.0") === nothing
        @test p.canonical_spdx_license_id(
            "GPL-2.0"; include_deprecated = true
        ) == "GPL-2.0"
        @test p.canonical_spdx_license_id("not-a-license") === nothing

        @test p.canonical_spdx_license_exception_id("Classpath-exception-2.0") ==
              "Classpath-exception-2.0"
        @test p.canonical_spdx_license_exception_id(
            "Nokia-Qt-exception-1.1"; include_deprecated = true) ==
              "Nokia-Qt-exception-1.1"
        @test p.canonical_spdx_license_exception_id("Nokia-Qt-exception-1.1") === nothing
        @test p.is_spdx_license_exception_id("Classpath-exception-2.0")
        @test p.is_deprecated_spdx_license_exception_id("Nokia-Qt-exception-1.1")

        mit_path = p.spdx_license_text_path("mit")
        @test basename(mit_path) == "MIT.txt"
        @test contains(p.spdx_license_text("MIT"), "MIT License")
        @test p.spdx_license_text_path("GPL-2.0") === nothing
        @test basename(p.spdx_license_text_path(
            "GPL-2.0"; include_deprecated = true)) == "GPL-2.0.txt"

        classpath_path = p.spdx_license_exception_text_path("Classpath-exception-2.0")
        @test basename(classpath_path) == "Classpath-exception-2.0.txt"
        @test contains(
            p.spdx_license_exception_text("Classpath-exception-2.0"),
            "special exception"
        )
        @test p.spdx_license_exception_text_path("Nokia-Qt-exception-1.1") === nothing
        @test basename(p.spdx_license_exception_text_path(
            "Nokia-Qt-exception-1.1"; include_deprecated = true
        )) == "Nokia-Qt-exception-1.1.txt"
    end
end
