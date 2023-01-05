"""
    abstract type AbstractMergerTree{S} end

Abstract type representing the merger tree of a simulation `S<:AbstractCosmoSimulation`.

Subtypes have to implement the following methods:
- [`get_simulation(::AbstractMergerTree)`](@ref): if `simulation` is not a field

This is not exported.
"""
abstract type AbstractMergerTree{S} end

Base.broadcastable(tree::AbstractMergerTree) = Ref(tree)

"""
    abstract type AbstractMergerTreeNode end

Abstract type representing a halo in the merger tree of a simulation.

Subtypes have to implement the following methods:
- [`has_prop(::AbstractMergerTreeNode)`](@ref)
- [`read_prop_simunits(::AbstractMergerTreeNode, ::Symbol)`](@ref): not exported
- [`convert_halonode_prop`](@ref): not exported
- [`get_halo(::AbstractMergerTreeNode)`](@ref)
- [`get_subhalo(::AbstractMergerTreeNode)`](@ref)
- [`get_tree_node(::Type{<:AbstractMergerTree}, ::Subhalo)`](@ref)
- [`get_tree_node(::Type{<:AbstractMergerTree}, ::Halo)`](@ref): if the tree represents `Halo`s
- [`first_progenitor`](@ref)
- [`first_progenitor_at`](@ref)
- [`descendant`](@ref)
- [`next_progenitor_sibling`](@ref)
- [`prev_progenitor_sibling`](@ref)
- [`first_progenitor_sibling`](@ref)
- [`first_progenitors`](@ref)
- [`first_progenitors_and_self`](@ref)
- [`descendants`](@ref)
- [`descendant_at`](@ref)
- [`descendants_and_self`](@ref)
- [`direct_progenitors`](@ref)
- [`progenitor_siblings`](@ref)
- [`get_tree(::AbstractMergerTreeNode)`](@ref): if `tree` is not a field
- [`get_snapshot(::AbstractMergerTreeNode)`](@ref): if `snapshot` is not a field

This is not exported.
"""
abstract type AbstractMergerTreeNode end

Base.broadcastable(node::AbstractMergerTreeNode) = Ref(node)

"""
    get_tree(halo::AbstractHalo) -> AbstractMergerTree

Returns the merger tree of the simulation the halo belongs to.

See [`get_tree(::AbstractCosmoSimulation)`](@ref).
"""
get_tree(h::AbstractHalo) = h |> get_snapshot |> get_simulation |> get_tree

"""
    get_tree(halonode::AbstractMergerTreeNode)

Returns the merger tree of the merger tree halo node.

By default returns `halonode.tree`.
"""
get_tree(h::AbstractMergerTreeNode) = h.tree

"""
    get_simulation(tree::AbstractMergerTree)

Returns the simulation to which the merger tree belongs.

By default returns `tree.simulation`.
"""
get_simulation(tree::AbstractMergerTree) = tree.simulation

"""
    get_snapshot(halnode::AbstractMergerTreeNode)

Returns the snapshot of the merger tree halo node.

By default returns `halonode.snapshot`.
"""
get_snapshot(h::AbstractMergerTreeNode) = h.snapshot

"""
    has_prop(halonode::AbstractMergerTreeNode, prop) -> Bool

Returns `true` if the halo node has the passed property.

Also see [`read_prop`](@ref).
"""
function has_prop(::AbstractMergerTreeNode, prop) end

"""
    read_prop(halonode::AbstractMergerTreeNode, prop; units=:physical, unitful=false)

Returns the property of the halo node.

# Keyword arguments
- `units::Symbol=:physical`: has to be `:sim`, `:physical`, or `:comoving` for simulation, physical, or comoving
  units, respectively
- `unitful::Bool=false`: whether unitful units should be added to the properties or not. This is ignored if
  `units=:sim`.
"""
function read_prop(halonode::AbstractMergerTreeNode, prop; kwargs...)
    val = read_prop_simunits(halonode, prop)
    return convert_halonode_prop(val, prop, halonode; kwargs...)
end

"""
    read_prop_simunits(halonode::AbstractMergerTreeNode, prop::Symbol)

Returns the halo property in simulation units.

Contrary to [`read_prop`](@ref), this function always reads in the value from the simulation.

This is not exported.
"""
function read_prop_simunits(::AbstractMergerTreeNode, ::Symbol) end

"""
    convert_halonode_prop(val, prop::Symbol, halonode::AbstractMergerTreeNode; units::Symbol, unitful::Bool)

Returns the halo node's property or properties converted from simulation units to the specified units.

For the allowed values of `units` and `unitful`, see [`read_prop`](@ref).
The passed value can be a scalar value (`Number`) or an array of values (`AbstractArray`).

This is not exported.
"""
function convert_halonode_prop(_, ::Symbol, ::AbstractMergerTreeNode) end

"""
    get_halo(halonode::AbstractMergerTreeNode) -> Halo

Returns the halo object corresponding to the halo node from the merger tree.

By default returns the halo of the corresponding subhalo.
"""
get_halo(h::AbstractMergerTreeNode) = get_halo(get_subhalo(h))

