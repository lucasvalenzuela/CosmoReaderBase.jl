module ConfigManager

using Unitful

export PropertyConfig,
    ParticleTypeConfig,
    add_property!,
    add_identifier!,
    add_particle_type!,
    set_units!,
    set_rownames!,
    particleidentifier,
    particleindex,
    particlearray,
    particlearrayview

"""
    struct PropertyConfig{T} where {T}
        props::Dict{T,Symbol}
        identifiers::Dict{Symbol,T}
        units::Dict{Symbol,<:Tuple}
        dist_exponents::Dict{Symbol,Int}
        rownames::Dict{Symbol,NTuple}
    end

Configuration struct to manage the properties in a simulation file.

It is recommended to create this configuration object in the following way (by default, `T` will be `String`):
```julia
using CosmoReaderBase.ConfigManager
c = PropertyConfig() # or PropertyConfig{String}()
add_property!(c, "POS", (h -> 1 / h.h0, u"kpc"), 1, :pos, :Coordinates, :POS)
add_property!(c, "ID", (nothing, nothing), :id, :ParticleIDs, :ID)
```

# Attributes
- `props`: `Dict` of the property names saved in the simulation output pointing to the default `Symbol`
  identifier, e.g. `"POS" => :pos`
- `identifiers`: `Dict` of all possible `Symbol` identifiers pointing to the property name in the simulation
  output, e.g. `:pos => "POS"` and `:Coordinates => "POS"`
- `units`: `Dict` of the format `:pos => (f, unit)`, where `f(props)` is the
  factor used to convert simulation units to comoving units (`props` has the fields `h0` and `z`); and `unit`
  is the unitful unit corresponding to the quantity, e.g. `u"kpc"`
- `dist_exponents`: `Dict` of the exponential dependence on distance, e.g. `:pos => 1`, `:vel => 1`,
  or `:rho => -3`. This is necessary for the conversion between comoving and physical quantities.
- `rownames::Dict{Symbol,NTuple}`: `Dict` of the row names of the properties,
  they can be used to create a `NamedRowArray`
"""
struct PropertyConfig{T}
    props::Dict{T,Symbol}
    identifiers::Dict{Symbol,T}
    units::Dict{Symbol,<:Tuple}
    dist_exponents::Dict{Symbol,Int}
    rownames::Dict{Symbol,NTuple}
end
PropertyConfig{T}() where {T} = PropertyConfig(
    Dict{T,Symbol}(),
    Dict{Symbol,T}(),
    Dict{Symbol,Tuple}(),
    Dict{Symbol,Int}(),
    Dict{Symbol,NTuple}(),
)
PropertyConfig() = PropertyConfig{String}()

"""
    add_property!(config::PropertyConfig, prop, units, [dist_exponent], [rownames], identifiers...)
    add_property!(config::PropertyConfig, prop, f, unit, [dist_exponent], [rownames], identifiers...)

Adds the property `prop` with the given parameters to the configuration and returns `config`.

Example usage:
```julia
using CosmoReaderBase.ConfigManager
c = PropertyConfig() # or PropertyConfig{String}()
add_property!(c, "POS", (h -> 1 / h.h0, u"kpc"), 1, :pos, :Coordinates, :POS)
add_property!(c, "ID", (nothing, nothing), :id, :ParticleIDs, :ID)
add_property!(c, "Zs", (nothing, nothing), (:He, :C, :O, :Ej) :zs, :GFM_Metals, :Zs)
```

# Arguments
- `config::PropertyConfig{T}`: the configuration object to which to add the property
- `prop::T`: property name saved in the simulation output, e.g. `"POS"`
- `f::Union{Function,Nothing}`: function where `f(props)` is the factor used to convert simulation units to
  comoving units (`props` has the fields `h0` and `z`), or `nothing` if no conversion is necessary
- `unit::Union{Unitful.Units,Nothing}`: unitful unit corresponding to the quantity, e.g. `u"kpc"`, or `nothing`
  for dimensionless quantities
- `units`: Tuple of the format `(f, unit)` as an alternative to passing `f` and `unit` individually
- `dist_exponent::Union{Integer,Nothing}`: exponential dependence on distance, e.g. `1` for positional and
  velocity quantities, or `-3` for densities. This is necessary for the conversion between comoving and physical
  quantities.
- `rownames::Union{NTuple{N,Symbol},Nothing}`: row names of the property, for example for metals
- `identifiers::Symbol...`: possible identifiers (at least one is needed) for usage when reading properties,
  e.g. `:pos`, `:Coordinates`, `:positions`, etc.
"""
function add_property!(
    c::PropertyConfig,
    prop,
    units::Tuple,
    dist_exponent::Union{Integer,Nothing},
    rownames::Union{NTuple,Nothing},
    default_identifier::Symbol,
    identifiers::Symbol...,
)
    @assert isnothing(rownames) || eltype(rownames) === Symbol

    c.props[prop] = default_identifier
    c.identifiers[default_identifier] = prop
    c.units[default_identifier] = units
    if !isnothing(dist_exponent) && !iszero(dist_exponent)
        c.dist_exponents[default_identifier] = dist_exponent
    end
    if !isnothing(rownames) && !isempty(rownames)
        c.rownames[default_identifier] = rownames
    end

    for identifier in identifiers
        c.identifiers[identifier] = prop
        c.units[identifier] = units
        if !isnothing(dist_exponent) && !iszero(dist_exponent)
            c.dist_exponents[identifier] = dist_exponent
        end
        if !isnothing(rownames) && !isempty(rownames)
            c.rownames[identifier] = rownames
        end
    end

    return c
