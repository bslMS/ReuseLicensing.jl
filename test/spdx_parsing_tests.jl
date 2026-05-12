# SPDX-FileCopyrightText: 2026 Guido Wolf Reichert <gwr@bsl-support.de>
# SPDX-License-Identifier: EUPL-1.2+

using TestItems

@testsnippet BaseSetup begin
    p = ReuseLicensing
end

@testitem "SPDX tokenizer" setup=[BaseSetup] begin
    tokens = p.tokenize_spdx("MIT AND Apache-2.0")
    @test getfield.(tokens, :kind) == [:ATOM, :AND, :ATOM]
    @test getfield.(tokens, :text) == ["MIT", "AND", "Apache-2.0"]

    @test getfield.(p.tokenize_spdx("(MIT OR Apache-2.0)"), :kind) ==
          [:LPAREN, :ATOM, :OR, :ATOM, :RPAREN]

    @test_throws ArgumentError p.tokenize_spdx("MIT AnD Apache-2.0")
end

@testitem "SPDX token stream" setup=[BaseSetup] begin
    stream = p.SPDXTokenStream(p.tokenize_spdx("MIT AND Apache-2.0"))

    @test p.peek(stream) == p.SPDXToken(:ATOM, "MIT")
    @test p.consume!(stream) == p.SPDXToken(:ATOM, "MIT")
    @test p.expect!(stream, :AND) == p.SPDXToken(:AND, "AND")
    @test p.consume!(stream) == p.SPDXToken(:ATOM, "Apache-2.0")
    @test p.consume!(stream) === nothing
    @test p.isdone(stream)
end

@testitem "atomic identifiers" setup=[BaseSetup] begin
    parsed = parse_spdx_expression("MIT")
    @test parsed isa ParsedSPDXExpression
    @test parsed.ast isa p.SPDXLicenseId
    @test parsed.expression == "MIT"
    @test parsed.licenses isa Set
    @test isempty(parsed.exceptions)
    @test isempty(parsed.licenserefs)

    parsed = parse_spdx_expression("LicenseRef-Custom.1")
    @test parsed.ast isa p.SPDXLicenseRef
    @test parsed.expression == "LicenseRef-Custom.1"
    @test parsed.ast.identifier == "Custom.1"
    @test parsed.licenserefs == Set(["custom.1"])

    @test parse_spdx_expression("gPl-2.0+").expression == "GPL-2.0-or-later"
end

@testitem "operator precedence" setup=[BaseSetup] begin
    ast = parse_spdx_expression("MIT OR Apache-2.0 AND BSD-3-Clause").ast
    @test ast isa p.SPDXDisjunctiveExpression
    @test ast.left isa p.SPDXLicenseId
    @test ast.left.identifier == "MIT"
    @test ast.right isa p.SPDXConjunctiveExpression
    @test ast.right.left isa p.SPDXLicenseId
    @test ast.right.left.identifier == "Apache-2.0"
    @test ast.right.right isa p.SPDXLicenseId
    @test ast.right.right.identifier == "BSD-3-Clause"
end

@testitem "with expressions inside larger expressions" setup=[BaseSetup] begin
    ast = parse_spdx_expression("EUPL-1.2 AND GPL-3.0-only WITH Classpath-exception-2.0").ast
    @test ast isa p.SPDXConjunctiveExpression
    @test ast.left isa p.SPDXLicenseId
    @test ast.right isa p.SPDXWithExceptionExpression
    @test ast.right.license isa p.SPDXLicenseId
    @test ast.right.exception isa p.SPDXLicenseExceptionId
    @test ast.right.license.identifier == "GPL-3.0-only"
    @test ast.right.exception.identifier == "Classpath-exception-2.0"
end

@testitem "invalid expressions" begin
    @test_throws ArgumentError parse_spdx_expression("GPL-2.0+"; legacy = :error)
    @test_throws ArgumentError parse_spdx_expression("Classpath-exception-2.0")
    @test_throws ArgumentError parse_spdx_expression("LicenseRef-")
    @test_throws ArgumentError parse_spdx_expression("LicenseRef-Fake/Bad")
    @test_throws ArgumentError parse_spdx_expression("MIT Or Apache-2.0")
    @test_throws ArgumentError parse_spdx_expression("MIT AnD Apache-2.0")
    @test_throws ArgumentError parse_spdx_expression("MIT Apache-2.0")
    @test_throws ArgumentError parse_spdx_expression("MIT OR Apache-2.0 BSD-3-Clause")
    @test_throws ArgumentError parse_spdx_expression("MIT WITH Apache-2.0")
    @test_throws ArgumentError parse_spdx_expression("(MIT OR Apache-2.0) WITH Classpath-exception-2.0")
    @test_throws ArgumentError parse_spdx_expression("GPL-2.0-only WITH Nokia-Qt-exception-1.1")
