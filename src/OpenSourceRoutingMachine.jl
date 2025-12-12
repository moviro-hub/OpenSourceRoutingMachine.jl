"""
    OpenSourceRoutingMachine

A Julia package for routing machine functionality.
Thin wrapper around the libosrmc C API.
"""
module OpenSourceRoutingMachine

# Import modules (not specific functions) so submodules can access them
using OSRM_jll
using libosrmc_jll
using Libdl
using CEnum
using FlatBuffers

function __init__()
    # building with dont_dlopen=true means the JLLs won't autoload so we have to do it manually here.
    return if OSRM_jll.is_available() && libosrmc_jll.is_available()
        dlopen(OSRM_jll.libosrm_path)
        dlopen(libosrmc_jll.libosrmc_path)
    else
        error("OSRM and libosrmc are required to use OpenSourceRoutingMachine.jl")
    end
end

const libosrmc = libosrmc_jll.libosrmc_path

"""
    get_version() -> UInt32

Return the libosrmc/OSRM ABI version that this wrapper is linked against.
"""
get_version() = ccall((:osrmc_get_version, libosrmc), Cuint, ())

"""
    is_abi_compatible() -> Bool

Report whether the loaded libosrmc library matches the version this package
was built against, so callers can fail fast on mismatched binaries.
"""
is_abi_compatible() = ccall((:osrmc_is_abi_compatible, libosrmc), Cint, ()) != 0

include("utils.jl")
include("shared.jl")
include("types.jl")
include("deserialize.jl")
include("main.jl")

include("route/Routes.jl")
include("table/Tables.jl")
include("nearest/Nearests.jl")
include("match/Matches.jl")
include("trip/Trips.jl")
include("tile/Tiles.jl")
include("graph/Graphs.jl")

# Constructor for Position that takes (lon, lat) for convenience
Position(lon::Real, lat::Real) = Position(Float32(lon), Float32(lat))

# types
export OSRM, OSRMConfig, Position
# enums
export Algorithm, Snapping, Approach, OutputFormat, Geometries, Overview, Annotations
# functions
export get_version, is_abi_compatible, set_algorithm!, set_max_locations_trip!, set_max_locations_viaroute!, set_max_locations_distance_table!, set_max_locations_map_matching!, set_max_radius_map_matching!, set_max_results_nearest!, set_default_radius!, set_max_alternatives!, set_use_mmap!, set_use_shared_memory!, set_dataset_name!

end # module OpenSourceRoutingMachine
