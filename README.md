# CosmoReaderBase

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliacosmosims.gitlab.io/CosmoReaderBase.jl/dev)
[![Build Status](https://gitlab.com/juliacosmosims/CosmoReaderBase.jl/badges/main/pipeline.svg)](https://gitlab.com/juliacosmosims/CosmoReaderBase.jl/pipelines)
[![Coverage](https://gitlab.com/juliacosmosims/CosmoReaderBase.jl/badges/main/coverage.svg)](https://gitlab.com/juliacosmosims/CosmoReaderBase.jl/commits/main)
[![Coverage](https://codecov.io/gl/juliacosmosims/CosmoReaderBase.jl/branch/main/graph/badge.svg?token=40ILLQHGW3)](https://codecov.io/gl/juliacosmosims/CosmoReaderBase.jl)

## Installation

This package is available through the public registry
[CosmoAnalysisRegistry](https://github.com/lucasvalenzuela/CosmoAnalysisRegistry). Add the registry
once per Julia installation, together with the General registry, which provides the dependencies:
```julia
using Pkg
Pkg.Registry.add("General")
Pkg.Registry.add(url="https://github.com/lucasvalenzuela/CosmoAnalysisRegistry")
```

The package requires Julia 1.12 or newer and can then be installed with:
```julia
Pkg.add("CosmoReaderBase")
```
