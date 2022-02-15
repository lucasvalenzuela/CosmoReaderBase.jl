"""
    read_halos(snapshot::AbstractSnapshot, props::AbstractVector{Symbol}) -> Halos

Returns the halos in a snapshot with the specified properties.

# Keyword arguments
For the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref).
"""
function read_halos(::AbstractSnapshot, ::AbstractVector{Symbol}) end

"""
    read_subhalos(snapshot::AbstractSnapshot, props::AbstractVector{Symbol}) -> Subhalos

Returns the subhalos in a snapshot with the specified properties.

# Keyword arguments
For the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref).
"""
function read_subhalos(::AbstractSnapshot, ::AbstractVector{Symbol}) end

# """
# read_halos_in_cuboid(snapshot::AbstractSnapshot, props::AbstractVector{<:Symbol}, lowerleft::AbstractArray, upperright::AbstractArray) -> Halos

# Returns the halos within the cuboid given by the lower left and upper right corner in a snapshot with the
# specified properties.
# Particles are shifted across the box borders if the cuboid reaches across the borders and the box is periodic.

# # Keyword arguments
# For the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref), and additionally:
# - `shift_to_center=false`: if `true`, the particle positions are shifted such that `centerpos` becomes the
# origin. Particles are shifted across the box borders if the box is periodic.
# """
# function read_halos_in_cuboid(
# ::AbstractSnapshot,
# ::AbstractVector{Symbol},
# ::AbstractVector,
# ::AbstractVector,
# ) end

# """
# read_subhalos_in_cuboid(snapshot::AbstractSnapshot, props::AbstractVector{<:Symbol}, lowerleft::AbstractArray, upperright::AbstractArray) -> Halos

# Returns the subhalos within the cuboid given by the lower left and upper right corner in a snapshot with the
# specified properties.

# Like [`read_halos_in_cuboid`](@ref), just for subhalos.
# """
# function read_subhalos_in_cuboid(
# ::AbstractSnapshot,
# ::AbstractVector{Symbol},
# ::AbstractVector,
# ::AbstractVector,
# ) end

"""
    read_halos(snapshot::AbstractSnapshot, props::AbstractVector{<:Symbol}, ids::AbstractVector) -> Halos

Returns the halos with the given ids in a snapshot with the specified properties.

For the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref), and additionally:
"""
function read_halos(::AbstractSnapshot, ::AbstractVector{Symbol}, ::AbstractVector) end

"""
    read_subhalos(snapshot::AbstractSnapshot, props::AbstractVector{<:Symbol}, ids::AbstractVector) -> Subhalos

Returns the subhalos with the given ids in a snapshot with the specified properties.

For the possible keywords, see [`read_particles(::AbstractSnapshot)`](@ref), and additionally:
"""
function read_subhalos(::AbstractSnapshot, ::AbstractVector{Symbol}, ::AbstractVector) end
