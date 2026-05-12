# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testitem "SPDX tokenizer" begin
    let p = ReuseLicensing
        tokens = p.tokenize_spdx("MIT AND Apache-2.0")
        @test getfield.(tokens, :kind) == [:ATOM, :AND, :ATOM]
        @test getfield.(tokens, :text) == ["MIT", "AND", "Apache-2.0"]

        @test getfield.(p.tokenize_spdx("(MIT OR Apache-2.0)"), :kind) ==
              [:LPAREN, :ATOM, :OR, :ATOM, :RPAREN]

        @test_throws ArgumentError p.tokenize_spdx("MIT AnD Apache-2.0")
    end
end

@testitem "SPDX token stream" begin
    let p = ReuseLicensing
        stream = p.SPDXTokenStream(p.tokenize_spdx("MIT AND Apache-2.0"))

        @test p.peek(stream) == p.SPDXToken(:ATOM, "MIT")
        @test p.consume!(stream) == p.SPDXToken(:ATOM, "MIT")
        @test p.expect!(stream, :AND) == p.SPDXToken(:AND, "AND")
        @test p.consume!(stream) == p.SPDXToken(:ATOM, "Apache-2.0")
        @test p.consume!(stream) === nothing
        @test p.isdone(stream)
    end
end

# Add parser tests once parser functions exist.

