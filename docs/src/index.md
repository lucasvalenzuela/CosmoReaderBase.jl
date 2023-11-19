```@meta
CurrentModule = CosmoReaderBase
```

# CosmoReaderBase

[`CosmoReaderBase`](https://gitlab.com/juliacosmosims/CosmoReaderBase.jl) provides an API for reading in
cosmological simulations and uses the [`CosmoParticles.jl`](https://github.com/lucasvalenzuela/CosmoParticles.jl)
package for working with particle data.

## Implementing Packages

Currently, only [`GadgetReader.jl`](https://gitlab.com/juliacosmosims/GadgetReader.jl) implements the API for
simulations written in the Gadget 2 format.

## Installation

To install the package, make sure the JuliaCosmoSims registry is installed
([JuliaCosmoSimsDocs](https://juliacosmosims.gitlab.io/JuliaCosmoSimsDocs/dev/installation)).

The latest version of the package is available for Julia 1.7 and newer versions and can be installed with:

```julia
using Pkg
Pkg.add("CosmoReaderBase")
```