"""
    get_subhalo(::AbstractMergerTreeNode) -> Subhalo

Returns the subhalo object corresponding to the halo node from the merger tree.
"""
function get_subhalo(::AbstractMergerTreeNode) end

"""
    get_tree_node(halo::AbstractHalo) -> AbstractMergerTreeNode

Returns the merger tree node corresponding to the halo object.

For a `Halo` object, by default the halo node corresponding to its first subhalo is returned.
"""
get_tree_node(h::Subhalo) = get_tree_node(typeof(get_tree(h)), h)
get_tree_node(h::Halo) = get_tree_node(typeof(get_tree(h)), h)

function get_tree_node(::Type{<:AbstractMergerTree}, h::Subhalo) end

get_tree_node(T::Type{<:AbstractMergerTree}, h::Halo) = get_tree_node(T, get_main_subhalo(h))


"""
    first_progenitor(halo::AbstractHalo) -> AbstractHalo
    first_progenitor(halonode::AbstractMergerTreeNode) -> AbstractMergerTreeNode

Returns the first or main progenitor of the halo, or `nothing` if it does not exist.

The progenitor is not necessarily from the immediate previous snapshot of the passed halo.
"""
function first_progenitor(::AbstractMergerTreeNode) end

"""
    descendant(halo::AbstractHalo) -> AbstractHalo
    descendant(halonode::AbstractMergerTreeNode) -> AbstractHaloNode

Returns the descendant of the halo, or `nothing` if it does not exist.

The descendant is not necessarily from the immediate next snapshot of the passed halo.
"""
function descendant(::AbstractMergerTreeNode) end

"""
    next_progenitor_sibling(halo::AbstractHalo) -> AbstractHalo
    next_progenitor_sibling(halonode::AbstractMergerTreeNode) -> AbstractHaloNode

Returns the next progenitor sibling of the halo, or `nothing` if it does not exist.

Next progenitor sibling means the next smaller halo that has the same descendant as the passed halo.
The sibling progenitor is not necessarily from the same snapshot as the passed halo.
"""
function next_progenitor_sibling(::AbstractMergerTreeNode) end

"""
    prev_progenitor_sibling(halo::AbstractHalo) -> AbstractHalo
    prev_progenitor_sibling(halonode::AbstractMergerTreeNode) -> AbstractHaloNode

Returns the previous progenitor sibling of the halo, or `nothing` if it does not exist.

Previous progenitor sibling means the next larger halo that has the same descendant as the passed halo.
The sibling progenitor is not necessarily from the same snapshot as the passed halo.
"""
function prev_progenitor_sibling(::AbstractMergerTreeNode) end

"""
    first_progenitor_sibling(halo::AbstractHalo) -> AbstractHalo
    first_progenitor_sibling(halonode::AbstractMergerTreeNode) -> AbstractHaloNode

Returns the first or main progenitor sibling of the halo, or `nothing` if it does not exist.

First progenitor sibling means the main halo that has the same descendant as the passed halo, i.e., the
halo that the passed halo merged into.
The sibling progenitor is not necessarily from the same snapshot as the passed halo.
"""
function first_progenitor_sibling(::AbstractMergerTreeNode) end


"""
    first_progenitors(halo::AbstractHalo)
    first_progenitors(halonode::AbstractMergerTreeNode)

Returns an iterator over the respective first progenitors of the passed halo back through the snapshots.

Note it is possible that snapshots are skipped from one halo to its progenitor due to halos not always
being identified in all snapshots.

Also see [`first_progenitors_and_self`](@ref).
"""
function first_progenitors(::AbstractMergerTreeNode) end

"""
    first_progenitors_and_self(halo::AbstractHalo)
    first_progenitors_and_self(halonode::AbstractMergerTreeNode)

Returns an iterator over the halo and its respective first progenitors of the passed halo back through
the snapshots.

Note it is possible that snapshots are skipped from one halo to its progenitor due to halos not always
being identified in all snapshots.

Also see [`first_progenitors`](@ref).
"""
function first_progenitors_and_self(::AbstractMergerTreeNode) end

"""
    descendants(halo::AbstractHalo)
    descendants(halonode::AbstractMergerTreeNode)

Returns an iterator over the respective descendants of the passed halo forward through the snapshots.

Note it is possible that snapshots are skipped from one halo to its descendant due to halos not always
being identified in all snapshots.

Also see [`descendants_and_self`](@ref).
"""
function descendants(::AbstractMergerTreeNode) end

"""
    descendants_and_self(halo::AbstractHalo)
    descendants_and_self(halonode::AbstractMergerTreeNode)

Returns an iterator over the halo and its respective first progenitors of the passed halo node forward through
the snapshots.

Note it is possible that snapshots are skipped from one halo to its descendant due to halos not always
being identified in all snapshots.

Also see [`descendants`](@ref).
"""
function descendants_and_self(::AbstractMergerTreeNode) end

