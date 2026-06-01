# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testsnippet BaseSetup begin
    p = ReuseLicensing
end

@testitem "basic reuse CLI interaction" setup=[BaseSetup] begin
    @test p.has_reuse() isa Bool

    if p.has_reuse()
        exe = p.reuse_executable()
        @test isfile(exe)

        result = p.reuse_lint_lines(;
            root = pkgdir(ReuseLicensing), multiprocessing = false)
        @test result isa p.ReuseLintLinesResult
        @test result.status isa Int
        @test result.stdout isa String
        @test result.stderr isa String

        json_result = p.reuse_lint_json(;
            root = pkgdir(ReuseLicensing), multiprocessing = false)
        @test json_result isa p.ReuseLintJsonResult
        @test json_result.status isa Int
        @test json_result.stdout isa String
        @test json_result.stderr isa String
    else
        @test_throws ArgumentError p.reuse_executable()
    end
end
