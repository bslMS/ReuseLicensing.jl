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

@testitem "change package copyright notice" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)

            result = set_package_copyright!(
                root;
                year = "1837-1843",
                copyright_holders = ["Ada Lovelace", "contributors"]
            )

            @test result.project_file == project_file
            @test result.license_file == license_file
            @test result.package_copyright_notice ==
                  "Copyright © 1837-1843 Ada Lovelace and contributors"

            project_after = read(project_file, String)
            license_after = read(license_file, String)

            @test occursin(
                "package_copyright_notice = \"Copyright © 1837-1843 Ada Lovelace and contributors\"",
                project_after
            )
            @test startswith(
                license_after,
                "Copyright © 1837-1843 Ada Lovelace and contributors\n\n"
            )
            @test occursin("MIT License", license_after)
            @test replace(
                license_after,
                "Copyright © 1837-1843 Ada Lovelace and contributors" =>
                    "Copyright © 1837 Ada Lovelace";
                count = 1
            ) == license_before
        end
    end
end

@testitem "non-canonical copyright preamble prevents change" setup=[
    BaseSetup,
    PackageFixtures
] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_text = read(license_file, String)
            license_text = replace(
                license_text,
                "Copyright © 1837 Ada Lovelace\n\n" =>
                    "Copyright © 1837 Ada Lovelace\n";
                count = 1
            )
            write(license_file, license_text)
            license_before = read(license_file, String)

            @test_throws ArgumentError set_package_copyright!(
                root;
                year = "1843",
                copyright_holders = ["Ada Lovelace"]
            )

            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end
