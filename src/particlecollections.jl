"""
    abstract type AbstractSimulationParticleCollection{AS,AP} <: AbstractParticleCollection{AP} end

Abstract type representing a particle collection belonging to a `snapshot::AS<:AbstractSnapshot` with
`particles::AP<:AbstractParticles`.
"""
abstract type AbstractSimulationParticleCollection{AS,AP} <: AbstractParticleCollection{AP} end

"""
    get_snapshot(pc::AbstractSimulationParticleCollection) -> AbstractSnapshot

Returns the simulation snapshot that the particle collection is from.
"""
get_snapshot(pc::AbstractSimulationParticleCollection) = pc.snapshot

CosmoParticles.redshift(pc::AbstractSimulationParticleCollection) = redshift(get_snapshot(pc))


struct SimulationParticleCollection{AS<:AbstractSnapshot,AP<:AbstractParticles} <:
       AbstractParticleCollection{AP}
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
    pairs::Pair{Symbol,AP}...,
) where {AP<:AbstractParticles,AS<:AbstractSnapshot}
    SimulationParticleCollection{AS,AP}(snapshot, Dict{Symbol,AP}(pairs...))
end

"""
    SimulationParticleCollection(snapshot::AbstractSnapshot, p::Particles...)

Create a particle collection at redshift `snapshot` from multiple
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


Base.copy(pc::SimulationParticleCollection) = SimulationParticleCollection(copy(pc.snapshot), copy(pc.particles))
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
    show_properties(io, mime, pc)
end
