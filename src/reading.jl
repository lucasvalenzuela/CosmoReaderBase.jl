"""
    read_particles(snapshot::AbstractSnapshot[, type::Symbol[, props]]; kwargs...) -> CosmoParticleCollection
    read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}) -> CosmoParticleCollection

Returns particles in a snapshot with all or the specified properties.

If the particle type is given, only the particles of that type are read, and if one or more properties are passed
through `props` (as a Symbol or AbstractVector of Symbols), only those properties are read.

The value of `typeprops` is a vector of tuples in the format of `[(:dm, [:pos, :vel]), (:gas, [:pos, :mass])]`.

# Keyword arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`
- `verbose::Bool=false`: whether the output should be verbose or not
"""
function read_particles(::AbstractSnapshot) end

# to implement:
# read_particles(snapshot::AbstractSnapshot)
# read_particles(snapshot::AbstractSnapshot, type::Symbol)
# read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple})
# read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, ids::AbstractVector)
# read_particles(halo::AbstractHalo, typeprops::AbstractVector{<:Tuple})
# read_particles_in_cuboid(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, lowerleft::AbstractArray, upperright::AbstractArray)

function read_particles(snapshot::AbstractSnapshot, type::Symbol, prop::Symbol; kwargs...)
    read_particles(snapshot, ((type, (prop,)),); kwargs...)
end
function read_particles(snapshot::AbstractSnapshot, type::Symbol, props::AbstractVector; kwargs...)
    read_particles(snapshot, ((type, props),); kwargs...)
end

"""
    read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, ids::AbstractVector[, centerpos, radius]) -> CosmoParticleCollection


Returns the particles with the given IDs in a snapshot with the specified properties.

If a center position and radius are given, only the particles in at least the volume of such a surrounding cube
are read and filtered by their IDs. Particles are shifted across the box borders if the volume reaches across the
borders and the box is periodic. Depending on the implementation it is also possible that a larger volume is
read in first and particles outside the cube are read in.


# Keyword arguments
- `shift_to_center=false`: if `true`, the particle positions are shifted such that `centerpos` becomes the
  origin. Particles are shifted across the box borders if the box is periodic. This is ignored if `centerpos` is
  not given.

For the format of `typeprops` and the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref).
"""
function read_particles(::AbstractSnapshot, ::AbstractVector{<:Tuple}, ::AbstractVector) end

function read_particles(
    snapshot::AbstractSnapshot,
    typeprops::AbstractVector{<:Tuple},
    ids::AbstractVector,
    centerpos::AbstractVector,
    radius::Number;
    kwargs...,
)
    pc = read_particles_in_cuboid(snapshot, typeprops, centerpos .- radius, centerpos .+ radius; kwargs...)
    filter!(pc; ids)
    return pc
end

"""
    read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, geo::AbstractCosmoGeometry) -> CosmoParticleCollection
    read_particles(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, geo::CosmoHyperrectangle; exact=false) -> CosmoParticleCollection

Returns the particles within a given volume in a snapshot with the specified properties.

Particles are shifted across the box borders if the volume reaches across the borders and the box is periodic.

# Keyword arguments
- `posprop=:pos`: name of the position property by which to filter the read-in particles
- `shift_to_center=false`: if `true`, the particle positions are shifted such that `centerpos` becomes the
  origin. Particles are shifted across the box borders if the box is periodic. This is ignored if `centerpos` is
  not given.

For further possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref).
"""
function read_particles(
    snapshot::AbstractSnapshot,
    typeprops::AbstractVector{<:Tuple},
    geo::AbstractCosmoGeometry;
    posprop=:pos,
    kwargs...,
)
    lowerleft, upperright = CosmoParticles.geometry_enclosing_corners(geo)
    pc = read_particles_in_cuboid(snapshot, typeprops, lowerleft, upperright; kwargs...)
    filter!(pc, geo, posprop)
    return pc
end

