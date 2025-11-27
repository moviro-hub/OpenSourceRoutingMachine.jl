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
using EnumX: @enumx

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

get_version() = ccall((:osrmc_get_version, libosrmc), Cuint, ())
is_abi_compatible() = ccall((:osrmc_is_abi_compatible, libosrmc), Cint, ()) != 0

include("enums.jl")
include("types.jl")
include("functions.jl")
include("utils/Utils.jl")
include("main.jl")

import .Utils:
    OSRMError, check_error, take_error!, with_error, error_pointer,
    as_string, finalize, as_cstring, as_cstring_or_null,
    as_cint, normalize_enum, to_cint

include("route/Routes.jl")
include("table/Tables.jl")
include("nearest/Nearests.jl")
include("match/Matches.jl")
include("trip/Trips.jl")
include("tile/Tiles.jl")
include("graph/Graphs.jl")

# Pull commonly used symbols into the top-level namespace so users only need to
# depend on `OpenSourceRoutingMachine` rather than its internal structure.
import .Graphs: Profile, OSRMCommandError, profile_lua_path, extract, partition,
    customize, contract
import .Routes: RouteParams, RouteResponse, route, as_json, distance, duration,
    alternative_count, distance_at, duration_at, geometry_polyline, geometry_coordinate_count,
    geometry_coordinate_latitude, geometry_coordinate_longitude, waypoint_count,
    waypoint_latitude, waypoint_longitude, waypoint_name, leg_count, step_count,
    step_distance, step_duration, step_instruction
import .Nearests: NearestParams, NearestResponse, nearest, latitude, longitude, name
import .Tables: TableParams, TableResponse, table
import .Matches: MatchParams, MatchResponse, match, route_count, tracepoint_count,
    route_distance, route_duration, route_confidence, tracepoint_latitude,
    tracepoint_longitude, tracepoint_is_null
import .Trips: TripParams, TripResponse, trip
import .Tiles: TileParams, TileResponse, tile, data, size

export LatLon, Routes

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
    # Graph helpers stay public so build pipelines can script the OSRM CLI flow.
    OSRMCommandError,
    profile_lua_path,
    extract,
    partition,
    customize,
    contract

end # module OpenSourceRoutingMachine
