"""
    OpenSourceRoutingMachine

A thin Julia wrapper for OSRM (Open Source Routing Machine), a high-performance tool for route planning in road networks.

This package provides a complete interface to OSRM's routing capabilities, including:
- **Graph**: Builds OSRM graphs from OpenStreetMap data
- **Nearest**: Find the nearest waypoint in a road network for a given position
- **Route**: Find a route between waypoints containing detailed information
- **Table**: Find distance/duration matrices between multiple source and destination waypoints
- **Match**: Find a route by map matching noisy GPS traces to a road network
- **Trip**: Find a route by solving the traveling salesman problem
- **Tile**: Retrieve road network geometry as vector tiles

All modules expose the full configuration and parameter handling API of OSRM through setter and getter functions.
They also provide fine-grained control over query behavior.
The output format is restricted to FlatBuffers for all modules except the Tile module, which returns road network geometry in MVT format.
"""
module OpenSourceRoutingMachine

# Import modules (not specific functions) so submodules can access them
using OSRM_jll
using libosrmc_jll
using Libdl
using CEnum
using FlatBuffers

function __init__()
    # Building with dont_dlopen=true means the JLLs won't autoload, so we load them manually here.
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

include("types.jl")
include("shared.jl")
include("utils.jl")
include("instance.jl")

include("route/Route.jl")
include("table/Table.jl")
include("nearest/Nearest.jl")
include("match/Match.jl")
include("trip/Trip.jl")
include("tile/Tile.jl")
include("graph/Graph.jl")

"""
    Position(lon::Real, lat::Real) -> Position

Constructor for Position that accepts real numbers (converts to Float32).
"""
Position(lon::Real, lat::Real) = Position(Float32(lon), Float32(lat))

# types
export OSRM, OSRMConfig, OSRMError, Position
# enums
export Algorithm, ALGORITHM_CH, ALGORITHM_MLD,
    Snapping, SNAPPING_DEFAULT, SNAPPING_ANY,
    Approach, APPROACH_CURB, APPROACH_UNRESTRICTED, APPROACH_OPPOSITE,
    Geometries, GEOMETRIES_POLYLINE, GEOMETRIES_POLYLINE6, GEOMETRIES_GEOJSON,
    Overview, OVERVIEW_SIMPLIFIED, OVERVIEW_FULL, OVERVIEW_FALSE,
    Annotations, ANNOTATIONS_NONE, ANNOTATIONS_DURATION, ANNOTATIONS_NODES,
    ANNOTATIONS_DISTANCE, ANNOTATIONS_WEIGHT, ANNOTATIONS_DATASOURCES,
    ANNOTATIONS_SPEED, ANNOTATIONS_ALL,
    Verbosity, VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG
# helper
export get_version, is_abi_compatible
# setter
export set_algorithm!, set_max_locations_trip!, set_max_locations_viaroute!, set_max_locations_distance_table!,
    set_max_locations_map_matching!, set_max_radius_map_matching!, set_max_results_nearest!, set_default_radius!,
    set_max_alternatives!, set_use_mmap!, set_use_shared_memory!, set_dataset_name!, set_memory_file!, set_verbosity!,
    disable_feature_dataset!, clear_disabled_feature_datasets!
# getter
export get_algorithm, get_max_locations_trip, get_max_locations_viaroute, get_max_locations_distance_table,
    get_max_locations_map_matching, get_max_radius_map_matching, get_max_results_nearest, get_default_radius,
    get_max_alternatives, get_use_mmap, get_use_shared_memory, get_dataset_name, get_memory_file, get_verbosity,
    get_disabled_feature_dataset_count, get_disabled_feature_dataset_at

# FlatBuffer enums
public ManeuverType, MANEUVER_TYPE_TURN, MANEUVER_TYPE_NEW_NAME, MANEUVER_TYPE_DEPART, MANEUVER_TYPE_ARRIVE,
    MANEUVER_TYPE_MERGE, MANEUVER_TYPE_ON_RAMP, MANEUVER_TYPE_OFF_RAMP, MANEUVER_TYPE_FORK, MANEUVER_TYPE_END_OF_ROAD,
    MANEUVER_TYPE_CONTINUE, MANEUVER_TYPE_ROUNDABOUT, MANEUVER_TYPE_ROTARY, MANEUVER_TYPE_ROUNDABOUT_TURN,
    MANEUVER_TYPE_NOTIFICATION, MANEUVER_TYPE_EXIT_ROUNDABOUT, MANEUVER_TYPE_EXIT_ROTARY,
    Turn, TURN_NONE, TURN_U_TURN, TURN_SHARP_RIGHT, TURN_RIGHT, TURN_SLIGHT_RIGHT, TURN_STRAIGHT, TURN_SLIGHT_LEFT,
    TURN_LEFT, TURN_SHARP_LEFT
# FlatBuffer structs
public Uint64Pair
# FlatBuffer tables
public StepManeuver, Error, Waypoint, Lane, Metadata, TableResult, Intersection, Annotation, Step, Leg, RouteObject, FBResult

end # module OpenSourceRoutingMachine
