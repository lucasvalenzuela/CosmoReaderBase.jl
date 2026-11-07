using CosmoReaderBase
using Documenter

DocMeta.setdocmeta!(CosmoReaderBase, :DocTestSetup, :(using CosmoReaderBase); recursive=true)

makedocs(;
    modules=[CosmoReaderBase],
    authors="Lucas Valenzuela",
    sitename="CosmoReaderBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lucasvalenzuela.github.io/CosmoReaderBase.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Quick Start" => "quickstart.md",
        "Simulation" => "simulation.md",
        "Particle Collections" => "particlecollections.md",
        "Reading" => "reading.md",
        "Merger Trees" => "trees.md",
        "Utils" => "configutils.md",
    ],
)

deploydocs(;
    repo="github.com/lucasvalenzuela/CosmoReaderBase.jl",
    devbranch="main",
)
