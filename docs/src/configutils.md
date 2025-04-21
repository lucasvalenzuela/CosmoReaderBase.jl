```@meta
CurrentModule = CosmoReaderBase
```

# Utils

## Configuration Utils

### Property Configuration

Use `PropertyConfig` to create the configuration for particle and subfind properties
found in simulation files.

```@docs
ConfigManager.PropertyConfig
ConfigManager.add_property!
ConfigManager.add_identifier!
ConfigManager.set_units!
ConfigManager.set_rownames!
ConfigManager.delete!(::ConfigManager.PropertyConfig, ::Symbol)
ConfigManager.getindex(::ConfigManager.PropertyConfig, ::Symbol)
ConfigManager.getindex(::ConfigManager.PropertyConfig, _)
ConfigManager.get(::ConfigManager.PropertyConfig, ::Symbol, _)
ConfigManager.get(::ConfigManager.PropertyConfig, _, _)
ConfigManager.haskey(::ConfigManager.PropertyConfig, ::Symbol)
ConfigManager.haskey(::ConfigManager.PropertyConfig, _)
ConfigManager.properties
```

### Particle Type Configuration

Use `ParticleTypeConfig` to create the configuration for the particle types found in a simulation,
that is gas, stars, dark matter, disk, bulge, etc.

```@docs
ConfigManager.ParticleTypeConfig
ConfigManager.add_particle_type!
ConfigManager.particleidentifier
ConfigManager.particleindex
ConfigManager.particlearray
ConfigManager.particlearrayview
ConfigManager.delete!(::ConfigManager.ParticleTypeConfig, ::Symbol)
ConfigManager.getindex(::ConfigManager.ParticleTypeConfig, ::Symbol)
ConfigManager.get(::ConfigManager.ParticleTypeConfig, ::Symbol, _)
ConfigManager.haskey(::ConfigManager.ParticleTypeConfig, ::Symbol)
```


## Developer Utils

```@docs
AbstractSnapParams
SnapParams
convert_by_factor
convert_sim_to
convert_to_sim
assert_unit_type
assert_pos_of_unit_type
```
