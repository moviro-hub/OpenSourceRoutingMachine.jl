"""
    OpenSourceRoutingMachine

A Julia package for routing machine functionality.
Thin wrapper around the libosrmc C API.
"""
module OpenSourceRoutingMachine

# Import modules (not specific functions) so submodules can access them
using OSRM_jll
using libosrmc_jll
using Libdl: dlopen

function __init__()
    # building with dont_dlopen=true means the JLLs won't autoload so we have to do it manually here.
    return if OSRM_jll.is_available() && libosrmc_jll.is_available()
        dlopen(OSRM_jll.libosrm_path)
        dlopen(libosrmc_jll.libosrmc_path)
    else
        error("OSRM and libosrmc are required to use OpenSourceRoutingMachine.jl")
    end
end

"""
    LatLon

A named tuple representing a latitude and longitude coordinate.
"""
const LatLon = NamedTuple{(:lat, :lon), Tuple{Float32, Float32}}
LatLon(lat::Real, lon::Real) = (lat = Float32(lat), lon = Float32(lon))

"""
    distance(response, ...) -> Float32

Compute distance from OSRM response objects. Methods are defined for:
- `RouteResponse`: returns total route distance
- `NearestResponse`: returns distance to nearest point at given index
- `TripResponse`: returns total trip distance
"""
function distance end

"""
    duration(response, ...) -> Float32

Compute duration from OSRM response objects. Methods are defined for:
- `RouteResponse`: returns total route duration
- `TripResponse`: returns total trip duration
"""
function duration end

# Load all submodules up front so their symbols can be re-exported from this
# entrypoint module without requiring callers to `include` anything manually.
include("c_wrapper.jl")
include("enums.jl")
include("error.jl")
include("config.jl")
include("params.jl")
include("utils.jl")
include("route.jl")
include("table.jl")
include("nearest.jl")
include("match.jl")
include("trip.jl")
include("tile.jl")
include("graph.jl")

# Pull commonly used symbols into the top-level namespace so users only need to
# depend on `OpenSourceRoutingMachine` rather than its internal structure.
import .Enums: OutputFormat, Snapping, Approach, Profile, to_cint
import .Error: OSRMError
import .Config: OSRMConfig, OSRM, get_version, is_abi_compatible
import .Params: RouteParams, TableParams, NearestParams, MatchParams, TripParams, TileParams,
    add_coordinate!, add_coordinate_with!, add_steps!, add_alternatives!,
    set_annotations!, add_source!, add_destination!,
    set_number_of_results!, add_timestamp!,
    set_snapping!, set_format!, set_approach!, add_exclude!, set_generate_hints!,
    set_skip_waypoints!, add_waypoint!, clear_waypoints!, set_geometries!, set_overview!,
    set_continue_straight!, set_number_of_alternatives!, set_annotations_mask!,
    set_fallback_speed!, set_fallback_coordinate_type!, set_scale_factor!,
    set_gaps!, set_tidy!, add_roundtrip!, set_x!, set_y!, set_z!
import .Graph: OSRMCommandError, profile_lua_path, osrm_extract, osrm_partition, osrm_customize,
    osrm_contract, build_mld_graph, build_ch_graph
import .Route: RouteResponse, route, route_with
import .Nearest: NearestResponse, nearest, latitude, longitude, name
import .Table: TableResponse, table
import .Match: MatchResponse, match, route_count, tracepoint_count, route_distance,
    route_duration, route_confidence, tracepoint_latitude, tracepoint_longitude,
    tracepoint_is_null
import .Trip: TripResponse, trip
import .Tile: TileResponse, tile, data, size
import .Trip: TripResponse, trip

export LatLon

# Re-export the public API so downstream packages treat this module as the sole
# integration surface, regardless of the internal module layout.
export
    OSRMError,
    OSRMConfig,
    OSRM,
    get_version,
    is_abi_compatible,
    RouteParams,
    TableParams,
    NearestParams,
    MatchParams,
    TripParams,
    TileParams,
    Profile,
    add_coordinate!,
    add_coordinate_with!,
    add_steps!,
    add_alternatives!,
    set_annotations!,
    add_source!,
    add_destination!,
    set_number_of_results!,
    add_timestamp!,
    set_snapping!,
    set_format!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    add_waypoint!,
    clear_waypoints!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations_mask!,
    set_fallback_speed!,
    set_fallback_coordinate_type!,
    set_scale_factor!,
    set_gaps!,
    set_tidy!,
    add_roundtrip!,
    set_x!,
    set_y!,
    set_z!,
    # Service-specific exports keep downstream code from reaching into internal
    # modules just to call the OSRM HTTP-equivalent APIs.
    RouteResponse,
    route,
    route_with,
    distance,
    duration,
    TableResponse,
    table,
    NearestResponse,
    nearest,
    latitude,
    longitude,
    name,
    MatchResponse,
    match,
    route_count,
    tracepoint_count,
    route_distance,
    route_duration,
    route_confidence,
    tracepoint_latitude,
    tracepoint_longitude,
    tracepoint_is_null,
    TripResponse,
    trip,
    TileResponse,
    tile,
    data,
    size,
    TripResponse,
    trip,
    # Graph helpers stay public so build pipelines can script the OSRM CLI flow.
    OSRMCommandError,
    profile_lua_path,
    osrm_extract,
    osrm_partition,
    osrm_customize,
    osrm_contract,
    build_mld_graph,
    build_ch_graph

end # module OpenSourceRoutingMachine
