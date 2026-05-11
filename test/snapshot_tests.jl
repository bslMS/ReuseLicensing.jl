# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "SPDX snapshot metadata is readable" begin
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

    for(relpath, expected_hash) in snapshot["hashes"]["files"]
        path = joinpath(data_dir, split(relpath, '/')...)
        @test isfile(path)
        @test "sha256:" * bytes2hex(sha256(read(path))) == expected_hash
    end
end
