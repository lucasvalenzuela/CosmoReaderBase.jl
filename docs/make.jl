using CosmoReaderBase
using Documenter

DocMeta.setdocmeta!(CosmoReaderBase, :DocTestSetup, :(using CosmoReaderBase); recursive=true)

makedocs(;
    modules=[CosmoReaderBase],
    authors="Lucas Valenzuela",
    repo="https://github.com/lucasvalenzuela/CosmoReaderBase.jl/blob/{commit}{path}#{line}",
    sitename="CosmoReaderBase.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://lucasvalenzuela.github.io/CosmoReaderBase.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/lucasvalenzuela/CosmoReaderBase.jl",
    devbranch="main",
)