end

function add_property!(c::PropertyConfig, prop, units::Tuple, identifiers::Symbol...)
    add_property!(c, prop, units, nothing, nothing, identifiers...)
end

function add_property!(c::PropertyConfig, prop, units::Tuple, dist_exponent::Integer, identifiers::Symbol...)
    add_property!(c, prop, units, dist_exponent, nothing, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    units::Tuple,
    rownames::NTuple{N,Symbol},
    identifiers::Symbol...,
) where {N}
    add_property!(c, prop, units, nothing, rownames, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
    identifiers::Symbol...,
)
    add_property!(c, prop, (func_sim_to_comoving, unit), nothing, nothing, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
    rownames::NTuple{N,Symbol},
    identifiers::Symbol...,
) where {N}
    add_property!(c, prop, (func_sim_to_comoving, unit), nothing, rownames, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
    dist_exponent::Integer,
    identifiers::Symbol...,
)
    add_property!(c, prop, (func_sim_to_comoving, unit), dist_exponent, nothing, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
    dist_exponent::Integer,
    rownames::NTuple{N,Symbol},
    identifiers::Symbol...,
) where {N}
    add_property!(c, prop, (func_sim_to_comoving, unit), dist_exponent, rownames, identifiers...)
end

"""
    add_identifier!(config::PropertyConfig, prop, identifier::Symbol)

Adds a further identifier for an already existing property in the configuration and returns `config`.
"""
function add_identifier!(c::PropertyConfig, prop, identifier::Symbol)
    @assert haskey(c.props, prop)
    c.identifiers[identifier] = prop
    return c
end


# """
# set_default_identifier!(config::PropertyConfig, prop, identifier::Symbol)
# 
# Sets the default identifier of `prop` in the configuration and returns `config`.
# 
# The default identifier is returned when 
# """
# function set_default_identifier!(c::PropertyConfig, prop, identifier::Symbol)
# c.props[prop] = identifier
# c.identifiers[identifier] = prop
# return c
# end

"""
    set_units!(c::PropertyConfig, prop, units)
    set_units!(c::PropertyConfig, prop, f, unit)

Modifies the units of an existing property `prop` in the configuration.

The property can be passed by its original name or by any of its identifiers.

# Examples
```julia
using CosmoReaderBase.ConfigManager
c = PropertyConfig()
add_property!(c, "POS", (h -> 1 / h.h0, u"kpc"), 1, :pos, :Coordinates, :POS)
set_units!(c, "POS", (nothing, u"kpc")) # no little h involved

# or using the second syntax with four arguments and using one of the Symbol identifiers:
set_units!(c, :Coordinates, h -> 1000, u"pc") # default to pc instead of kpc
```

See [`add_property!`](@ref) about creating new properties.
"""
function set_units!(c::PropertyConfig, prop, units::Tuple)
    @assert haskey(c.props, prop) "The property config object $prop is not defined, you can define it yourself using `add_property!`."

    identifiers = [key for (key, val) in pairs(c.identifiers) if val == prop]

    for identifier in identifiers
        c.units[identifier] = units
    end

    return c
end

