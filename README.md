# CosmoReaderBase

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://lucasvalenzuela.github.io/CosmoReaderBase.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://lucasvalenzuela.github.io/CosmoReaderBase.jl/dev/)
[![Build Status](https://github.com/lucasvalenzuela/CosmoReaderBase.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lucasvalenzuela/CosmoReaderBase.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/lucasvalenzuela/CosmoReaderBase.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/lucasvalenzuela/CosmoReaderBase.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

CosmoReaderBase is a Julia package that provides an API for reading data from cosmological
simulations, with the particle data represented by CosmoParticles.jl.

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
