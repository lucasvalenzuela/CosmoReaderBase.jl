"""
    assert_unit_type(units::Symbol)

Returns `true` if `units` has one of the supported values, else throws an error.

The supported values for `units` are `:physical`, `:comoving`, and `:sim`.
"""
function assert_unit_type(units::Symbol)
    if units !== :physical && units !== :comoving && units !== :sim
        error("Invalid units value $units passed - only the following values are supported: :physical, :comoving, :sim")
    end

    return true
end


"""
    abstract type AbstractSnapParams end

Abstract type containing parameters for conversion of properties between simulation and physical
or comoving units.

This is not exported.
"""
abstract type AbstractSnapParams end

"""
    struct SnapParams{T,S} <: AbstractSnapParams
        h0::T
        z::S
    end

Type containing little h and redshift `z` for property conversions.

This is not exported.
"""
struct SnapParams{T,S} <: AbstractSnapParams
    h0::T
    z::S
end


"""
    convert_by_factor(a, factor, u::Unitful.Units)
    convert_by_factor!(a::AbstractArray, factor, u::Unitful.Units)

Multiply the scalar or array `a` with `factor` and the unit `u` or strip the unit if `a` is unitful.

The `convert_by_factor!` function modifies the arrays in-place.
Any of `factor` and `u` can be `nothing`.

This is not exported.
"""
function convert_by_factor(a::Real, factor::Real, _::Nothing)
    a * factor
end

function convert_by_factor(a::Real, _::Nothing, _::Nothing)
    a
end

function convert_by_factor(a::AbstractArray{T}, factor::Real, _::Nothing) where {T<:Real}
    CosmoParticles.product_preserve_type(a, factor)
end

function convert_by_factor(a::AbstractArray{T}, _::Nothing, _::Nothing) where {T<:Real}
    copy(a)
end

function convert_by_factor!(a::AbstractArray{T}, factor::Real, _::Nothing) where {T<:Real}
    CosmoParticles.product_preserve_type!(a, factor)
end

function convert_by_factor!(a::AbstractArray{T}, _::Nothing, _::Nothing) where {T<:Real}
    a
end


function convert_by_factor(a::Real, factor::Real, u::U) where {U<:Unitful.Units}
    a * factor * u
end

function convert_by_factor(a::Real, _::Nothing, u::U) where {U<:Unitful.Units}
    a * u
end

function convert_by_factor(a::AbstractArray{T}, factor::Real, u::U) where {T<:Real,U<:Unitful.Units}
    a = CosmoParticles.product_preserve_type(a, factor)
    Q = Quantity{T,dimension(u),U}
    return reinterpret(Q, a)
end

function convert_by_factor(a::AbstractArray{T}, _::Nothing, u::U) where {T<:Real,U<:Unitful.Units}
    a = copy(a)
    Q = Quantity{T,dimension(u),U}
    return reinterpret(Q, a)
end

function convert_by_factor!(a::AbstractArray{T}, factor::Real, u::U) where {T<:Real,U<:Unitful.Units}
    CosmoParticles.product_preserve_type!(a, factor)
    Q = Quantity{T,dimension(u),U}
    return reinterpret(Q, a)
end

function convert_by_factor!(a::AbstractArray{T}, _::Nothing, u::U) where {T<:Real,U<:Unitful.Units}
    Q = Quantity{T,dimension(u),U}
    return reinterpret(Q, a)
end


function convert_by_factor(a::Quantity, factor::Real, u::U) where {U<:Unitful.Units}
    ustrip(u, a * factor)
end

function convert_by_factor(a::Quantity, _::Nothing, u::U) where {U<:Unitful.Units}
    ustrip(u, a)
end

function convert_by_factor(a::AbstractArray{Q}, factor::Real, u::U) where {Q<:Quantity,U<:Unitful.Units}
    a = CosmoParticles.product_preserve_type(a, factor)
    return CosmoParticles.ustrip_lazy!(u, a)
end

function convert_by_factor(a::AbstractArray{Q}, _::Nothing, u::U) where {Q<:Quantity,U<:Unitful.Units}
    a = copy(a)
    return CosmoParticles.ustrip_lazy!(u, a)
end

function convert_by_factor!(a::AbstractArray{Q}, factor::Real, u::U) where {Q<:Quantity,U<:Unitful.Units}
    a = CosmoParticles.product_preserve_type!(a, factor)
    return CosmoParticles.ustrip_lazy!(u, a)
end

