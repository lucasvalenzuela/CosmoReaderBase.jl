"""
    read_particles(snapshot::AbstractSnapshot[, type::Symbol[, props]]; kwargs...) -> CosmoParticleCollection
    read_particles(snapshot::AbstractSnapshot, typeprops::Tuple) -> CosmoParticleCollection

Returns particles in a snapshot with all or the specified properties.

If the particle type is given, only the particles of that type are read, and if one or more properties are passed
through `props` (as a Symbol or Tuple/AbstractVector of Symbols), only those properties are read.

The value of `typeprops` is a tuple of tuples in the format of `((:dm, (:pos, :vel), (:gas, (:pos, :mass)`.

# Keyword Arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`
- `verbose::Bool=false`: whether the output should be verbose or not
"""
function read_particles end

function read_particles(snapshot::AbstractSnapshot, type::Symbol, prop::Symbol)
    read_particles(snapshot, ((type, (prop,)),))
end
function read_particles(snapshot::AbstractSnapshot, type::Symbol, props::Tuple)
    read_particles(snapshot, ((type, props),))
end
