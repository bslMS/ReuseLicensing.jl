using ReuseLicensing
using Documenter

DocMeta.setdocmeta!(
    ReuseLicensing,
    :DocTestSetup,
    :(using ReuseLicensing);
    recursive = true
)

makedocs(;
    modules = [ReuseLicensing],
    authors = "Guido Wolf Reichert <gwr@bsl-support.de> and contributors",
    sitename = "ReuseLicensing.jl",
    format = Documenter.HTML(;
        canonical = "https://bsl-support.de/julia/ReuseLicensing.jl",
        edit_link = "main",
        assets = String[],
        footer = "Copyright © 2026 Guido Wolf Reichert and contributors ⋅ Documentation " *
        "licensed under [CC-BY-SA-4.0](https://creativecommons.org/licenses/by-sa/4.0/) " *
        "⋅ Built with [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)."
    ),
    pages = [
        "Home" => "index.md",
        "SPDX Core" => "spdx.md",
    ]
)
