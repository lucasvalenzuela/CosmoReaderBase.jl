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
- [`get_tree_node(::AbstractMergerTree, ::Subhalo)`](@ref)
- [`get_tree_node(::AbstractMergerTree, ::Halo)`](@ref): if the tree represents `Halo`s
- [`first_progenitor`](@ref)
- [`first_progenitor_at`](@ref): optional for performance
- [`descendant`](@ref)
- [`next_progenitor_sibling`](@ref)
- [`prev_progenitor_sibling`](@ref): optional for performance
- [`first_progenitor_sibling`](@ref): optional for performance
- [`first_progenitors`](@ref): optional for performance
- [`first_progenitors_and_self`](@ref): optional for performance
- [`descendants`](@ref): optional for performance
- [`descendant_at`](@ref): optional for performance
- [`descendants_and_self`](@ref): optional for performance
- [`direct_progenitors`](@ref): optional for performance
- [`progenitor_siblings`](@ref): optional for performance
- [`get_tree(::AbstractMergerTreeNode)`](@ref): if `tree` is not a field
- [`get_snapshot(::AbstractMergerTreeNode)`](@ref): if `snapshot` is not a field
- `Base.:(==)`: for some of the default traversal methods to work

This is not exported.
"""
abstract type AbstractMergerTreeNode end

Base.broadcastable(node::AbstractMergerTreeNode) = Ref(node)

"""
    get_tree(halo::AbstractHalo) -> AbstractMergerTree

Returns the merger tree of the simulation the halo belongs to.

See [`get_tree(::AbstractCosmoSimulation)`](@ref).
"""
get_tree(h::AbstractHalo; kwargs...) = get_tree(h |> get_snapshot |> get_simulation; kwargs...)

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
get_tree_node(h::Subhalo; kwargs...) = get_tree_node(get_tree(h; kwargs...), h)
get_tree_node(h::Halo; kwargs...) = get_tree_node(get_tree(h; kwargs...), h)

function get_tree_node(::AbstractMergerTree, h::Subhalo) end

get_tree_node(tree::AbstractMergerTree, h::Halo) = get_tree_node(tree, get_main_subhalo(h))


"""
    first_progenitor(halo::AbstractHalo) -> AbstractHalo
    first_progenitor(halonode::AbstractMergerTreeNode) -> AbstractMergerTreeNode

Returns the first or main progenitor of the halo, or `nothing` if it does not exist.

The progenitor is not necessarily from the immediate previous snapshot of the passed halo.
"""
function first_progenitor(::AbstractMergerTreeNode) end

"""
    descendant(halo::AbstractHalo) -> AbstractHalo
    descendant(halonode::AbstractMergerTreeNode) -> AbstractMergerTreeNode

Returns the descendant of the halo, or `nothing` if it does not exist.

The descendant is not necessarily from the immediate next snapshot of the passed halo.
"""
function descendant(::AbstractMergerTreeNode) end

"""
    next_progenitor_sibling(halo::AbstractHalo) -> AbstractHalo
    next_progenitor_sibling(halonode::AbstractMergerTreeNode) -> AbstractMergerTreeNode

Returns the next progenitor sibling of the halo, or `nothing` if it does not exist.

Next progenitor sibling means the next halo that has the same descendant as the passed halo.
The sibling progenitor is not necessarily from the same snapshot as the passed halo.
"""
function next_progenitor_sibling(::AbstractMergerTreeNode) end

"""
    prev_progenitor_sibling(halo::AbstractHalo) -> AbstractHalo
    prev_progenitor_sibling(halonode::AbstractMergerTreeNode) -> AbstractMergerTreeNode

Returns the previous progenitor sibling of the halo, or `nothing` if it does not exist.

