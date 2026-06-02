# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "change license from MIT to EUPL-1.2" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            result = set_package_license!(
                root, "EUPL-1.2";
                license_policy = OSIApproved()
            )
            @test result isa NamedTuple
            @test result.package_license_expression == "EUPL-1.2"

            project_text = read(result.project_file, String)
            @test occursin(
                "package_license_expression = \"EUPL-1.2\"",
                project_text
            )
            @test occursin(
                "package_copyright_notice = \"Copyright © 1837 Ada Lovelace\"",
                project_text
            )

            license_text = read(result.license_file, String)
            @test startswith(license_text, "Copyright © 1837 Ada Lovelace")
            @test occursin("EUPL-1.2", license_text)
            @test occursin("EUROPEAN UNION PUBLIC LICENCE", license_text)
            @test !occursin("MIT License", license_text)
        end
    end
end

@testitem "license preamble mismatch prevents change" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            text = read(license_file, String)
            text = replace(
                text,
                "Copyright © 1837 Ada Lovelace" => "Copyright © 1843 Ada Lovelace";
                count = 1
            )
            write(license_file, text)
            license_before = read(license_file, String)

            @test_throws ArgumentError set_package_license!(
                root, "EUPL-1.2";
                license_policy = OSIApproved()
            )
            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end

@testitem "unapproved license prevents change" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)
            @test_throws ArgumentError set_package_license!(
                root, "CC0-1.0";
                license_policy = OSIApproved()
            )
            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end

@testitem "invalid license prevents change" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)
            @test_throws ArgumentError set_package_license!(
                root, "CC1.5";
                license_policy = ValidSPDX()
            )
            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end

@testitem "missing license_ref_dir prevents change" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)
            @test_throws ArgumentError set_package_license!(
                root, "LicenseRef-Proprietary";
                license_policy = ValidSPDX(),
                license_ref_dir = nothing
            )
            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end
