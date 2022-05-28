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

Note that this package usually does not have to be directly installed by the user, instead install any of the
implementing packages.

This package is only available through the local registry
[CosmoSimsRegistry](https://gitlab.com/juliacosmosims/CosmoSimsRegistry), for which access first needs to be
granted. It is recommended that an ssh key pair is created with the following command (which can be saved
as `id_rsa_gitlab`, for example):
```
ssh-keygen -t rsa -b 4096 -m PEM
```

For the package manager to pick up on the ssh key, either `ssh-agent` has to be used, or the following two
environment variables should be set (e.g., by setting them in the `.bashrc` file with `export` in front of each
line):
```
SSH_KEY_PATH=~/.ssh/id_rsa_gitlab
SSH_PUB_KEY_PATH=~/.ssh/id_rsa_gitlab.pub
```

The package registry can be loaded from the Julia REPL with the Julia package manager:
```julia
using Pkg
pkg"registry add https://gilab.com/juliacosmosims/CosmoSimsRegistry"
```
This only needs to be done once per Julia installation.

The latest version of the package is available for Julia 1.7 and newer versions and can be installed with:
```julia
using Pkg
Pkg.add("CosmoReaderBase")
```
