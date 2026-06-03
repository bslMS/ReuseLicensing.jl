# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "record manifest evidence default path" setup=[PackageFixtures] begin
    PackageFixtures.with_package_fixture("valid_reuse_package") do root
        manifest_file = joinpath(root, "Manifest.toml")
        write(manifest_file, "julia_version = \"$(VERSION)\"\n")

        dest = record_manifest_evidence!(root)

        expected_filename =
            replace(Base.BinaryPlatforms.host_triplet(), r"_version\+" => "-") * ".toml"

        @test basename(dest) == expected_filename
        @test dirname(dest) == joinpath(
            root,
            ".licensing",
            "manifests",
            "v0.1.0"
        )
        @test read(dest, String) == read(manifest_file, String)
    end
end

@testitem "record manifest evidence profile path is normalized" setup=[
    PackageFixtures
] begin
    PackageFixtures.with_package_fixture("valid_reuse_package") do root
        write(joinpath(root, "Manifest.toml"), "julia_version = \"$(VERSION)\"\n")

        dest = record_manifest_evidence!(
            root;
            profile = "Extensions/Foo_Ext Profile"
        )

        @test dirname(dest) == joinpath(
            root,
            ".licensing",
            "manifests",
            "v0.1.0",
            "extensions",
            "foo-ext-profile"
        )
    end
end

@testitem "record manifest evidence rejects unsafe profiles" setup=[PackageFixtures] begin
    PackageFixtures.with_package_fixture("valid_reuse_package") do root
        write(joinpath(root, "Manifest.toml"), "julia_version = \"$(VERSION)\"\n")

        for profile in ("", "../bad", ".hidden", "bad:name", "bad//name")
            @test_throws ArgumentError record_manifest_evidence!(root; profile)
        end
    end
end
