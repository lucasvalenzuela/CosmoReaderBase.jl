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
