"""
    abstract type AbstractCosmoReaderConfig end

Abstract type for representing different configurations for cosmological simulations.
"""
abstract type AbstractCosmoReaderConfig end

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
- [`get_cosmology`](@ref)
"""
abstract type AbstractCosmoSimulation end

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

Returns an iterator over the snapshots.
"""
function snapshots(::AbstractCosmoSimulation) end

"""
    get_cosmology(sim::AbstractCosmoSimulation) -> Cosmology.AbstractCosmology

Returns the cosmology associated with the simulation.

See [Cosmology.jl](https://github.com/JuliaAstro/Cosmology.jl).
"""
function get_cosmology(::AbstractCosmoSimulation) end



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
"""
abstract type AbstractSnapshot{ACS} end

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
    get_cosmology(snapshot::AbstractSnapshot) -> Cosmology.AbstractCosmology

Returns the cosmology associated with the simulation of the snapshot.

See [Cosmology.jl](https://github.com/JuliaAstro/Cosmology.jl).
"""
get_cosmology(s::AbstractSnapshot) = get_cosmology(get_simulation(s))
