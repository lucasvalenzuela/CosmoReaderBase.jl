```@meta
CurrentModule = CosmoReaderBase
```

# Simulation

A cosmological simulation of type [`CosmoSimulation`](@ref) will generally consist of the path it is
located at and of a configuration struct of type [`AbstractCosmoReaderConfig`](@ref), which typically contains the
information on the snapshot naming system, on the available particle types, and on the property names and units.
Different backends for concrete simulation types implement this API individually.

## General Simulations

```@docs
AbstractCosmoSimulation
has_tree
get_tree(::AbstractCosmoSimulation)
get_snapshot(::AbstractCosmoSimulation, snapid)
get_nearest_snapshot
get_first_snapshot
get_last_snapshot
snapshots
cosmology(::AbstractCosmoSimulation)
isperiodic
is_cosmological
boxcorners(::AbstractCosmoSimulation)
boxlengths(::AbstractCosmoSimulation)
CosmoReaderBase.get_name
```

## Simulations with Configs

```@docs
AbstractCosmoReaderConfig
CosmoSimulation
CosmoReaderBase.get_config(::CosmoSimulation)
CosmoReaderBase.get_dir
```

## Snapshots

```@docs
AbstractSnapshot
get_simulation
get_snapshotid
CosmoReaderBase.get_config(::AbstractSnapshot)
prev_snapshot
next_snapshot
CosmoParticles.redshift
lookback_time
simulation_time
cosmology(::AbstractSnapshot)
boxcorners(s::AbstractSnapshot)
boxlengths(::AbstractSnapshot)
```

For developers implementing the interface:
```@docs
simulation_time_isolated
```
