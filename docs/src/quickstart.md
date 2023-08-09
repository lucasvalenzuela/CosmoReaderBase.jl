```@meta
CurrentModule = CosmoReaderBase
```

# Quick Start

## Loading a Simulation

Simulations can be loaded through implementing packages of the `CosmoReaderBase` API. In general, this means
that `CosmoReaderBase` does not have to be installed directly, but only the implementing package.
Currently, only [`GadgetReader.jl`](https://gitlab.com/juliacosmosims/GadgetReader.jl) implements the API for
simulations written in the Gadget 2 format.

For example, using [`CASTSims.jl`](https://gitlab.com/juliacosmosims/CASTSims.jl) for simulations of the CAST
group:
```julia
using CASTSims, GadgetReader

sim = Box4() # loads the default configuration object defined in CASTSims
sim isa CosmoSimulation
```

For more ways of loading simulations, refer to the documentation pages of the respective packages.


## Loading a Snapshot

Snapshots contain information on particles and/or identified halos found through a halo finder for a given
point in time of the simulation. A snapshot can be loaded in the following ways (see [General Simulations](@ref)
and [Snapshots](@ref) for more details):
- `get_first_snapshot(sim)`: the first available snapshot
- `get_last_snapshot(sim)`: the last available snapshot
- `get_nearest_snapshot(sim, z)`: the nearest snapshot to the given redshift in terms of the scale factor
- `get_snapshot(sim, id)`: obtaining the snapshot of the given ID (this depends on the simulation, typically
  this is an integer)
- `snapshots(sim)`: an iterator over all available snapshots
- `prev_snapshot(snapshot)`: the previous available snapshot
- `next_snapshot(snapshot)`: the next available snapshot

Some packages (like `GadgetReader`) may allow additional keyword arguments to force particle or halo data
(e.g. `forcesnap=true` or `forcesub=true`).


## Reading Information from a Simulation or Snapshot

Some information is available through some methods on simulations and snapshots (see [Simulation](@ref) for more
details):

```julia
lowerleft, upperright = boxcorners(sim; units=:comoving, unitful=false) # note that :physical units are not possible for a simulation object
lowerleft, upperright = boxcorners(snapshot; units=:physical, unitful=false) # :physical is the default for a given snapshot

lengths = boxlengths(sim; units=:comoving, unitful=false)
lengths = boxlengths(snapshot; units=:physical, unitful=false)

c = cosmology(sim)
c = cosmology(snapshot)

z = redshift(snapshot)
```


## Reading Particle Data

Particles can be read with [`read_particles`](@ref) through a number of methods. For all methods, the keyword
arguments `units` and `unitful` can be passed. The former, `units`, can be one of `:physical` (the default),
`:comoving`, or `:sim`, while `unitful` is `true` or `false` (the default).
The particles are of the type [`SimulationParticleCollection`](@ref), for which the operations defined by
[`CosmoParticles.jl`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/) can be used.


### Reading All Particles

Reading all the particles in a box is possible in the following ways:

```julia
p = read_particles(snapshot, :dm, :pos)  # read all DM positions

typeprops = [(:dm, [:id, :pos]), (:gas, [:id, :pos, :temp])]
p = read_particles(snapshot, typeprops)  # read multiple particle types
```

### Reading in a Volume

Reading the particles within a certain volume is also possible. Particles are shifted across the box borders if
the box is periodic and the defined volume reaches across the borders.
To additionally shift the particles to the center of the volume, pass the keyword argument `shift_to_center=true`
to the method, so that the defined volume's center is at the origin of the coordinate system.
The length parameters of the geometry have to be given in the same units that the particles are read with (i.e.
the units defined by `units` and `unitful`).

```julia
typeprops = [(:dm, [:id, :pos]), (:gas, [:id, :pos, :temp])]

centerpos, radius = [200, 200, 200], 50
vol = CosmoCube(centerpos, radius)
p = read_particles(snapshot, typeprops, vol)  # no guarantee that all particles are within the volume when reading a cuboid volume
p = read_particles(snapshot, typeprops, vol; exact=true)  # all particles are within the volume

vol = CosmoSphere(centerpos, radius)
p = read_particles(snapshot, typeprops, vol)  # all particles are within the volume by default
```

### Accessing the Particle Data

The read-in particle data can be accessed in the following way:

```julia
# accessing the properties
p.dm.pos    # 3×N matrix
p.dm.mass   # N-length vector or scalar, depending on the simulation

p.all.pos           # lazy matrix of the positions
Particles(p.all)    # copy of the particle properties to a new particle object
```


### Reading the Particles of a Halo

Reading the particles of a certain halo can be done with [`read_particles!`](@ref) in the following way:

```julia
typeprops = [(:dm, [:id, :pos]), (:gas, [:id, :pos, :temp])]

id   # ID of the halo, typically an integer
halo = Halo(snapshot, id)

read_particles!(halo, typeprops, :rvir)             # reads the particles within the virial radius
read_particles!(halo, typeprops, :rvir; rscale=2)   # reads the particles within two virial radii
read_particles!(halo, typeprops, 200)               # reads the particles within 200 physical units

read_particles!(halo, typeprops, 200; shift_to_center=true) # shifts the halo's center to the origin
```

It is also possible to read the corresponding particles within a containing already read-in volume. This is
fastest when the particles from the large volume are already sorted by their IDs and no radius is passed:

```julia
typeprops = [(:dm, [:id, :pos]), (:gas, [:id, :pos, :temp])]
p = read_particles(snapshot, typeprops)    # read all the particles in the simulation
sort!(p, :id)   # this may take a while for large simulations (roughly a couple of minutes for 100 million particles)

id    # ID of the halo
halo = Halo(snapshot, id)

read_particles!(halo, p)
```

The same also applies to reading the particles of a subhalo within a halo:

```julia
id    # ID of the halo
halo = Halo(snapshot, id)

read_particles!(halo, p, typeprops, :rvir; rscale=2)
sort!(halo, :id)

subhalo = get_main_subhalo(halo)
read_particles!(subhalo, halo)
```


## Reading Halo Data

### Properties of Individual Halos

The property of a halo can be read in with [`read_prop`](@ref):

```julia
read_prop(halo, :rvir; units=:physical, unitful=false)
```

The halos and subhalos in the hierarchy of halos can be obtained in the following ways:

Taking a halo as argument:
- [`get_halo(::AbstractHalo)`](@ref)
- [`get_main_subhalo`](@ref)

Taking a subhalo as argument:
- [`get_subhalos`](@ref)
- [`get_parent_subhalo`](@ref)
- [`is_main_subhalo`](@ref)


### Properties of Multiple Halos

Halo data can be read with [`read_halos`](@ref) and [`read_subhalos`](@ref). The resulting `Halos` and `Subhalos`
objects or `AbstractParticles` and can be worked with as documented in
[`CosmoParticles.jl`](https://lucasvalenzuela.github.io/CosmoParticles.jl/stable/).

```julia
halos = read_halos(snapshot, [:id, :pos, :mvir])

halos isa AbstractParticles  # = true

# access halo properties
halos.pos


# invidiual Halo objects can be obtained in the following ways:
halo = halos[1]

for halo in halos
    halo isa Halo   # true
end
```

Halos can also be read in by ID:

```julia
ids    # vector of halo IDs
halos = read_halos(snapshot, [:id, :pos, :mvir], ids)
```

## Working with Merger Trees

Some simulations provide a merger tree to track the subhalos and/or halos back through time.
To easily check whether a tree is provided, use [`has_tree(sim)`](@ref) and if it returns `true` then load it
with [`get_tree(sim)`](@ref).

Each subhalo (and/or halo) of a simulation has a counterpart halo node in the merger tree. To switch between the
two types, use [`get_halo(::AbstractMergerTreeNode)`](@ref), [`get_subhalo(::AbstractMergerTreeNode)`](@ref), and
[`get_tree_node`](@ref). Generally, a limited set of properties are available for halo nodes, which can be
checked with [`has_prop(::AbstractMergerTreeNode, prop)`](@ref) and loaded with [`read_prop(::AbstractMergerTreeNode, prop)`].

The following methods can be used to traverse the merger tree, using either the halo/subhalo objects or the halo
nodes as arguments (see [Traversing](@ref) for more details):
- `first_progenitor`
- `first_progenitor_at`
- `descendant_at`
- `descendant`
- `next_progenitor_sibling`
- `prev_progenitor_sibling`
- `first_progenitor_sibling`

Finally, there are also some iterators to traverse the trees, e.g. in for-loops (see [Traverse Iteration](@ref)
for more details). Traversing the halo node objects is faster if only properties directly available for these
are needed.
- `first_progenitors`
- `first_progenitors_and_self`
- `descendants`
- `descendants_and_self`
- `direct_progenitors`
- `progenitor_siblings`
