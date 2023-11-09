"""
    abstract type AbstractSimulationParticleCollection{AS,AP} <: AbstractParticleCollection{AP} end

Abstract type representing a particle collection belonging to a `snapshot::AS<:AbstractSnapshot` with
`particles::AP<:AbstractParticles`.

This is not exported.
"""
abstract type AbstractSimulationParticleCollection{AS,AP} <: AbstractParticleCollection{AP} end

"""
    get_snapshot(pc::AbstractSimulationParticleCollection) -> AbstractSnapshot

Returns the simulation snapshot that the particle collection is from.
"""
get_snapshot(pc::AbstractSimulationParticleCollection) = pc.snapshot

CosmoParticles.redshift(pc::AbstractSimulationParticleCollection) = redshift(get_snapshot(pc))


"""
    struct SimulationParticleCollection{AS<:AbstractSnapshot,AP<:AbstractParticles} <: AbstractSimulationParticleCollection{AP}
        snapshot::AS
        particles::Dict{Symbol,AP}
    end

Particle collection belonging to a snapshot of a cosmological simulation.
"""
struct SimulationParticleCollection{AS<:AbstractSnapshot,AP<:AbstractParticles} <:
       AbstractSimulationParticleCollection{AS,AP}
    snapshot::AS
    particles::Dict{Symbol,AP}
end


"""
    SimulationParticleCollection([::Type{AP}=Particles,] snapshot::AbstractSnapshot) where {AP<:AbstractParticles}

Create an empty particle collection of the passed type belonging to the passed `snapshot`.

By default, the particle collection is created for the
[`Particles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/#CosmoParticles.Particles) type.
"""
function SimulationParticleCollection(
    ::Type{AP},
    snapshot::AS,
) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
    return SimulationParticleCollection{AS,AP}(snapshot, Dict{Symbol,AP}())
end
function SimulationParticleCollection(s::AS) where {AS<:AbstractSnapshot}
    return SimulationParticleCollection(Particles, s)
end

"""
    SimulationParticleCollection(snapshot::AbstractSnapshot, pairs::Pair{Symbol,AP}...) where {AP<:AbstractParticles}

Create a particle collection for the given `snapshot` from pairs of Symbols and particles.

# Example
```julia
SimulationParticleCollection(snapshot, :dm => Particles(:dm), :gas => Particles(:gas))
```
"""
function SimulationParticleCollection(
    snapshot::AS,
    pair::Pair{Symbol,AP},
    pairs::Pair{Symbol,AP}...,
) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
    SimulationParticleCollection{AS,AP}(snapshot, Dict{Symbol,AP}(pair, pairs...))
end

"""
    SimulationParticleCollection(snapshot::AbstractSnapshot, p::Particles...)

Create a particle collection for the given `snapshot` from multiple
[`Particles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/#CosmoParticles.Particles).

The `Dict` keys are taken from the
[`Particles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/#CosmoParticles.Particles) type.

# Example
```julia
SimulationParticleCollection(snapshot, Particles(:dm), Particles(:gas))
```
"""
function SimulationParticleCollection(snapshot::AbstractSnapshot, p::Particles, ps::Particles...)
    particles = Dict(p.type => p)
    for particle in ps
        particles[particle.type] = particle
    end
    return SimulationParticleCollection(snapshot, particles)
end


Base.copy(pc::SimulationParticleCollection) =
    SimulationParticleCollection(copy(pc.snapshot), copy(pc.particles))
Base.empty(pc::SimulationParticleCollection) = SimulationParticleCollection(pc.snapshot, empty(pc.particles))
function Base.:(==)(pc1::SimulationParticleCollection, pc2::SimulationParticleCollection)
    return pc1.snapshot == pc2.snapshot && pc1.particles == pc2.particles
end

function Base.propertynames(pc::SimulationParticleCollection; private=false)
    if private
        return [fieldnames(SimulationParticleCollection) |> collect; :all; keys(pc) |> collect]
    else
        return [:snapshot; :all; keys(pc) |> collect]
    end
end

function Base.show(io::IO, mime::MIME"text/plain", pc::SimulationParticleCollection)
    printstyled(io, "ParticleCollection"; bold=true)
    println(io, " at z = $(round(redshift(pc); sigdigits=4)) in $(pc.snapshot |> get_simulation |> get_name)")
    CosmoParticles.show_properties(io, mime, pc)
end



"""
    abstract type AbstractHalo{AS,AP,T} <: AbstractSimulationParticleCollection{AS,AP} end

Abstract type representing a halo's particle collection belonging to a `snapshot::AS<:AbstractSnapshot` with
`particles::AP<:AbstractParticles`.

The halo has an id of type `T`.

This is not exported.
"""
abstract type AbstractHalo{AS,AP,T} <: AbstractSimulationParticleCollection{AS,AP} end