function set_units!(c::PropertyConfig, prop::Symbol, units::Tuple)
    if haskey(c.props, prop)
        @invoke set_units!(c::PropertyConfig, prop::Any, units::Tuple)
    elseif haskey(c.identifiers, prop)
        set_units!(c, c.identifiers[prop], units)
    else
        error("The property config object $prop is not defined, you can define it yourself using `add_property!`.")
    end
end

function set_units!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
)
    set_units!(c, prop, (func_sim_to_comoving, unit))
end

"""
    set_rownames!(c::PropertyConfig, prop, rownames)

Modifies the row names of an existing property `prop` in the configuration.

The property can be passed by its original name or by any of its identifiers.

# Examples
```julia
using CosmoReaderBase.ConfigManager
c = PropertyConfig()
add_property!(c, "Zs", (h -> 1e10 / h.h0, u"Msun"), (:H, :He), :Zs, :Metallicities)
set_rownames!(c, "Zs", (:H, :He, :Fe))

# or removing the rownames entirely:
set_rownames!(c, "Zs", nothing)
```

See [`add_property!`](@ref) about creating new properties.
"""
function set_rownames!(c::PropertyConfig, prop, rownames::Union{Nothing,NTuple{N,Symbol}}) where {N}
    @assert haskey(c.props, prop) "The property config object $prop is not defined, you can define it yourself using `add_property!`."

    identifiers = [key for (key, val) in pairs(c.identifiers) if val == prop]

    for identifier in identifiers
        if isnothing(rownames)
            delete!(c.rownames, identifier)
        else
            c.rownames[identifier] = rownames
        end
    end

    return c
end

function set_rownames!(c::PropertyConfig, prop::Symbol, rownames::Union{Nothing,NTuple{N,Symbol}}) where {N}
    if haskey(c.props, prop)
        @invoke set_rownames!(c::PropertyConfig, prop::Any, rownames::NTuple{Any,Symbol})
    elseif haskey(c.identifiers, prop)
        set_rownames!(c, c.identifiers[prop], rownames)
    else
        error("The property config object $prop is not defined, you can define it yourself using `add_property!`.")
    end
end

"""
    Base.delete!(config::PropertyConfig, prop)

Deletes the property in the configuration if it exists, else assumes it is an identifier and deletes the
identifier for another property (but only if `prop` is a `Symbol`).
"""
function Base.delete!(c::PropertyConfig, prop::Symbol)
    if haskey(c.props, prop)
        @invoke delete!(c::PropertyConfig, prop::Any)
    elseif haskey(c.identifiers, prop)
        delete!(c, c.identifiers[prop])
    end

    return c
end

function Base.delete!(c::PropertyConfig, prop)
    haskey(c.props, prop) || return c

    identifiers = [key for (key, val) in pairs(c.identifiers) if val == prop]

    delete!(c.props, prop)
    for identifier in identifiers
        delete!(c.identifiers, identifier)
        delete!(c.units, identifier)
        delete!(c.dist_exponents, identifier)
        delete!(c.rownames, identifier)
    end

    return c
end

"""
    Base.getindex(config::PropertyConfig, identifier::Symbol)

Returns the property corresponding to the identifier.
"""
Base.getindex(c::PropertyConfig, prop::Symbol) = getindex(c.identifiers, prop)

"""
    Base.getindex(config::PropertyConfig, identifier)

Returns the default identifier corresponding to the property.
"""
Base.getindex(c::PropertyConfig, prop) = getindex(c.props, prop)

"""
    Base.get(config::PropertyConfig, identifier::Symbol, default)

Returns the property corresponding to the identifier, or `default` if the identifier does not exist.
"""
Base.get(c::PropertyConfig, prop::Symbol, default) = get(c.identifiers, prop, default)

"""
    Base.get(config::PropertyConfig, prop, default)

Returns the default identifier corresponding to the property, or `default` if the property does not exist.
"""
Base.get(c::PropertyConfig, prop, default) = get(c.props, prop, default)

"""
    Base.haskey(config::PropertyConfig, identifier::Symbol)

Returns if the identifier exists in the configuration.
"""
Base.haskey(c::PropertyConfig, prop::Symbol) = haskey(c.identifiers, prop)

"""
    Base.haskey(config::PropertyConfig, prop)

Returns if the property exists in the configuration.
"""
Base.haskey(c::PropertyConfig, prop) = haskey(c.props, prop)

Base.copy(c::PropertyConfig) = PropertyConfig(
    copy(c.props),
    copy(c.identifiers),
    copy(c.units),
    copy(c.dist_exponents),
    copy(c.rownames),
)