function read_particles(
    snapshot::AbstractSnapshot,
    typeprops::AbstractVector{<:Tuple},
    geo::CosmoHyperrectangle;
    posprop=:pos,
    exact=false,
    kwargs...,
)
    lowerleft, upperright = CosmoParticles.geometry_enclosing_corners(geo)
    pc = read_particles_in_cuboid(snapshot, typeprops, lowerleft, upperright; kwargs...)
    exact && filter!(pc, geo, posprop)
    return pc
end

"""
    read_particles!(halo::AbstractHalo, typeprops::AbstractVector{<:Tuple}[, radius])
    read_particles!(halo::AbstractHalo, pc::AbstractParticleCollection[, typeprops::AbstractVector{<:Tuple}][, radius])

Returns the particles within the given halo with the specified properties.

For the second method, the particles are purely read from the particle collection `pc`. If `typeprops` are not
given, all available particle types and properties are filtered. The units passed should be the same as the
particle collection was read in with.

Particles are shifted across the box borders if the halo reaches across the borders and the box is periodic.

# Optional arguments
- `radius`: A Number or a radius property of the halo as a Symbol to indicate what cubic volume around the halo's
  center should be read in. When a Number is passed, the units are assumed to be identical to the ones requested
  of the particles to read in.

# Keyword arguments
- `rscale::Real=1`: If `radius` given, it is multiplied by rscale to determine the cubic volume to read in. This
  is especially relevant for when `radius` is a halo property.
- `shift_to_center=false`: if `true`, the particle positions are shifted such that `centerpos` becomes the
  origin. Particles are shifted across the box borders if the box is periodic. This is ignored if `centerpos` is
  not given.

For further possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref).
"""
function read_particles!(::AbstractHalo, ::AbstractVector{<:Tuple}) end

_get_val_or_halo_prop(val::Number, _, _, _) = val
_get_val_or_halo_prop(prop::Symbol, halo, units, unitful) = read_prop(halo, prop; units, unitful)

function read_particles!(
    halo::AbstractHalo,
    typeprops::AbstractVector{<:Tuple},
    radius::Union{Number,Symbol};
    rscale::Real=1,
    units::Symbol=:physical,
    unitful::Bool=false,
    kwargs...,
)
    centerpos = read_prop(halo, :pos; units, unitful)
    r = rscale * _get_val_or_halo_prop(radius, halo, units, unitful)
    pc = read_particles_in_cuboid(halo, typeprops, centerpos .- r, centerpos .+ r; units, unitful, kwargs...)

    ids = read_particle_ids(halo)
    copy!(halo, filter(pc; ids))
    return halo
end

function read_particles!(
    halo::AbstractHalo,
    pc::AbstractParticleCollection,
    typeprops::Union{AbstractVector{<:Tuple},Nothing}=nothing;
    shift_to_center::Bool=false,
    units::Symbol=:physical,
    unitful::Bool=false,
    posprop::Symbol=:pos,
)
    ids = read_particle_ids(halo)
    copy!(halo, filter(pc; ids, affect=typeprops))

    # shift according to halo center
    centerpos = read_prop(halo, :pos; units, unitful)
    if shift_to_center
        translate_periodic_to_center!(halo, centerpos, posprop)
    else
        translate_periodic!(halo, centerpos, posprop)
    end
    return halo
end