"""
    CosmoReaderBase.get_id(halo::AbstractHalo)

Returns the halo's id.

This is not exported.
"""
get_id(halo::AbstractHalo) = halo.id

"""
    struct Halo{AS<:AbstractSnapshot,AP<:AbstractParticles,T} <: AbstractHalo{AS,AP,T}
        snapshot::AS
        id::T
        props::Dict{Symbol,Any}
        particles::Dict{Symbol,AP}
    end

A Halo's particle collection belonging to a snapshot of a cosmological simulation.

Individual properties of the Halo can be saved in `props`. The reading routines
will use `props` to save properties in simulation units. To get the values converted to units,
[`read_prop`](@ref) should be used.

The following methods have to be implemented for `Halo{<:AbstractSnapshot}`:
- [`get_subhalos`](@ref)
- [`get_main_subhalo`](@ref)
"""
struct Halo{AS<:AbstractSnapshot,AP<:AbstractParticles,T} <: AbstractHalo{AS,AP,T}
    snapshot::AS
    id::T
    props::Dict{Symbol,Any}
    particles::Dict{Symbol,AP}
end

"""
    struct Subhalo{AS<:AbstractSnapshot,AP<:AbstractParticles,T} <: AbstractHalo{AS,AP,T}
        snapshot::AS
        id::T
        props::Dict{Symbol,Any}
        particles::Dict{Symbol,AP}
    end

A Subhalo's particle collection belonging to a snapshot of a cosmological simulation.

Individual properties of the Subhalo can be saved in `props`. The reading routines
will use `props` to save properties in simulation units. To get the values converted to units,
[`read_prop`](@ref) should be used.

The following methods have to be implemented for `Subhalo{<:AbstractSnapshot}`:
- [`get_halo(::AbstractHalo)`](@ref)
- [`is_main_subhalo`](@ref)
- [`get_parent_subhalo`](@ref) if parent subhalos exist
"""
struct Subhalo{AS<:AbstractSnapshot,AP<:AbstractParticles,T} <: AbstractHalo{AS,AP,T}
    snapshot::AS
    id::T
    props::Dict{Symbol,Any}
    particles::Dict{Symbol,AP}
end

for H in [:Halo, :Subhalo]
    quote
        """
            $($(String(H)))([::Type{AP}=Particles,] snapshot::AbstractSnapshot, id[, props]) where {AP<:AbstractParticles}

        Create an empty $($(lowercase(String(H)))) particle collection of the passed type belonging to the passed `snapshot`.

        By default, the particle collection is created for the
        [`Particles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/#CosmoParticles.Particles) type.
        """
        function $H(
            ::Type{AP},
            snapshot::AS,
            id::T,
            props=Dict{Symbol,Any}(),
        ) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
            return $H{AS,AP,T}(snapshot, id, props, Dict{Symbol,AP}())
        end
        function $H(s::AS, id, props=Dict{Symbol,Any}()) where {AS<:AbstractSnapshot}
            return $H(Particles, s, id, props)
        end

        """
            $($(String(H)))(snapshot::AbstractSnapshot, id, [props,] pairs::Pair{Symbol,AP}...) where {AP<:AbstractParticles}

        Create a $($(lowercase(String(H)))) particle collection for the given `snapshot` from pairs of Symbols and particles.

        # Example
        ```julia
        $($(String(H)))(snapshot, id, :dm => Particles(:dm), :gas => Particles(:gas))
        ```
        """
        function $H(
            snapshot::AS,
            id::T,
            props::Dict,
            pair::Pair{Symbol,AP},
            pairs::Pair{Symbol,AP}...,
        ) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
            $H{AS,AP,T}(snapshot, id, props, Dict{Symbol,AP}(pair, pairs...))
        end
        function $H(
            snapshot::AS,
            id::T,
            pair::Pair{Symbol,AP},
            pairs::Pair{Symbol,AP}...,
        ) where {AP<:AbstractParticles,AS<:AbstractSnapshot,T}
            $H(snapshot, id, Dict{Symbol,Any}(), pair, pairs...)
        end

        """
            $($(String(H)))(snapshot::AbstractSnapshot, [props,] p::Particles...)

        Create a $($(lowercase(String(H)))) particle collection for the given `snapshot` from multiple
        [`Particles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/#CosmoParticles.Particles).

        The `Dict` keys are taken from the
        [`Particles`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/particles/#CosmoParticles.Particles)
        type.

        # Example
        ```julia
        $($(String(H)))(snapshot, id, Particles(:dm), Particles(:gas))
        ```
        """
        function $H(snapshot::AbstractSnapshot, id, props::Dict, p::Particles, ps::Particles...)
            particles = Dict(p.type => p)
            for particle in ps
                particles[particle.type] = particle
            end
            return $H(snapshot, id, props, particles)
        end
        function $H(snapshot::AbstractSnapshot, id, p::Particles, ps::Particles...)
            return $H(snapshot, id, Dict{Symbol,Any}(), p, ps...)
        end


        Base.copy(halo::$H) = $H(halo.snapshot, halo.id, copy(halo.props), copy(halo.particles))
        Base.empty(halo::$H) = $H(halo.snapshot, halo.id, empty(halo.props), empty(halo.particles))
        function Base.:(==)(halo1::$H, halo2::$H)
            return halo1.snapshot == halo2.snapshot &&
                   halo1.id == halo2.id &&
                   halo1.particles == halo2.particles
        end

        function Base.propertynames(halo::$H; private=false)
            if private
                return [fieldnames($H) |> collect; :all; keys(halo) |> collect]
            else
                return [:snapshot; :id; :props; :all; keys(halo) |> collect]
            end
        end

        function Base.show(io::IO, halo::$H)
            print(io, $(String(H)), " ", halo.id)
        end

        function Base.show(io::IO, mime::MIME"text/plain", halo::$H)
            printstyled(io, $(String(H)); bold=true)
            print(io, " ", halo.id)
            println(
                io,
                " at z = $(round(redshift(halo); sigdigits=4)) in $(halo.snapshot |> get_simulation |> get_name)",
            )
            CosmoParticles.show_properties(io, mime, halo)
        end
    end |> eval
