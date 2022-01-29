```@meta
CurrentModule = CosmoReaderBase
```

# Particle Collections

```@docs
AbstractSimulationParticleCollection
get_snapshot(pc::AbstractSimulationParticleCollection)
SimulationParticleCollection
SimulationParticleCollection(::Type{AP}, ::AS) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
SimulationParticleCollection(::AS, ::Pair{Symbol,AP}...,) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
SimulationParticleCollection(snapshot::AbstractSnapshot, p::Particles, ps::Particles...)
AbstractHalo
get_id
```

# Halos and Subhalos

```@docs
Halo
Halo(::Type{AP}, ::AS, ::T, props=Dict{Symbol,Any}()) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Halo(::AS, ::T, ::Dict, ::Pair{Symbol,AP}...) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Halo(snapshot::AbstractSnapshot, id, props::Dict, p::Particles, ps::Particles...)
Subhalo
Subhalo(::Type{AP}, ::AS, ::T, props=Dict{Symbol,Any}()) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Subhalo(::AS, ::T, ::Dict, ::Pair{Symbol,AP}...) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Subhalo(snapshot::AbstractSnapshot, id, props::Dict, p::Particles, ps::Particles...)
CosmoParticles.translate_periodic
CosmoParticles.translate_periodic!
CosmoParticles.translate_periodic_to_center
CosmoParticles.translate_periodic_to_center!
get_subhalos
get_halo
get_parent_subhalo
get_main_subhalo
is_main_subhalo
```
