# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testmodule PackageFixtures begin
    const PACKAGE_FIXTURES_DIR = joinpath(@__DIR__, "fixtures", "packages")

    package_fixture_path(name) = joinpath(PACKAGE_FIXTURES_DIR, name)

    function with_package_fixture(f, name)
        mktempdir() do tmp
            src = package_fixture_path(name)
            dst = joinpath(tmp, name)
            cp(src, dst)
            f(dst)
        end
    end

    issue_codes(check) = getproperty.(check.issues, :code)
    has_issue(check, code::Symbol) = code in issue_codes(check)
end

@testsnippet BaseSetup begin
    p = ReuseLicensing
end
