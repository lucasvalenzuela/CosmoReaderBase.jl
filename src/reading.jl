"""
    read_all_particles(snapshot::AbstractSnapshot[, type::Symbol]; kwargs...) -> CosmoParticleCollection

Returns all particles in a snapshot with all available properties.

If the particle type is given, only the particles of that type are read.

Note that this may take very long for large simulations. It is recommended to generally use [`read_particles`](@ref)
and specify which particle types. and properties should be read.

# Keyword Arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`
- `verbose::Bool=false`: whether the output should be verbose or not
"""
function read_all_particles end

"""
    read_particles(snapshot::AbstractSnapshot[, typeprops]) -> CosmoParticleCollection
    read_particles(snapshot::AbstractSnapshot, type::Symbol, props) -> CosmoParticleCollection

Returns all particles of the specified types and properties.

The default value of `typeprops` is `((:dm, (:pos, :vel), (:gas, (:pos, :mass)`.
For the second method, the parameter `props` can be a Symbol or a Tuple of Symbols.

See [`read_all_particles`](@ref) for allowed keyword arguments.
"""
function read_particles end

function read_particles(snapshot::AbstractSnapshot, type::Symbol, prop::Symbol)
    read_particles(snapshot, ((type, (prop,)),))
end
function read_particles(snapshot::AbstractSnapshot, type::Symbol, props::Tuple)
    read_particles(snapshot, ((type, props),))
end