"""
    direct_progenitors(halo::AbstractHalo)
    direct_progenitors(halonode::AbstractMergerTreeNode)

Returns an iterator over all direct progenitors of the passed halo from largest to smallest.

Note it is possible that not all direct progenitors are from the same snapshot due to halos not always
being identified in all snapshots.

Also see [`progenitor_siblings`](@ref).
"""
function direct_progenitors(::AbstractMergerTreeNode) end

"""
    progenitor_siblings(halo::AbstractHalo)
    progenitor_siblings(halonode::AbstractMergerTreeNode)

Returns an iterator over all smaller halos that merge into the same descendant of the passed halo node from
largest to smallest.

Note it is possible that not all progenitor siblings are from the same snapshot as the passed halo due to halos
not always being identified in all snapshots.

Also see [`direct_progenitors`](@ref).
"""
function progenitor_siblings(::AbstractMergerTreeNode) end


for func in [
    :first_progenitor,
    :descendant,
    :next_progenitor_sibling,
    :prev_progenitor_sibling,
    :first_progenitor_sibling,
]
    quote
        $func(h::Halo) = get_halo($func(get_tree_node(h)))
        $func(h::Subhalo) = get_subhalo($func(get_tree_node(h)))
    end |> eval
end

for func in [
    :first_progenitors,
    :first_progenitors_and_self,
    :descendants,
    :descendants_and_self,
    :direct_progenitors,
    :progenitor_siblings,
]
    quote
        function $func(h::Halo)
            f = node -> get_halo(node)
            Iterators.map(f, $func(get_tree_node(h)))
        end

        function $func(h::Subhalo)
            f = node -> get_subhalo(node)
            Iterators.map(f, $func(get_tree_node(h)))
        end
    end |> eval
end


"""
    first_progenitor_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real)

Returns the closest first progenitor to the given redshift.

See [`first_progenitors`](@ref).
"""
function first_progenitor_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real)
    currentprog = halo
    prevprog = halo
    current_z = prev_z = redshift(get_snapshot(halo))

    for prog in first_progenitors(halo)
        prog_z = redshift(get_snapshot(prog))
        prevprog, currentprog = currentprog, prog
        prev_z, current_z = current_z, prog_z
        prog_z > z && break
    end

    a = 1 / (1 + z)
    current_a = 1 / (1 + current_z)
    prev_a = 1 / (1 + prev_z)

    if abs(current_a - a) < abs(prev_a - a)
        return currentprog
    else
        return prevprog
    end
end

"""
    first_progenitor_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}; id)
    first_progenitor_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, snapshot::AbstractSnapshot)

Returns the first progenitor at the snapshot (of the given ID) or `nothing` if there is no progenitor at the snapshot.

See [`first_progenitors`](@ref).
"""
function first_progenitor_at(halonode::AbstractMergerTreeNode; id)
    snapshot = get_snapshot(halonode |> get_snapshot |> get_simulation, id)
    for prog in first_progenitors(halonode)
        snapshot == get_snapshot(prog) && return prog
    end
    return nothing
end

function first_progenitor_at(halo::Halo; id)
    node = get_tree_node(halo)
    return first_progenitor_at(node; id) |> get_halo
end

function first_progenitor_at(halo::Subhalo; id)
    node = get_tree_node(halo)
    return first_progenitor_at(node; id) |> get_subhalo
end

function first_progenitor_at(halonode::Union{AbstractHalo,AbstractMergerTreeNode}, snapshot::AbstractSnapshot)
    return first_progenitor_at(halonode; id=get_snapshotid(snapshot))
end


"""
    descendant_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real)

Returns the closest descendant to the given redshift.

See [`descendants`](@ref).
"""
function descendant_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real)
    currentdesc = halo
    prevdesc = halo
    current_z = prev_z = redshift(get_snapshot(halo))

    for desc in descendants(halo)
        desc_z = redshift(get_snapshot(desc))
        prevdesc, currentdesc = currentdesc, desc
        prev_z, current_z = current_z, desc_z
        desc_z < z && break
    end

    a = 1 / (1 + z)
    current_a = 1 / (1 + current_z)
    prev_a = 1 / (1 + prev_z)

    if abs(current_a - a) < abs(prev_a - a)
        return currentdesc
    else
        return prevdesc
    end
end

"""
    descendant_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}; id)
    descendant_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, snapshot::AbstractSnapshot)

Returns the descendant at the snapshot (of the given ID) or `nothing` if there is no descendant at the snapshot.

See [`descendants`](@ref).
"""
function descendant_at(halonode::AbstractMergerTreeNode; id)
    snapshot = get_snapshot(halonode |> get_snapshot |> get_simulation, id)
    for prog in descendants(halonode)
        snapshot == get_snapshot(prog) && return prog
    end
    return nothing
end

function descendant_at(halo::Halo; id)
    node = get_tree_node(halo)
    return descendant_at(node; id) |> get_halo
end

function descendant_at(halo::Subhalo; id)
    node = get_tree_node(halo)
    return descendant_at(node; id) |> get_subhalo
end

function descendant_at(halonode::Union{AbstractHalo,AbstractMergerTreeNode}, snapshot::AbstractSnapshot)
    return descendant_at(halonode; id=get_snapshotid(snapshot))
end
