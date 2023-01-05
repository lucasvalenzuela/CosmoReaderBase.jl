"""
    get_subhalos(halo::Halo) -> Vector{Subhalo}

Returns the subhalos of the halo.
"""
function get_subhalos(::Halo) end

"""
    get_halo(subhalo::Subhalo) -> Halo

Returns the host halo of the subhalo.
"""
function get_halo(::Subhalo) end

"""
    get_parent_subhalo(subhalo::Subhalo) -> Subhalo

Returns the parent subhalo of the subhalo, or `nothing` if it does not have a parent subhalo.
"""
get_parent_subhalo(::Subhalo) = nothing

"""
    get_main_subhalo(halo::Halo) -> Subhalo

Returns the main subhalo of the halo.
"""
function get_main_subhalo(::Halo) end

"""
    is_main_subhalo(subhalo::Subhalo)

Returns true if the subhalo is the main subhalo in the host halo.
"""
function is_main_subhalo(s::Subhalo)
    smain = get_main_subhalo(get_halo(s))
    return smain.id == s.id
end



"""
    abstract type AbstractHalos <: AbstractParticles end

Abstract type for lists of halo properties.

This is not exported.
"""
abstract type AbstractHalos <: AbstractParticles end

for H in [:Halos, :Subhalos]
    quote
        """
            struct $($(String(H))){AS} <: AbstractHalos where {AS<:AbstractSnapshot}
                snapshot::AS
                props::Dict{Symbol,Any}
            end

        Property list of $($(lowercase(String(H)))) at a given `snapshot`.

        See the documentation of 
        [`AbstractParticles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/)
        for how to access and set the properties.
        """
        struct $H{AS} <: AbstractHalos where {AS<:AbstractSnapshot}
            snapshot::AS
            props::Dict{Symbol,Any}
        end

        """
            $($(String(H)))(snapshot::AbstractSnapshot[, pairs::Pair...])

        Create a [`$($(String(H)))`](@ref) object at the given `snapshot` and pairs of `Symbol` to the property
        values. These are passed to the underlying `Dict`. If no pairs are passed to the method, an empty `Dict`
        is created.
        """
        $H(snapshot::AbstractSnapshot) = $H(snapshot, Dict{Symbol,Any}())
        $H(snapshot::AbstractSnapshot, pairs::Pair...) = $H(snapshot, Dict{Symbol,Any}(pairs...))

        CosmoParticles.particle_name(::$H) = $(String(H))
    end |> eval
end

Base.copy(h::AH) where {AH<:AbstractHalos} = AH(h.snapshot, h.props)
Base.empty(h::AH) where {AH<:AbstractHalos} = AH(h.snapshot, empty(h.props))
Base.:(==)(h1::AH, h2::AH) where {AH<:AbstractHalos} =
    h1.snapshot == h2.snapshot && isequal(h1.props, h2.props)

"""
    get_snapshot(h::AbstractHalos)

Returns the snapshot of the halos.
"""
get_snapshot(h::AbstractHalos) = h.snapshot

"""
    CosmoParticles.redshift(h::AbstractHalos)

Returns the redshift of the halos.
"""
CosmoParticles.redshift(h::AbstractHalos) = CosmoParticles.redshift(h.snapshot)

function Base.propertynames(h::AH; private=false) where {AH<:AbstractHalos}
    if private
        return [fieldnames(AH) |> collect; keys(h) |> collect]
    else
        return [:snapshot; keys(h) |> collect]
    end
end

function Base.show(io::IO, mime::MIME"text/plain", h::AbstractHalos)
    printstyled(io, String(CosmoParticles.particle_name(h)); bold=true)
    println(io, " at z = $(round(redshift(h); sigdigits=4)) in $(h.snapshot |> get_simulation |> get_name)")
    CosmoParticles.show_properties(io, mime, h)
end


function Base.getindex(h::Halos, index::Integer)
    @assert haskey(h, :id)
    return Halo(h.snapshot, h.id[index])
end

function Base.getindex(h::Subhalos, index::Integer)
    @assert haskey(h, :id)
    return Subhalo(h.snapshot, h.id[index])
end

Base.length(h::AbstractHalos) = length(h.id)
Base.lastindex(h::AbstractHalos) = lastindex(h.id)

Base.iterate(h::AbstractHalos, state=1) = state > length(h.id) ? nothing : (h[state], state + 1)
