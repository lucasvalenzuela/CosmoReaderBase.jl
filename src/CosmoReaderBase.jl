module CosmoReaderBase

using Reexport
@reexport using CosmoParticles

export
    # Abstract simulation
    AbstractCosmoReaderConfig,
    AbstractCosmoSimulation,
    has_tree,
    get_tree,
    get_snapshot,
    get_nearest_snapshot,
    get_first_snapshot,
    get_last_snapshot,
    snapshots,
    get_cosmology,

    # Simulation
    CosmoSimulation,

    # Snapshot
    AbstractSnapshot,
    get_simulation,
    get_snapshotid,
    prev_snapshot,
    next_snapshot

include("cosmosims.jl")
include("particlecollections.jl")

end