end

@testitem "parentheses overriding precedence" setup=[BaseSetup] begin
    ast = parse_spdx_expression("(MIT OR Apache-2.0) AND BSD-3-Clause").ast
    @test ast isa p.SPDXConjunctiveExpression
    @test ast.left isa p.SPDXDisjunctiveExpression
    @test ast.right isa p.SPDXLicenseId
    @test ast.right.identifier =="BSD-3-Clause"
end

@testitem "opposite precedence directions" setup=[BaseSetup] begin
    ast = parse_spdx_expression("MIT AND Apache-2.0 OR BSD-3-Clause").ast
    @test ast isa p.SPDXDisjunctiveExpression
    @test ast.left isa p.SPDXConjunctiveExpression
    @test ast.right isa p.SPDXLicenseId
    @test ast.right.identifier == "BSD-3-Clause"
end

@testitem "case-insensitive identifiers and lowercase operators" setup=[BaseSetup] begin
    ast = parse_spdx_expression("mIt or ApAcHe-2.0+ and BSD-3-ClAUse").ast
    @test ast isa p.SPDXDisjunctiveExpression
    @test ast.left isa p.SPDXLicenseId
    @test ast.left.identifier == "MIT"
    @test ast.right isa p.SPDXConjunctiveExpression
    @test ast.right.left isa p.SPDXLicenseId
    @test ast.right.left.identifier == "Apache-2.0+"
    @test ast.right.right isa p.SPDXLicenseId
    @test ast.right.right.identifier == "BSD-3-Clause"

    ast = parse_spdx_expression("GpL-2.0 with Classpath-eXception-2.0").ast
    @test ast isa p.SPDXWithExceptionExpression
    @test ast.license.identifier == "GPL-2.0-only"
    @test ast.exception.identifier == "Classpath-exception-2.0"
end

@testitem "legacy normalization plus WITH" setup=[BaseSetup] begin
    parsed = parse_spdx_expression("AGPL-3.0+ WITH Classpath-exception-2.0")
    @test parsed.expression == "AGPL-3.0-or-later WITH Classpath-exception-2.0"
    @test parsed.licenses == Set(["AGPL-3.0-or-later"])
    @test parsed.exceptions == Set(["Classpath-exception-2.0"])
    @test parsed.licenserefs == Set([])
end

@testitem "precedence reflected in rendering" begin
    parsed = parse_spdx_expression("(MIT OR Apache-2.0) AND BSD-3-Clause")
    @test parsed.expression == "(MIT OR Apache-2.0) AND BSD-3-Clause"
    @test parsed.licenses == Set(["MIT", "Apache-2.0", "BSD-3-Clause"])

    parsed = parse_spdx_expression("MIT OR Apache-2.0 AND BSD-3-Clause")
    @test parsed.expression == "MIT OR Apache-2.0 AND BSD-3-Clause"
end

@testitem "generic trailing + lookup behavior" begin
    parsed = parse_spdx_expression("EUPL-1.2+")
    @test parsed.expression == "EUPL-1.2+"
    @test parsed.licenses == Set(["EUPL-1.2"])
end

@testitem "rendering and collection for composite expressions" setup=[BaseSetup] begin
    parsed = parse_spdx_expression(
        "(MIT OR Apache-2.0) AND LicenseRef-Custom.1"
    )
    @test parsed.expression == "(MIT OR Apache-2.0) AND LicenseRef-Custom.1"
    @test parsed.licenses == Set(["MIT", "Apache-2.0"])
    @test parsed.exceptions == Set{String}()
    @test parsed.licenserefs == Set(["custom.1"])

    parsed = parse_spdx_expression(
        "MIT WITH Classpath-exception-2.0 OR EUPL-1.2+"
    )
    @test parsed.expression == "MIT WITH Classpath-exception-2.0 OR EUPL-1.2+"
    @test parsed.licenses == Set(["MIT", "EUPL-1.2"])
    @test parsed.exceptions == Set(["Classpath-exception-2.0"])
    @test parsed.licenserefs == Set{String}()
end

