module ConfigManager

using Unitful

export PropertyConfig, add_property!, add_identifier!#, set_default_identifier!

"""
    struct PropertyConfig{T} where {T}
        props::Dict{T,Symbol}
        identifiers::Dict{Symbol,T}
        units::Dict{Symbol,<:Tuple}
        dist_exponents::Dict{Symbol,Int}
    end

Configuration struct to manage the properties in a simulation file.

It is recommended to create this configuration object in the following way (by default, `T` will be `String`):
```julia
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
"""
struct PropertyConfig{T}
    props::Dict{T,Symbol}
    identifiers::Dict{Symbol,T}
    units::Dict{Symbol,<:Tuple}
    dist_exponents::Dict{Symbol,Int}
end
PropertyConfig{T}() where {T} = PropertyConfig(Dict{T,Symbol}(), Dict{Symbol,T}(), Dict{Symbol,Tuple}(), Dict{Symbol,Int}())
PropertyConfig() = PropertyConfig{String}()

"""
    add_property!(config::PropertyConfig, prop, units, [dist_exponent], identifiers...)
    add_property!(config::PropertyConfig, prop, f, unit, [dist_exponent], identifiers...)

Adds the property `prop` with the given parameters to the configuration and returns `config`.

Example usage:
```julia
c = PropertyConfig() # or PropertyConfig{String}()
add_property!(c, "POS", (h -> 1 / h.h0, u"kpc"), 1, :pos, :Coordinates, :POS)
add_property!(c, "ID", (nothing, nothing), :id, :ParticleIDs, :ID)
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
- `identifiers::Symbol...`: possible identifiers (at least one is needed) for usage when reading properties,
  e.g. `:pos`, `:Coordinates`, `:positions`, etc.
"""
function add_property!(
    c::PropertyConfig,
    prop,
    units::Tuple,
    dist_exponent::Union{Integer,Nothing},
    default_identifier::Symbol,
    identifiers::Symbol...,
)
    c.props[prop] = default_identifier
    c.identifiers[default_identifier] = prop
    c.units[default_identifier] = units
    if !isnothing(dist_exponent) && !iszero(dist_exponent)
        c.dist_exponents[default_identifier] = dist_exponent
    end

    for identifier in identifiers
        c.identifiers[identifier] = prop
        c.units[identifier] = units
        if !isnothing(dist_exponent) && !iszero(dist_exponent)
            c.dist_exponents[identifier] = dist_exponent
        end
    end

    return c
end

function add_property!(
    c::PropertyConfig,
    prop,
    units::Tuple,
    identifiers::Symbol...,
)
    add_property!(c, prop, units, nothing, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
    identifiers::Symbol...,
)
    add_property!(c, prop, (func_sim_to_comoving, unit), nothing, identifiers...)
end

function add_property!(
    c::PropertyConfig,
    prop,
    func_sim_to_comoving::Union{Function,Nothing},
    unit::Union{Unitful.Units,Nothing},
    dist_exponent::Integer,
    identifiers::Symbol...,
)
    add_property!(c, prop, (func_sim_to_comoving, unit), dist_exponent, identifiers...)
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
end

function Base.delete!(c::PropertyConfig, prop)
    haskey(c.props, prop) || return c

    identifiers = [key for (key, val) in pairs(c.identifiers) if val == prop]

    delete!(c.props, prop)
    for identifier in identifiers
        delete!(c.identifiers, identifier)
        delete!(c.units, identifier)
        delete!(c.dist_exponents, identifier)
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

Base.copy(c::PropertyConfig) = PropertyConfig(copy(c.props), copy(c.identifiers), copy(c.units), copy(c.dist_exponents))

function Base.show(io::IO, mime::MIME"text/plain", c::PropertyConfig)
    printstyled(io, "PropertyConfig: "; bold=true)
    print(io, join(keys(c.props), ", "))
end

end # module
