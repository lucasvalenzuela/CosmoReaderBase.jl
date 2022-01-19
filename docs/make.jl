using CosmoReaderBase
using Documenter

DocMeta.setdocmeta!(CosmoReaderBase, :DocTestSetup, :(using CosmoReaderBase); recursive=true)

makedocs(;
    modules=[CosmoReaderBase],
    authors="Lucas Valenzuela",
    repo="https://gitlab.com/juliacosmosims/CosmoReaderBase.jl/blob/{commit}{path}#{line}",
    sitename="CosmoReaderBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliacosmosims.gitlab.io/CosmoReaderBase.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Simulation" => "simulation.md",
    ],
)

deploydocs(;
    repo="gitlab.com/juliacosmosims/CosmoReaderBase.jl",
    devbranch="main",
)
