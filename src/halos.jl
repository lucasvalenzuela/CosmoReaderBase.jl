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

Returns if the subhalo is the main subhalo in the host halo.
"""
function is_main_subhalo(s::Subhalo)
    smain = get_main_subhalo(get_halo(s))
    return smain.id == s.id
end



abstract type AbstractHalos <: AbstractParticles end

for H in [:Halos, :Subhalos]
    quote
        struct $H{ACS} <: AbstractHalos where {ACS<:AbstractCosmoSimulation}
            snapshot::AbstractSnapshot{ACS}
            props::Dict{Symbol,Any}
        end

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
