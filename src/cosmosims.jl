"""
    abstract type AbstractCosmoReaderConfig end

Abstract type for representing different configurations for cosmological simulations.

This is not exported.
"""
abstract type AbstractCosmoReaderConfig end

Base.broadcastable(config::AbstractCosmoReaderConfig) = Ref(config)

"""
    abstract type AbstractCosmoSimulation end

Abstract type for representing a cosmological simulation.

Subtypes have to implement the following methods:
- [`has_tree`](@ref)
- [`get_tree`](@ref)
- [`get_snapshot`](@ref)
- [`get_nearest_snapshot`](@ref)
- [`get_first_snapshot`](@ref)
- [`get_last_snapshot`](@ref)
- [`snapshots`](@ref)
- [`cosmology`](@ref)
- [`isperiodic`](@ref)
- [`boxcorners`](@ref)
- [`boxlengths`](@ref)
- [`get_name`](@ref)
- [`get_config`](@ref): if `config` is not a field
- [`get_dir`](@ref): if `dir` is not a field

This is not exported.
"""
abstract type AbstractCosmoSimulation end

Base.broadcastable(sim::AbstractCosmoSimulation) = Ref(sim)

"""
    has_tree(sim::AbstractCosmoSimulation)

Returns whether the simulation has a merger tree or not.
"""
has_tree(::AbstractCosmoSimulation) = false

"""
    get_tree(sim::AbstractCosmoSimulation) -> AbstractMergerTree

Returns the merger tree, or `nothing` if it does not exist for the simulation.

Note: Merger trees are still under development and currently not supported.
"""
get_tree(::AbstractCosmoSimulation) = nothing

"""
    get_snapshot(sim::AbstractCosmoSimulation, snapid) -> AbstractSnapshot

Returns the simulation's snapshot of the given `snapid`.
"""
function get_snapshot(::AbstractCosmoSimulation, snapid) end

"""
    get_nearest_snapshot(sim::AbstractCosmoSimulation, z::Real) -> AbstractSnapshot

Returns the nearest snapshot of the simulation to the redshift `z`.
"""
function get_nearest_snapshot(::AbstractCosmoSimulation, z::Real) end

"""
    get_first_snapshot(sim::AbstractCosmoSimulation) -> AbstractSnapshot

Returns the first snapshot of the simulation, i.e., the one at the highest redshift.
"""
function get_first_snapshot(::AbstractCosmoSimulation) end

"""
    get_last_snapshot(sim::AbstractCosmoSimulation) -> AbstractSnapshot

Returns the last snapshot of the simulation, i.e., the one at the lowest redshift.
"""
function get_last_snapshot(::AbstractCosmoSimulation) end

"""
    snapshots(sim::AbstractCosmoSimulation)

Returns an iterator over the snapshots from earliest to latest in time.

Keyword Arguments
- `rev::Bool=false`: if `true`, the latest snapshots will be iterated over first
"""
function snapshots(::AbstractCosmoSimulation) end

"""
    Cosmology.cosmology(sim::AbstractCosmoSimulation) -> Cosmology.AbstractCosmology

Returns the cosmology associated with the simulation.

See [Cosmology.jl](https://github.com/JuliaAstro/Cosmology.jl).
"""
function cosmology(::AbstractCosmoSimulation) end

"""
    isperiodic(sim::AbstractCosmoSimulation) -> Bool

Returns whether the simulated volume is periodic or not.
"""
function isperiodic(::AbstractCosmoSimulation) end

"""
    boxcorners(sim::AbstractCosmoSimulation) -> Vector, Vector

Returns a tuple of the lower left and upper right corners.

# Keyword Arguments
- `units::Symbol=:comoving`: has to be `:sim` or `:comoving` for simulation or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`
"""
function boxcorners(::AbstractCosmoSimulation) end

"""
    boxlengths(sim::AbstractCosmoSimulation) -> Vector

Returns a vector of the side lengths along the three axes.

# Keyword Arguments
- `units::Symbol=:comoving`: has to be `:sim` or `:comoving` for simulation or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`
"""
function boxlengths(sim::AbstractCosmoSimulation; kwargs...)
    corners = boxcorners(sim; kwargs...)
    return corners[2] .- corners[1]
end

"""
    get_name(::AbstractCosmoSimulation)

Returns the name of the simulation.

This is not exported.
"""
function get_name(::AbstractCosmoSimulation) end



