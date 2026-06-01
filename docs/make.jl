using Pkg

Pkg.develop(Pkg.PackageSpec(path = joinpath(@__DIR__, "..")))
Pkg.instantiate()

using ReuseLicensing
using Documenter

const PROJECT_TOML = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
const PACKAGE_VERSION = VersionNumber(PROJECT_TOML["version"])

DocMeta.setdocmeta!(
    ReuseLicensing,
    :DocTestSetup,
    :(using ReuseLicensing);
    recursive = true,
)

makedocs(;
    modules = [ReuseLicensing],
    authors = "Guido Wolf Reichert <gwr@bsl-support.de> and contributors",
    sitename = "ReuseLicensing.jl",
    format = Documenter.HTML(;
        canonical = "https://bsl-support.de/julia/ReuseLicensing.jl",
        edit_link = "main",
        assets = String[],
        footer = "Copyright © 2026 Guido Wolf Reichert and contributors ⋅ " *
        "Documentation v$(PACKAGE_VERSION) " *
        "licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/) " *
        "⋅ Built with [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)."
    ),
    pages = [
        "Home" => "index.md",
        "SPDX Core" => "spdx.md",
        "Approval Layers" => "approval.md",
        "Package Licensing" => "package.md"
    ]

)
