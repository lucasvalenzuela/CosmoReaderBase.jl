```@meta
CurrentModule = CosmoReaderBase
```

# Merger Trees

## Tree Type

```@docs
AbstractMergerTree
get_simulation(::AbstractMergerTree)
```

## Halo & Merger Tree Node Types

```@docs
AbstractMergerTreeNode
get_tree(::AbstractHalo)
get_tree(::AbstractMergerTreeNode)
get_snapshot(::AbstractMergerTreeNode)
has_prop(::AbstractMergerTreeNode, prop)
read_prop(::AbstractMergerTreeNode, prop)
get_halo(::AbstractMergerTreeNode)
get_subhalo(::AbstractMergerTreeNode)
get_tree_node
```

## Traversing

```@docs
first_progenitor
first_progenitor_at
descendant
descendant_at
next_progenitor_sibling
prev_progenitor_sibling
first_progenitor_sibling
```

## Traverse Iteration

```@docs
first_progenitors
first_progenitors_and_self
descendants
descendants_and_self
direct_progenitors
progenitor_siblings
```

## Developer's API

```@docs
read_prop_simunits(::AbstractMergerTreeNode, prop)
convert_halonode_prop
```
