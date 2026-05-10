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
    authors = "Guido Wolf Reichert <gwr@bsl-support.de>",
    sitename = "ReuseLicensing.jl",
    format = Documenter.HTML(;
        canonical = "https://bsl-support.de/julia/ReuseLicensing.jl",
        edit_link = "main",
        assets = String[]
    ),
    pages = [
        "Home" => "index.md"
    ]
)
