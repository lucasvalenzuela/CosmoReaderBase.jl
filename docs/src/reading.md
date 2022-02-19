```@meta
CurrentModule = CosmoReaderBase
```

# Reading

## Reading 

```@docs
read_particles
read_particles!
read_particles_in_cuboid
read_particle_ids
read_prop
read_halos
read_subhalos
```

## Developer's API

At least the following functions have to be implemented for implementations of `AbstractCosmoSimulation`.
Further predefined methods can also be implemented to improve performance.

- `read_particles(snapshot::AbstractSnapshot)`
- `read_particles(snapshot::AbstractSnapshot, type::Symbol)`
- `read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple})`
- `read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, ids::AbstractVector)`
- `read_particles_in_cuboid(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, lowerleft::AbstractArray, upperright::AbstractArray)`

```@docs
read_prop_simunits
convert_halo_prop
convert_particle_prop!
```