"""
    properties(c::PropertyConfig, available_props=nothing; private=startswith("_"))

Returns the available properties as a `NamedTuple` vector.

The table has the following column names:
- `prop`: the property name as saved in the simulation output
- `unit`: the unit of the property, or `nothing` if unitless
- `identifiers`: the possible identifiers of the property
- `rownames`: row names of the properties, else `nothing`
- `available`: `true`, `false`, or `missing`, depending on whether the property is actually available for the
  current simulation at hand

# Arguments
- `available_props`: vector of properties that are available from the simulation output, used for the `available`
  column
- `private=startswith("_")`: function that takes a property name and returns true if it should not be output in
  the table

See also [`CosmoReaderBase.particle_properties`](@ref), [`CosmoReaderBase.halo_properties`](@ref), [`CosmoReaderBase.subhalo_properties`](@ref), which require
the format returned here.

This is not exported.
"""
function properties(c::PropertyConfig, available_props=nothing; private=startswith("_"))
    if !isnothing(available_props)
        avail = Set(available_props)
    else
        avail = nothing
    end

    arr = [(; prop, unit=c.units[ident][2], identifiers=_get_identifiers(c, prop), rownames=get(c.rownames, prop, Symbol[]), available=isnothing(avail) ? missing : prop in avail) for (prop, ident) in pairs(c.props) if !(private(prop))]

    # add properties that are available but not contained in the property config
    additional_props = setdiff(avail, keys(c.props))
    for prop in additional_props
        push!(arr, (; prop, unit=nothing, identifiers=Symbol[], rownames=Symbol[], available=true))
    end

    return arr
end

function _get_identifiers(c::PropertyConfig{T}, prop::T) where {T}
    [identifier for (identifier, p) in pairs(c.identifiers) if p == prop]
end


function Base.show(io::IO, mime::MIME"text/plain", c::PropertyConfig)
    printstyled(io, "PropertyConfig: "; bold=true)
    print(io, join(keys(c.props), ", "))
end




"""
    struct ParticleTypeConfig{T}
        props::Dict{T,Symbol}
        identifiers::Dict{Symbol,T}
        index::Dict{Symbol,Int}
    end

Configuration struct to manage the particle types in a simulation file.

It is recommended to create this configuration object in the following way (where in this example the first
number indicates the particle name, such as the 0-based index in Gadget format 2, and the second number is the
1-based index that Julia is supposed to use when indexing into arrays):
```julia
using CosmoReaderBase.ConfigManager
c = ParticleTypeConfig{Int}()
add_particle_type!(c, 0, :gas, 1)
add_particle_type!(c, 1, :dm, 2)
add_particle_type!(c, 4, :stars, 5)
```

# Attributes
- `props`: `Dict` of the particle type names saved in the simulation output pointing to the default `Symbol`
  identifier, e.g. `0 => :gas` or `"PartType0" => :gas`
- `identifiers`: `Dict` of the `Symbol` identifiers pointing to the particle type name in the simulation output,
  e.g. `:gas => 0` or `:gas => "PartType0"`
- `indices`: `Dict` of the 1-based indices with which Julia should access arrays, e.g. `:gas => 1`, `:dm => 2`
"""
struct ParticleTypeConfig{T}
    props::Dict{T,Symbol}
    identifiers::Dict{Symbol,T}
    indices::Dict{Symbol,Int}
end

ParticleTypeConfig{T}() where {T} = ParticleTypeConfig(Dict{T,Symbol}(), Dict{Symbol,T}(), Dict{Symbol,Int}())

"""
    add_particle_type!(config::ParticleTypeConfig, prop, identifier, index)

Adds the particle type `prop` with the given identifier and 1-based index to the configuration and returns `config`.

Example usage:
```julia
using CosmoReaderBase.ConfigManager
c = ParticleTypeConfig{Int}()
add_particle_type!(c, 0, :gas, 1)
add_particle_type!(c, 1, :dm, 2)
add_particle_type!(c, 4, :stars, 5)
```

# Arguments
- `config::ParticleTypeConfig{T}`: the configuration object to which to add the particle type
- `prop::T`: particle type name saved in the simulation output, e.g. `0` or `"PartType0"`
- `identifier::Symbol`: `Symbol` identifier of the particle type, e.g. `:gas` or `:dm`
- `index::Int`: 1-based indices with which Julia should access arrays for the particle type, e.g. `1` or `2`
"""
function add_particle_type!(c::ParticleTypeConfig, prop, identifier, index)
    c.props[prop] = identifier
    c.identifiers[identifier] = prop
    c.indices[identifier] = index

    return c
