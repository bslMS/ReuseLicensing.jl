# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "valid package check" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            check = check_package_licensing(root; license_policy = OSIApproved())
            @test is_ok(check)
            @test check.root == root
        end
    end
end

@testitem "missing reuse metadata" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            text = read(project_file, String)
            # Remove the [reuse_licensing] table.
            text = replace(text, r"(?ms)^\[reuse_licensing\]\n.*?(?=^\[|\z)" => "")
            write(project_file, text)

            check = check_package_licensing(root)
            @test !is_ok(check)
            @test PackageFixtures.has_issue(check, :metadata_missing)
        end
    end
end

@testitem "metadata invalid" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            text = read(project_file, String)
            text = replace(text, r"(?m)^package_license_expression = \"MIT\"\n" => "")
            write(project_file, text)

            check = check_package_licensing(root)
            @test !is_ok(check)
            @test PackageFixtures.has_issue(check, :metadata_invalid)
        end
    end
end

@testitem "package license invalid" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            text = read(project_file, String)
            text = replace(
                text,
                "package_license_expression = \"MIT\"" => "package_license_expression = \"Not-A-License\""
            )
            write(project_file, text)

            check = check_package_licensing(root)
            @test !is_ok(check)
            @test PackageFixtures.has_issue(check, :package_license_invalid)
        end
    end
end

@testitem "package license not approved" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            project_file = joinpath(root, "Project.toml")
            text = read(project_file, String)
            text = replace(
                text,
                "package_license_expression = \"MIT\"" => "package_license_expression = \"CC0-1.0\""
            )
            write(project_file, text)

            check = check_package_licensing(root; license_policy = OSIApproved())
            @test !is_ok(check)
            @test PackageFixtures.has_issue(check, :package_license_not_approved)
        end
    end
end

@testitem "license preamble mismatch" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            license_file = joinpath(root, "LICENSE")
            text = read(license_file, String)
            text = replace(
                text,
                "Copyright © 1837 Ada Lovelace" => "Copyright © 1843 Ada Lovelace";
                count = 1
            )
            write(license_file, text)

            check = check_package_licensing(root)
            @test !is_ok(check)
            @test PackageFixtures.has_issue(check, :license_mismatch)
        end
    end
end

@testitem "ambiguous license file" setup=[BaseSetup, PackageFixtures] begin
    if !p.has_reuse()
        @test_skip "reuse CLI not available"
    else
        PackageFixtures.with_package_fixture("valid_reuse_package") do root
            write(joinpath(root, "LICENSE.txt"), "Ambiguous package license file.\n")

            check = check_package_licensing(root)
            @test !is_ok(check)
            @test PackageFixtures.has_issue(check, :ambiguous_license_file)
        end
    end
end
