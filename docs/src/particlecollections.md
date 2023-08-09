```@meta
CurrentModule = CosmoReaderBase
```

# Particle Collections

```@docs
AbstractSimulationParticleCollection
get_snapshot(pc::AbstractSimulationParticleCollection)
SimulationParticleCollection
SimulationParticleCollection(::Type{AP}, ::AS) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
SimulationParticleCollection(::AS, ::Pair{Symbol,AP}, ::Pair{Symbol,AP}...,) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
SimulationParticleCollection(snapshot::AbstractSnapshot, p::Particles, ps::Particles...)
```

# Halos and Subhalos

## Particle Data

Any [`AbstractHalo`](@ref) contains the particles containing to a halo and the corresponding snapshot.
A Halo can be created if its ID is known or from reading [`AbstractHalos`](@ref) from the simulation.
The particles of a [`Halo`](@ref) or [`Subhalo`](@ref) can be read in from a simulation with
[`read_particles!`](@ref).

```@docs
AbstractHalo
get_id
Halo
Halo(::Type{AP}, ::AS, ::T, props=Dict{Symbol,Any}()) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Halo(::AS, ::T, ::Dict, ::Pair{Symbol,AP}, ::Pair{Symbol,AP}...) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Halo(snapshot::AbstractSnapshot, id, props::Dict, p::Particles, ps::Particles...)
Subhalo
Subhalo(::Type{AP}, ::AS, ::T, props=Dict{Symbol,Any}()) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Subhalo(::AS, ::T, ::Dict, ::Pair{Symbol,AP}, ::Pair{Symbol,AP}...) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
Subhalo(snapshot::AbstractSnapshot, id, props::Dict, p::Particles, ps::Particles...)
CosmoParticles.translate_periodic
CosmoParticles.translate_periodic!
CosmoParticles.translate_periodic_to_center
CosmoParticles.translate_periodic_to_center!
get_subhalos
get_halo(::Subhalo)
get_parent_subhalo
get_main_subhalo
is_main_subhalo
```

## Halo/Subhalo Properties

[`AbstractHalos`](@ref) are an
[`AbstractParticles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/) subtype to provide a
simple interface for reading and working with halo properties.
[`Halos`](@ref) and [`Subhalos`](@ref) can be obtained through [`read_halos`](@ref) and [`read_subhalos`](@ref).
While the particles of an individual halo
(e.g. DM or gas particles) cannot be saved in this type, a [`Halo`](@ref) or [`Subhalo`](@ref) is created when
indexing into an `AbstractHalos`, provided the property `id` is available:

```julia
halos::Halos
halo = halos[1]   # first Halo, into which particles can be read with read_particles!
halo isa Halo     # true
```

Additionally, iterating over `AbstractHalos` returns individual `AbstractHalo` objects, i.e., [`Halo`](@ref) or [`Subhalo`](@ref):

```julia
halos::Halos
for halo in halos
    halo isa Halo  # true
end
```

```@docs
AbstractHalos
Halos
Halos(::AbstractSnapshot)
Subhalos
Subhalos(::AbstractSnapshot)
get_snapshot(::AbstractHalos)
CosmoParticles.redshift(::AbstractHalos)
```
