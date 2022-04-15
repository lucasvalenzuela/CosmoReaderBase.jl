```@meta
CurrentModule = CosmoReaderBase
```

# Reading

## Reading Particles

```@docs
read_particles
read_particles!
read_particles_in_cuboid
read_particle_ids
```

## Reading Halos

```@docs
read_prop(::AbstractHalo)
read_halos
read_subhalos
```

## Developer's API

At least the following functions have to be implemented for implementations of `AbstractCosmoSimulation`.
Further predefined methods can also be implemented to improve performance.

- `read_particles(snapshot::AbstractSnapshot)`
- `read_particles(snapshot::AbstractSnapshot, type::Symbol)`
- `read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Union{Tuple,Pair}})`
- `read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Union{Tuple,Pair}}, ids::AbstractVector)`
- `read_particles_in_cuboid(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Union{Tuple,Pair}}, lowerleft::AbstractArray, upperright::AbstractArray)`

```@docs
read_prop_simunits
convert_halo_prop
convert_particle_prop!
```