end


"""
    CosmoParticles.translate_periodic(pc::AbstractSimulationParticleCollection, centerpos::AbstractVector{<:Number}, posprop=:pos)

Translates the particles in-place periodically along the simulation box borders to minimize the distances to `centerpos`.

The particle positions are not shifted if the simulation box is not periodic.

# Keyword arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`.
"""
function CosmoParticles.translate_periodic(
    pc::AbstractSimulationParticleCollection,
    centerpos::AbstractVector{<:Number},
    posprop=:pos;
    units::Symbol=:physical,
    unitful::Bool=false,
)
    snapshot = get_snapshot(pc)
    sim = get_simulation(snapshot)
    isperiodic(sim) || return pc

    lengths = boxlengths(snapshot; units, unitful)
    return translate_periodic(pc, centerpos, lengths, posprop)
end


"""
    CosmoParticles.translate_periodic!(pc::AbstractSimulationParticleCollection, centerpos::AbstractVector{<:Number}, posprop=:pos)

In-place version of [`translate_periodic`](@ref).

For the possible keyword arguments, see [`translate_periodic`](@ref).
"""
function CosmoParticles.translate_periodic!(
    pc::AbstractSimulationParticleCollection,
    centerpos::AbstractVector{<:Number},
    posprop=:pos;
    units::Symbol=:physical,
    unitful::Bool=false,
)
    snapshot = get_snapshot(pc)
    sim = get_simulation(snapshot)
    isperiodic(sim) || return translate!(pc, -centerpos, posprop)

    lengths = boxlengths(snapshot; units, unitful)
    return translate_periodic!(pc, centerpos, lengths, posprop)
end


"""
    CosmoParticles.translate_periodic_to_center(pc::AbstractSimulationParticleCollection, centerpos::AbstractVector{<:Number}, posprop=:pos)

Translates the specified property of the particles or collection to place `centerpos` at the origin.

The particles are translated periodically to place them closest to `centerpos`.
The particle positions are not shifted if the simulation box is not periodic.

For the possible keyword arguments, see [`translate_periodic`](@ref).
"""
function CosmoParticles.translate_periodic_to_center(
    pc::AbstractSimulationParticleCollection,
    centerpos::AbstractVector{<:Number},
    posprop=:pos;
    units::Symbol=:physical,
    unitful::Bool=false,
)
    snapshot = get_snapshot(pc)
    sim = get_simulation(snapshot)
    isperiodic(sim) || return translate(pc, -centerpos, posprop)

    lengths = boxlengths(snapshot; units, unitful)
    return translate_periodic_to_center(pc, centerpos, lengths, posprop)
end


"""
    CosmoParticles.translate_periodic_to_center!(pc::AbstractSimulationParticleCollection, centerpos::AbstractVector{<:Number}, posprop=:pos)

In-place version of [`translate_periodic_to_center`](@ref).

For the possible keyword arguments, see [`translate_periodic`](@ref).
"""
function CosmoParticles.translate_periodic_to_center!(
    pc::AbstractSimulationParticleCollection,
    centerpos::AbstractVector{<:Number},
    posprop=:pos;
    units::Symbol=:physical,
    unitful::Bool=false,
)
    snapshot = get_snapshot(pc)
    sim = get_simulation(snapshot)
    isperiodic(sim) || return translate!(pc, -centerpos, posprop)

    lengths = boxlengths(snapshot; units, unitful)
    return translate_periodic_to_center!(pc, centerpos, lengths, posprop)
end