function convert_by_factor!(a::AbstractArray{Q}, _::Nothing, u::U) where {Q<:Quantity,U<:Unitful.Units}
    return CosmoParticles.ustrip_lazy!(u, a)
end


"""
    convert_sim_to(a, prop::Symbol, simunits::Dict, params::AbstractSnapParams; units=:physical, unitful=false, propexp)
    convert_sim_to!(a, prop::Symbol, simunits::Dict, params::AbstractSnapParams; units=:physical, unitful=false, propexp)

Returns the (in-place) property array converted from simulation to other units given by `units`.

This is not exported.

# Arguments
- `prop::Symbol`: property name to be converted, this is used to look up conversion information from `simunits`
  and `propexp`
- `simunits::Dict`: Dict of the format `prop => (func, unit)`, where `func` is a function that takes a
  `AbstractSnapParams` object as an argument and returns the conversion factor from simulation to comoving units
- `params::AbstractSnapParams`: parameters of the snapshot typically containing little h and the redshift

# Keyword arguments
- `units::Symbol=:physical`: one of `:sim`, `:physical`, or `:comoving`
- `unitful::Bool=false`: `true` if the returned scalar or array should be unitful objects
- `propexp::Dict`: Dict of the format `prop => n`, where `n` is the positional dimension of the unit (e.g. 1 for
  positions or -3 for densities)
"""
function convert_sim_to end


"""
    convert_to_sim(a, prop::Symbol, simunits::Dict, params::AbstractSnapParams; units=:physical, propexp)
    convert_to_sim!(a, prop::Symbol, simunits::Dict, params::AbstractSnapParams; units=:physical, propexp)

Returns the (in-place) property array converted from simulation to other units given by `units`.

This is not exported.

# Arguments
- `prop::Symbol`: property name to be converted, this is used to look up conversion information from `simunits`
  and `propexp`
- `simunits::Dict`: Dict of the format `prop => (func, unit)`, where `func` is a function that takes a
  `AbstractSnapParams` object as an argument and returns the conversion factor from simulation to comoving units
- `params::AbstractSnapParams`: parameters of the snapshot typically containing little h and the redshift

# Keyword arguments
- `units::Symbol=:physical`: one of `:sim`, `:physical`, or `:comoving`
- `propexp::Dict=Dict{Symbol,Float64}(:pos => 1, :vel => 1)`: Dict of the format `prop => n`, where `n` is the
  positional dimension of the unit (e.g. 1 for positions or -3 for densities)
"""
function convert_to_sim end

_to_sim_unit(a::Real, u) = nothing
_to_sim_unit(a::Quantity, u) = u
_to_sim_unit(a::AbstractArray{<:Real}, u) = nothing
_to_sim_unit(a::AbstractArray{<:Quantity}, u) = u

for (excl, sim_return) in zip(["", "!"], [:(copy(a)), :a])
    quote
        function $(Symbol("convert_sim_to", excl))(
            a,
            prop::Symbol,
            simunits::Dict,
            params::AbstractSnapParams;
            units::Symbol=:physical,
            unitful::Bool=false,
            propexp=Dict{Symbol,Float64}(:pos => 1, :vel => 1),
        )
            CosmoReaderBase.assert_unit_type(units)

            units === :sim && return $sim_return

            f, u = get(simunits, prop, (nothing, nothing))
            u = unitful ? u : nothing

            factor = nothing
            if units === :physical && haskey(propexp, prop)
                n = propexp[prop]
                factor = CosmoParticles.factor_to_physical(params.z, n)
            end

            if !isnothing(f)
                if isnothing(factor)
                    factor = f(params)
                else
                    factor *= f(params)
                end
            end

            return $(Symbol("convert_by_factor", excl))(a, factor, u)
        end

        function $(Symbol("convert_to_sim", excl))(
            a,
            prop::Symbol,
            simunits::Dict,
            params::AbstractSnapParams;
            units::Symbol=:physical,
            propexp=Dict{Symbol,Float64}(:pos => 1, :vel => 1),
        )
            CosmoReaderBase.assert_unit_type(units)

            units === :sim && return $sim_return

            f, u = get(simunits, prop, (nothing, nothing))

            factor = nothing
            if units === :physical && haskey(propexp, prop)
                n = propexp[prop]
                factor = CosmoParticles.factor_to_comoving(params.z, n)
            end

            if !isnothing(f)
                if isnothing(factor)
                    factor = 1 / f(params)
                else
                    factor /= f(params)
                end
            end

            u = _to_sim_unit(a, u)
            return $(Symbol("convert_by_factor", excl))(a, factor, u)
        end
    end |> eval
end