end

"""
    Base.delete!(config::ParticleTypeConfig, prop)

Deletes the particle in the configuration if it exists, else assumes it is an identifier and deletes the
identifier for another particle (but only if `prop` is a `Symbol`).
"""
function Base.delete!(c::ParticleTypeConfig, prop::Symbol)
    if haskey(c.props, prop)
        @invoke delete!(c::ParticleTypeConfig, prop::Any)
    elseif haskey(c.identifiers, prop)
        delete!(c, c.identifiers[prop])
    end

    return c
end

function Base.delete!(c::ParticleTypeConfig, prop)
    haskey(c.props, prop) || return c

    identifier = c.props[prop]

    delete!(c.props, prop)
    delete!(c.identifiers, identifier)
    delete!(c.indices, identifier)

    return c
end

"""
    Base.getindex(config::ParticleTypeConfig, identifier::Symbol)

Returns the property corresponding to the identifier.
"""
Base.getindex(c::ParticleTypeConfig, identifier::Symbol) = getindex(c.identifiers, identifier)

"""
    Base.get(config::ParticleTypeConfig, identifier::Symbol, default)

Returns the property corresponding to the identifier, or `default` if the identifier does not exist.
"""
Base.get(c::ParticleTypeConfig, identifier::Symbol, default) = get(c.identifiers, identifier, default)

"""
    Base.haskey(config::ParticleTypeConfig, identifier::Symbol)

Returns if the identifier exists in the configuration.
"""
Base.haskey(c::ParticleTypeConfig, identifier::Symbol) = haskey(c.identifiers, identifier)

Base.copy(c::ParticleTypeConfig) = ParticleTypeConfig(copy(c.props), copy(c.identifiers), copy(c.indices))

"""
    particleidentifier(config::ParticleTypeConfig, prop)

Returns the identifier corresponding to the particle type name.
"""
particleidentifier(c::ParticleTypeConfig, prop) = getindex(c.props, prop)

"""
    particleindex(config::ParticleTypeConfig, identifier::Symbol)

Returns the 1-based index corresponding to the particle type identifier.
"""
particleindex(c::ParticleTypeConfig, identifier::Symbol) = getindex(c.indices, identifier)

"""
    particlearray(config::ParticleTypeConfig, identifier::Symbol, a::AbstractVector)

Returns `a[particleindex]` with the index given by the config for the particle identifier.

This is relevant for the mass table array, for example:
```julia
using CosmoReaderBase.ConfigManager
config::ParticleTypeConfig # set up as seen in ParticleTypeConfig docstring
masstab = rand(6)
particlearray(config, :dm, masstab)
```

See also [`particlearrayview`](@ref).
"""
particlearray(c::ParticleTypeConfig, identifier::Symbol, a::AbstractVector) = a[particleindex(c, identifier)]

"""
    particlearray(config::ParticleTypeConfig, identifier::Symbol, a::AbstractMatrix)

Returns `a[particleindex, :]` with the index given by the config for the particle identifier.

This is relevant for the subhalo mass table array, for example:
```julia
using CosmoReaderBase.ConfigManager
config::ParticleTypeConfig # set up as seen in ParticleTypeConfig docstring
smst = rand(6, 100)
particlearray(config, :dm, smst)
```

See also [`particlearrayview`](@ref).
"""
particlearray(c::ParticleTypeConfig, identifier::Symbol, a::AbstractMatrix) =
    a[particleindex(c, identifier), :]

"""
    particlearrayview(config::ParticleTypeConfig, identifier::Symbol, a::AbstractMatrix)

Returns `@view a[particleindex, :]` with the index given by the config for the particle identifier.

This is relevant for the subhalo mass table array, for example:
```julia
using CosmoReaderBase.ConfigManager
config::ParticleTypeConfig # set up as seen in ParticleTypeConfig docstring
smst = rand(6, 100)
particlearrayview(config, :dm, smst)
```

See also [`particlearray`](@ref).
"""
particlearrayview(c::ParticleTypeConfig, identifier::Symbol, a::AbstractMatrix) =
    @view a[particleindex(c, identifier), :]


function Base.show(io::IO, mime::MIME"text/plain", c::ParticleTypeConfig)
    printstyled(io, "ParticleTypeConfig: "; bold=true)
    print(io, join(keys(c.identifiers), ", "))
end

end # module
