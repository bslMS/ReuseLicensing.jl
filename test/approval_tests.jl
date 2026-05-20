# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "approval public API accepts strings and parsed expressions" begin
    @test has_approved_license_path("MIT", OSIApproved())
    @test has_approved_license_path(parse_spdx_expression("MIT"), OSIApproved())

    @test has_approved_license_path("GPL-2.0+", OSIApproved())
    @test_throws ArgumentError has_approved_license_path(
        "GPL-2.0+",
        OSIApproved();
        legacy = :error
    )
end

@testitem "approval leaf policies use SPDX snapshot metadata" begin
    @test has_approved_license_path("MIT", OSIApproved())
    @test has_approved_license_path("MIT", FSFLibre())

    @test !has_approved_license_path("CC-BY-NC-4.0", OSIApproved())
    @test !has_approved_license_path("CC-BY-NC-4.0", FSFLibre())

    @test has_approved_license_path("0BSD", OSIApproved())
    @test !has_approved_license_path("0BSD", FSFLibre())

    @test !has_approved_license_path("CC0-1.0", OSIApproved())
    @test has_approved_license_path("CC0-1.0", FSFLibre())
end

@testitem "approval strips trailing plus for license metadata lookup" begin
    @test has_approved_license_path("Apache-2.0+", OSIApproved())
    @test has_approved_license_path("Apache-2.0+", FSFLibre())
end

@testitem "approval does not approve LicenseRef identifiers from SPDX metadata" begin
    @test !has_approved_license_path("LicenseRef-Internal", OSIApproved())
    @test !has_approved_license_path("LicenseRef-Internal", FSFLibre())
end

@testitem "approval follows SPDX OR semantics" begin
    @test has_approved_license_path("MIT OR LicenseRef-Internal", OSIApproved())
    @test has_approved_license_path("LicenseRef-Internal OR MIT", OSIApproved())
    @test !has_approved_license_path(
        "LicenseRef-Internal OR LicenseRef-External",
        OSIApproved()
    )
end

@testitem "approval follows SPDX AND semantics" begin
    @test has_approved_license_path("MIT AND Apache-2.0", OSIApproved())
    @test !has_approved_license_path("MIT AND LicenseRef-Internal", OSIApproved())
    @test !has_approved_license_path("CC0-1.0 AND MIT", OSIApproved())
end

@testitem "approval policy combinators compose leaf policies" begin
    any_policy = AnyOf(OSIApproved(), FSFLibre())
    all_policy = AllOf(OSIApproved(), FSFLibre())

    @test any_policy.policies == (OSIApproved(), FSFLibre())
    @test all_policy.policies == (OSIApproved(), FSFLibre())

    @test has_approved_license_path("0BSD", any_policy)
    @test !has_approved_license_path("0BSD", all_policy)

    @test has_approved_license_path("CC0-1.0", any_policy)
    @test !has_approved_license_path("CC0-1.0", all_policy)

    @test has_approved_license_path("MIT", all_policy)
end

@testitem "approval policy combinators compose over SPDX expressions" begin
    policy = AnyOf(OSIApproved(), FSFLibre())

    @test has_approved_license_path("CC0-1.0 OR 0BSD", policy)
    @test has_approved_license_path("CC0-1.0 AND 0BSD", policy)
    @test !has_approved_license_path(
        "CC-BY-NC-4.0 OR LicenseRef-Internal",
        policy
    )
end

@testitem "approval conservatively rejects WITH expressions" begin
    @test !has_approved_license_path(
        "GPL-2.0-only WITH Classpath-exception-2.0",
        OSIApproved()
    )
    @test !has_approved_license_path(
        "GPL-2.0-only WITH Classpath-exception-2.0",
        AnyOf(OSIApproved(), FSFLibre())
    )
end

@testitem "General registry approval" begin
    # Can be approved.
    @test has_approved_license_path("MIT", GeneralRegistryCodeApproval())
    @test has_approved_license_path("CC0-1.0", GeneralRegistryContentApproval())
    @test has_approved_license_path("CC-BY-4.0", GeneralRegistryContentApproval())
    @test has_approved_license_path("CC-BY-SA-4.0", GeneralRegistryContentApproval())
    @test has_approved_license_path(
        "CC-BY-4.0 OR CC0-1.0 OR CC-BY-SA-4.0",
        GeneralRegistryContentApproval()
    )
    @test has_approved_license_path(
        "MIT OR LicenseRef-US-Public-Domain",
        GeneralRegistryCodeApproval()
    )
    @test has_approved_license_path(
        "MIT AND EUPL-1.2 OR Apache-2.0",
        GeneralRegistryCodeApproval()
    )
    # Can not be approved.
    @test !has_approved_license_path(
        "GPL-3.0-only AND MIT",
        GeneralRegistryCodeApproval()
    )
    @test !has_approved_license_path("CC0-1.0", GeneralRegistryCodeApproval())
    @test !has_approved_license_path(
        "GPL-2.0-only WITH Classpath-exception-2.0",
        GeneralRegistryCodeApproval()
    )
    @test !has_approved_license_path(
        "LicenseRef-Internal",
        GeneralRegistryCodeApproval()
    )
    @test !has_approved_license_path(
        "CC-BY-SA-3.0 OR GFDL-1.3-or-later",
        GeneralRegistryContentApproval()
    )
    @test !has_approved_license_path(
        "CC0-1.0 AND CC-BY-4.0",
        GeneralRegistryContentApproval()
    )
    @test !has_approved_license_path(
        "LicenseRef-Internal",
        GeneralRegistryContentApproval()
    )
end