Previous progenitor sibling means the next halo that has the same descendant as the passed halo.
The sibling progenitor is not necessarily from the same snapshot as the passed halo.
"""
function prev_progenitor_sibling(node::AbstractMergerTreeNode)
    sibling_node = first_progenitor_sibling(node)
    sibling_node == node && return nothing # node is the first sibling
    while true
        next_sibling_node = next_progenitor_sibling(sibling_node)
        isnothing(next_sibling_node) && error("Tree corrupt: descendant is not progenitor of the given node")
        next_sibling_node == node && return sibling_node
        sibling_node = next_sibling_node
    end
end

"""
    first_progenitor_sibling(halo::AbstractHalo) -> AbstractHalo
    first_progenitor_sibling(halonode::AbstractMergerTreeNode) -> AbstractMergerTreeNode

Returns the first or main progenitor sibling of the halo, or `nothing` if it does not exist.

First progenitor sibling means the main halo that has the same descendant as the passed halo, i.e., the
halo that the passed halo merged into.
The sibling progenitor is not necessarily from the same snapshot as the passed halo.
"""
function first_progenitor_sibling(node::AbstractMergerTreeNode)
    node |> descendant |> first_progenitor
end


struct FirstProgenitors{N,T}
    node::T
end

Base.eltype(::Type{FirstProgenitors{N,T}}) where {N,T} = N
Base.IteratorSize(::Type{<:FirstProgenitors}) = Base.SizeUnknown()

"""
    first_progenitors(halo::AbstractHalo)
    first_progenitors(halonode::AbstractMergerTreeNode)

Returns an iterator over the respective first progenitors of the passed halo back through the snapshots.

Note it is possible that snapshots are skipped from one halo to its progenitor due to halos not always
being identified in all snapshots.

Also see [`first_progenitors_and_self`](@ref).
"""
function first_progenitors(node::N) where {N<:AbstractMergerTreeNode}
    prognode = first_progenitor(node)
    FirstProgenitors{N,typeof(prognode)}(prognode)
end

"""
    first_progenitors_and_self(halo::AbstractHalo)
    first_progenitors_and_self(halonode::AbstractMergerTreeNode)

Returns an iterator over the halo and its respective first progenitors of the passed halo back through
the snapshots.

Note it is possible that snapshots are skipped from one halo to its progenitor due to halos not always
being identified in all snapshots.

Also see [`first_progenitors`](@ref).
"""
function first_progenitors_and_self(node::N) where {N<:AbstractMergerTreeNode}
    FirstProgenitors{N,typeof(node)}(node)
end

Base.iterate(S::FirstProgenitors, node=S.node) = isnothing(node) ? nothing : (node, first_progenitor(node))


struct Descendants{N,T}
    node::T
end

Base.eltype(::Type{Descendants{N,T}}) where {N,T} = N
Base.IteratorSize(::Type{<:Descendants}) = Base.SizeUnknown()


"""
    descendants(halo::AbstractHalo)
    descendants(halonode::AbstractMergerTreeNode)

Returns an iterator over the respective descendants of the passed halo forward through the snapshots.

Note it is possible that snapshots are skipped from one halo to its descendant due to halos not always
being identified in all snapshots.

Also see [`descendants_and_self`](@ref).
"""
function descendants(node::N) where {N<:AbstractMergerTreeNode}
    descnode = descendant(node)
    Descendants{N,typeof(descnode)}(descnode)
end

"""
    descendants_and_self(halo::AbstractHalo)
    descendants_and_self(halonode::AbstractMergerTreeNode)

Returns an iterator over the halo and its respective first progenitors of the passed halo node forward through
the snapshots.

Note it is possible that snapshots are skipped from one halo to its descendant due to halos not always
being identified in all snapshots.

Also see [`descendants`](@ref).
"""
function descendants_and_self(node::N) where {N<:AbstractMergerTreeNode}
    Descendants{N,typeof(node)}(node)
end

Base.iterate(S::Descendants, node=S.node) = isnothing(node) ? nothing : (node, descendant(node))


struct DirectProgenitors{N,T}
    node::T
end

Base.eltype(::Type{DirectProgenitors{N,T}}) where {N,T} = N
Base.IteratorSize(::Type{<:DirectProgenitors}) = Base.SizeUnknown()

"""
    direct_progenitors(halo::AbstractHalo)
    direct_progenitors(halonode::AbstractMergerTreeNode)

Returns an iterator over all direct progenitors of the passed halo starting with the largest.