function read_particles!(
    halo::AbstractHalo,
    pc::AbstractParticleCollection,
    typeprops::AbstractVector{<:Tuple},
    radius::Union{Number,Symbol};
    rscale::Real=1,
    shift_to_center::Bool=false,
    units::Symbol=:physical,
    unitful::Bool=false,
    posprop::Symbol=:pos,
    forceshift::Bool=false,
)
    centerpos = read_prop(halo, :pos; units, unitful)
    r = rscale * _get_val_or_halo_prop(radius, halo, units, unitful)

    sim = get_snapshot(pc) |> get_simulation

    # shift according to halo center and check if volume not inside box for periodic boxes
    if isperiodic(sim)
        lowerleft, upperright = boxcorners(sim)
        if any(centerpos .- r .≤ lowerleft) || any(centerpos .+ r .≥ upperright) || forceshift
            if shift_to_center
                pc = translate_periodic_to_center(pc, centerpos, posprop)
            else
                pc = translate_periodic(pc, centerpos, posprop)
            end
        elseif shift_to_center
            pc = translate(pc, -centerpos, posprop)
        end
    elseif shift_to_center
        pc = translate(pc, -centerpos, posprop)
    end

    pc_halo = filter(pc, CosmoHypercube(centerpos, r); affect=typeprops)

    ids = read_particle_ids(halo)
    copy!(halo, filter!(pc_halo; ids))
    return halo
end

function read_particles!(
    halo::AbstractHalo,
    pc::AbstractParticleCollection,
    radius::Union{Number,Symbol};
    kwargs...,
)
    read_particles!(halo, pc, nothing, radius; kwargs...)
end

"""
    read_particles_in_cuboid(snapshot::AbstractSnapshot, typeprops::AbstractVector{<:Tuple}, lowerleft::AbstractArray, upperright::AbstractArray) -> CosmoParticleCollection

Returns the particles within the cuboid given by the lower left and upper right corner in a snapshot with the
specified properties.
Particles are shifted across the box borders if the cuboid reaches across the borders and the box is periodic.

# Keyword arguments
For the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref), and additionally:
- `shift_to_center=false`: if `true`, the particle positions are shifted such that `centerpos` becomes the
  origin. Particles are shifted across the box borders if the box is periodic. This is ignored if `centerpos` is
  not given.

This is not exported.
"""
function read_particles_in_cuboid(
    ::AbstractSnapshot,
    ::AbstractVector{<:Tuple},
    ::AbstractArray,
    ::AbstractArray,
) end

"""
    read_particle_ids(::AbstractHalo) -> Vector

Returns the particle IDs of the halo.

This is not exported.
"""
function read_particle_ids(::AbstractHalo) end

"""
    read_prop(halo::AbstractHalo, prop::Symbol)

Returns the halo property.

This function caches the value in simulation units and uses the cached value if available.

# Keyword arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`
- `verbose::Bool=false`: whether the output should be verbose or not
"""
function read_prop(halo::AbstractHalo, prop::Symbol; units::Symbol=:physical, unitful::Bool=false, kwargs...)
    val = haskey(halo.props, prop) ? halo.props[prop] : read_prop_simunits(halo, prop; kwargs...)
    return convert_halo_prop(val, prop, get_snapshot(halo) |> get_simulation; units, unitful)
end

"""
    read_prop_simunits(halo::AbstractHalo, prop::Symbol; verbose=false)

Returns the halo property in simulation units.

Contrary to [`read_prop`](@ref), this function always reads in the value from the simulation.

This is not exported.
"""
function read_prop_simunits(::AbstractHalo, ::Symbol) end

"""
    convert_halo_prop(val, prop::Symbol, sim::AbstractCosmoSimulation; units::Symbol, unitful::Bool)

Returns the halo's property or properties converted from simulation units to the specified units.

For the allowed values of `units` and `unitful`, see [`read_prop`](@ref).
The passed value can be a scalar value (`Number`) or an array of values (`AbstractArray`).

This is not exported.
"""
function convert_halo_prop(_, ::Symbol, ::AbstractCosmoSimulation) end


"""
    convert_particle_prop(val, prop::Symbol, sim::AbstractCosmoSimulation; units::Symbol, unitful::Bool)

Returns the particles' property or properties converted from simulation units to the specified units.

For the allowed values of `units` and `unitful`, see [`read_prop`](@ref).
The passed value can be a scalar value (`Number`) or an array of values (`AbstractArray`).

This is not exported.
"""
function convert_particle_prop(_, ::Symbol, ::AbstractCosmoSimulation) end
