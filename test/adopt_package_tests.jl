# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "adopt package fails without force" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("legacy_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)

            @test_throws ArgumentError adopt_package_licensing!(
                root;
                package_license = "MIT",
                year = "1837",
                copyright_holders = ["Ada Lovelace"],
                license_policy = OSIApproved()
            )

            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end

@testitem "adopt package succeeds with force" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("legacy_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)

            result = adopt_package_licensing!(
                root;
                package_license = "mit",
                year = "1837",
                copyright_holders = ["Ada Lovelace"],
                license_policy = OSIApproved(),
                force = true
            )

            @test result.package_license_expression == "MIT"
            @test result.project_file == project_file
            @test result.license_file == license_file

            license_after = read(license_file, String)
            project_after = read(project_file, String)

            @test project_after != project_before
            @test license_after != license_before

            old_copyright_notice = "Copyright (c) 1837 Ada Lovelace"

            @test occursin(old_copyright_notice, license_before) &&
                  !occursin(old_copyright_notice, license_after)

            @test occursin(
                "[reuse_licensing]\n",
                project_after
            )
            @test occursin(
                "package_copyright_notice = \"Copyright © 1837 Ada Lovelace\"\n",
                project_after
            )
            @test occursin(
                "package_license_expression = \"MIT\"\n",
                project_after
            )
        end
    end
end

@testitem "adopt package succeeds without force" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("legacy_reuse_package") do root
            license_file = joinpath(root, "LICENSE")
            rm(license_file)

            # Without a LICENSE to be found adopting should succeed.
            result = adopt_package_licensing!(
                root;
                package_license = "MIT",
                year = "1837",
                copyright_holders = ["Ada Lovelace", "Charles Babbage", "contributors"],
                license_policy = OSIApproved()
            )

            @test result.license_file == license_file
            @test isfile(license_file)
            @test startswith(
                read(license_file, String),
                "Copyright © 1837 Ada Lovelace, Charles Babbage, and contributors"
            )
        end
    end
end

@testitem "already adopted package fails" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("legacy_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            license_file = joinpath(root, "LICENSE")
            rm(license_file)

            adopt_package_licensing!(
                root;
                package_license = "MIT",
                year = "1837",
                copyright_holders = ["Ada Lovelace", "Charles Babbage", "contributors"],
                license_policy = OSIApproved()
            )

            project_before = read(project_file, String)
            license_before = read(license_file, String)

            @test_throws ArgumentError adopt_package_licensing!(
                root;
                package_license = "EUPL-1.2",
                year = "1837",
                copyright_holders = ["Ada Lovelace"],
                license_policy = OSIApproved(),
                force = true
            )

            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end

@testitem "invalid year prevents adoption" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("legacy_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)

            @test_throws ArgumentError adopt_package_licensing!(
                root;
                package_license = "MIT",
                year = "eighteen thirty-seven",
                copyright_holders = ["Ada Lovelace"],
                license_policy = OSIApproved(),
                force = true
            )

            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end

@testitem "empty copyright holders prevent adoption" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("legacy_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            project_before = read(project_file, String)
            license_file = joinpath(root, "LICENSE")
            license_before = read(license_file, String)

            @test_throws ArgumentError adopt_package_licensing!(
                root;
                package_license = "MIT",
                year = "1837",
                copyright_holders = String[],
                license_policy = OSIApproved(),
                force = true
            )

            @test read(project_file, String) == project_before
            @test read(license_file, String) == license_before
        end
    end
end