Note it is possible that not all direct progenitors are from the same snapshot due to halos not always
being identified in all snapshots.
It is also possible that the halos following the first are not ordered by size or mass.

Also see [`progenitor_siblings`](@ref).
"""
function direct_progenitors(node::N) where {N<:AbstractMergerTreeNode}
    prognode = first_progenitor(node)
    DirectProgenitors{N,typeof(prognode)}(prognode)
end

"""
    progenitor_siblings(halo::AbstractHalo)
    progenitor_siblings(halonode::AbstractMergerTreeNode)

Returns an iterator over all smaller halos that merge into the same descendant of the passed halo node.

Note it is possible that not all progenitor siblings are from the same snapshot as the passed halo due to halos
not always being identified in all snapshots.
Depending on the merger tree, these will not necessarily be ordered by size or mass.

Also see [`direct_progenitors`](@ref).
"""
function progenitor_siblings(node::N) where {N<:AbstractMergerTreeNode}
    sibnode = next_progenitor_sibling(node)
    DirectProgenitors{N,typeof(sibnode)}(sibnode)
end

Base.iterate(S::DirectProgenitors, node=S.node) = isnothing(node) ? nothing : (node, next_progenitor_sibling(node))


for func in [
    :first_progenitor,
    :descendant,
    :next_progenitor_sibling,
    :prev_progenitor_sibling,
    :first_progenitor_sibling,
]
    quote
        function $func(h::Halo; kwargs...)
            node = $func(get_tree_node(h; kwargs...))
            return isnothing(node) ? nothing : get_halo(node)
        end
        function $func(h::Subhalo; kwargs...)
            node = $func(get_tree_node(h; kwargs...))
            return isnothing(node) ? nothing : get_subhalo(node)
        end
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
        function $func(h::Halo; kwargs...)
            f = node -> get_halo(node)
            Iterators.map(f, $func(get_tree_node(h; kwargs...)))
        end

        function $func(h::Subhalo; kwargs...)
            f = node -> get_subhalo(node)
            Iterators.map(f, $func(get_tree_node(h; kwargs...)))
        end
    end |> eval
end


"""
    first_progenitor_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real)

Returns the closest first progenitor to the given redshift.

See [`first_progenitors`](@ref).
"""
function first_progenitor_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real; kwargs...)
    currentprog = halo
    prevprog = halo
    current_z = prev_z = redshift(get_snapshot(halo))

    for prog in first_progenitors(halo; kwargs...)
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

function first_progenitor_at(halo::Halo; id, kwargs...)
    node = get_tree_node(halo; kwargs...)
    return first_progenitor_at(node; id) |> get_halo
end

function first_progenitor_at(halo::Subhalo; id, kwargs...)
    node = get_tree_node(halo; kwargs...)
    return first_progenitor_at(node; id) |> get_subhalo
end

function first_progenitor_at(halonode::Union{AbstractHalo,AbstractMergerTreeNode}, snapshot::AbstractSnapshot; kwargs...)
    return first_progenitor_at(halonode; id=get_snapshotid(snapshot), kwargs...)
end


"""
    descendant_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real)

Returns the closest descendant to the given redshift.

See [`descendants`](@ref).
"""
function descendant_at(halo::Union{AbstractHalo,AbstractMergerTreeNode}, z::Real; kwargs...)
    currentdesc = halo
    prevdesc = halo
    current_z = prev_z = redshift(get_snapshot(halo))

    for desc in descendants(halo; kwargs...)
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

function descendant_at(halo::Halo; id, kwargs...)
    node = get_tree_node(halo; kwargs...)
    return descendant_at(node; id) |> get_halo
end

function descendant_at(halo::Subhalo; id, kwargs...)
    node = get_tree_node(halo; kwargs...)
    return descendant_at(node; id) |> get_subhalo
end

function descendant_at(halonode::Union{AbstractHalo,AbstractMergerTreeNode}, snapshot::AbstractSnapshot; kwargs...)
    return descendant_at(halonode; id=get_snapshotid(snapshot), kwargs...)
end