"""
    struct CosmoSimulation{C<:AbstractCosmoReaderConfig,T} <: AbstractCosmoSimulation
        config::C
        dir::T
    end

Cosmological simulation with an associated configuration object and a main directory.

The methods defined for [`AbstractCosmoSimulation`](@ref) need to be implemented for concrete types of
configuration types, e.g., by `has_tree(::CosmoSimulation{ConcreteCosmoReaderConfig})`.
"""
struct CosmoSimulation{C<:AbstractCosmoReaderConfig,T} <: AbstractCosmoSimulation
    config::C
    dir::T
end

"""
    get_config(cs::CosmoSimulation) -> AbstractCosmoReaderConfig

Returns the configuration object associated with the simulation.

This is not exported.
"""
get_config(cs::CosmoSimulation) = cs.config

"""
    get_dir(cs::CosmoSimulation)

Returns the directory of the simulation.

This is not exported.
"""
get_dir(cs::CosmoSimulation) = cs.dir


"""
    abstract type AbstractSnapshot{AbstractCosmoSimulation} end

Abstract type for representing simulation snapshots in time.

Usually has the fields `sim::<:AbstractCosmoSimulation` and `id`.

Subtypes have to implement the following methods:
- [`prev_snapshot`](@ref)
- [`next_snapshot`](@ref)
- [`CosmoParticles.redshift`](@ref)
- [`get_simulation`](@ref) if `sim` is not a field
- [`get_snapshotid`](@ref) if `id` is not a field

This is not exported.
"""
abstract type AbstractSnapshot{ACS} end

Base.broadcastable(s::AbstractSnapshot) = Ref(s)

"""
    get_simulation(snapshot::AbstractSnapshot) -> AbstractCosmoSimulation

Returns the simulation to which the snapshot belongs.
"""
get_simulation(s::AbstractSnapshot) = s.sim

"""
    get_snapshotid(snapshot::AbstractSnapshot)

Returns the id of the snapshot.
"""
get_snapshotid(s::AbstractSnapshot) = s.id

"""
    get_config(snapshot::AbstractSnapshot) -> AbstractCosmoReaderConfig

Returns the configuration object associated with the snapshot.

This is not exported.
"""
get_config(s::AbstractSnapshot) = get_config(get_simulation(s))

"""
    prev_snapshot(snapshot::AbstractSnapshot) -> AbstractSnapshot

Returns the previous existing snapshot.
"""
function prev_snapshot(::AbstractSnapshot) end

"""
    next_snapshot(snapshot::AbstractSnapshot) -> AbstractSnapshot

Returns the next existing snapshot.
"""
function next_snapshot(::AbstractSnapshot) end

"""
    CosmoParticles.redshift(snapshot::AbstractSnapshot)

Returns the redshift of the snapshot.
"""
function CosmoParticles.redshift(::AbstractSnapshot) end

"""
    Cosmology.cosmology(snapshot::AbstractSnapshot) -> Cosmology.AbstractCosmology

Returns the cosmology associated with the simulation of the snapshot.

See [Cosmology.jl](https://github.com/JuliaAstro/Cosmology.jl).
"""
cosmology(s::AbstractSnapshot) = cosmology(get_simulation(s))

"""
    boxcorners(snapshot::AbstractSnapshot) -> Vector, Vector

Returns a tuple of the lower left and upper right corners.

# Keyword Arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`.
"""
function boxcorners(s::AbstractSnapshot; units::Symbol=:physical, unitful::Bool=false)
    sim = get_simulation(s)
    if units === :physical
        a = 1 / (1 + redshift(s))
        corners = boxcorners(sim; units=:comoving, unitful)
        return corners[1] * a, corners[2] * a
    else
        return boxcorners(sim; units, unitful)
    end
end

"""
    boxlengths(snapshot::AbstractSnapshot) -> Vector

Returns a vector of the side lengths along the three axes.

# Keyword Arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`.
"""
function boxlengths(s::AbstractSnapshot; units::Symbol=:physical, unitful::Bool=false)
    sim = get_simulation(s)
    if units === :physical
        a = 1 / (1 + redshift(s))
        return boxlengths(sim; units=:comoving, unitful) * a
    else
        return boxlengths(sim; units, unitful)
    end
end
