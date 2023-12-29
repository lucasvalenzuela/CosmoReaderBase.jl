module CosmoReaderBase

import Cosmology
import Cosmology: cosmology, lookback_time
using CosmoParticles
using Unitful

include("cosmosims.jl")
include("particlecollections.jl")
include("halos.jl")
include("reading.jl")
include("readingsubfind.jl")
include("trees.jl")
include("configutils.jl")
include("config_manager.jl")

export
    # Abstract simulation
    has_tree,
    get_tree,
    get_snapshot,
    get_nearest_snapshot,
    get_first_snapshot,
    get_last_snapshot,
    snapshots,
    cosmology,
    lookback_time,
    simulation_time,
    isperiodic,
    is_cosmological,
    boxcorners,
    boxlengths,

    # Simulation
    CosmoSimulation,

    # Snapshot
    AbstractSnapshot,
    get_simulation,
    get_snapshotid,
    prev_snapshot,
    next_snapshot,

    # Particle Collections
    AbstractSimulationParticleCollection,
    SimulationParticleCollection,
    Halo,
    Subhalo,

    # Halos
    Halos,
    Subhalos,

    # Halos and subhalos
    get_subhalos,
    get_halo,
    get_parent_subhalo,
    get_main_subhalo,
    is_main_subhalo,

    # Reading
    read_particles,
    read_particles!,
    read_prop,
    read_halos,
    read_subhalos,
    read_particle_ids,

    # Merger tree
    has_prop,
    get_subhalo,
    get_tree_node,
    first_progenitor,
    first_progenitor_at,
    descendant,
    descendant_at,
    next_progenitor_sibling,
    prev_progenitor_sibling,
    first_progenitor_sibling,
    first_progenitors,
    first_progenitors_and_self,
    descendants,
    descendants_and_self,
    direct_progenitors,
    progenitor_siblings


end
