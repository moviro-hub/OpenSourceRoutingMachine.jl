"""
Test utilities and fixtures for OSRM tests.
"""
module TestUtils

using SHA
using Base.MathConstants: π
using Base.Math: deg2rad, tan, log, cos
using OpenSourceRoutingMachine: OSRM, OSRMConfig, Position
using OpenSourceRoutingMachine.Graphs: extract, partition, customize, Profile, PROFILE_CAR

# Test data paths
const TEST_DATA_DIR = joinpath(@__DIR__, "data")
const HAMBURG_OSM_PATH = joinpath(TEST_DATA_DIR, "hamburg-latest.osm.pbf")
let name = basename(HAMBURG_OSM_PATH)
    while true
        name_no_ext, ext = splitext(name)
        isempty(ext) && break
        name = name_no_ext
    end
    global const HAMBURG_OSRM_BASE = joinpath(TEST_DATA_DIR, name)
end

# Known coordinates in Hamburg for testing
const HAMBURG_COORDINATES = Dict(
    "city_center" => Position(9.9937, 53.5511),
    "airport" => Position(10.006, 53.6325),
    "port" => Position(9.9691, 53.5301),
    "altona" => Position(9.9362, 53.5522),
)

# Match test coordinates - trace from city center to altona
const TRACE_COORDS_CITY_CENTER_TO_ALTONA = [
    Position(9.993674, 53.551113),
    Position(9.994772, 53.551086),
    Position(9.99587, 53.551056),
    Position(9.996967, 53.55103),
    Position(9.998065, 53.551),
    Position(9.999163, 53.550972),
    Position(10.00026, 53.55094),
    Position(10.001358, 53.550915),
    Position(10.002455, 53.550888),
    Position(10.003552, 53.550858),
    Position(10.00465, 53.55083),
    Position(10.005748, 53.5508),
    Position(10.006845, 53.550774),
    Position(10.007943, 53.550743),
    Position(10.009041, 53.550716),
]

# Trace from city center to airport
const TRACE_COORDS_CITY_CENTER_TO_AIRPORT = [
    Position(9.9937, 53.5511),
    Position(9.995, 53.552),
    Position(9.9965, 53.553),
    Position(9.998, 53.554),
    Position(10.0, 53.555),
    Position(10.002, 53.556),
    Position(10.004, 53.557),
    Position(10.006, 53.6325),
]

# Trace from city center to port
const TRACE_COORDS_CITY_CENTER_TO_PORT = [
    Position(9.9937, 53.5511),
    Position(9.992, 53.55),
    Position(9.99, 53.549),
    Position(9.988, 53.548),
    Position(9.9691, 53.5301),
]

"""
    build_osrm_graph(osm_path::String) -> String

Build an OSRM routing graph from OSM data using MLD algorithm.
Returns the base path (without .osrm extension) to the built graph.
"""
function build_osrm_graph(osm_path::String)
    if !isfile(osm_path)
        error("OSM file not found: $osm_path")
    end

    # Remove all extensions (e.g., "file.osm.pbf" -> "file")
    name = basename(osm_path)
    while true
        name_no_ext, ext = splitext(name)
        isempty(ext) && break
        name = name_no_ext
    end
    base = joinpath(dirname(osm_path), name)
    osrm_base_path = "$base.osrm"
    partition_file = "$osrm_base_path.partition"
    hashing_guard = "$osrm_base_path.hash"

    function _current_hash(path)
        return open(path, "r") do io
            bytes2hex(sha256(io))
        end
    end

    if isfile(partition_file) && isfile(hashing_guard)
        recorded = strip(read(hashing_guard, String))
        current = _current_hash(osm_path)
        if recorded == current
            @info "OSRM graph already up to date at $partition_file"
            return base
        end
    end

    @info "Building OSRM MLD graph from $osm_path"
    extract(osm_path; profile = PROFILE_CAR)
    partition(osrm_base_path)
    customize(osrm_base_path)

    current = _current_hash(osm_path)
    open(hashing_guard, "w") do io
        write(io, current)
    end

    return base
end

"""
    get_test_osrm_base_path() -> String

Get the path to the test OSRM graph, building it if necessary.
Returns the base path (without .osrm extension).
"""
function get_test_osrm_base_path()
    return build_osrm_graph(HAMBURG_OSM_PATH)
end

# Cache for the test OSRM instance
const _test_osrm_cache = Ref{Union{OSRM, Nothing}}(nothing)

"""
    get_test_osrm() -> OSRM

Get a shared OSRM instance for testing (cached).
"""
function get_test_osrm()
    if _test_osrm_cache[] === nothing
        _test_osrm_cache[] = OSRM(OSRMConfig(get_test_osrm_base_path()))
    end
    return _test_osrm_cache[]
end

"""
    get_hamburg_coordinates() -> Dict{String, Position}

Get known coordinates in Hamburg for testing.
"""
function get_hamburg_coordinates()
    return HAMBURG_COORDINATES
end

"""
    get_trace_coords_city_center_to_altona() -> Vector{Position}

Get trace coordinates from city center to Altona.
"""
function get_trace_coords_city_center_to_altona()
    return TRACE_COORDS_CITY_CENTER_TO_ALTONA
end

"""
    get_trace_coords_city_center_to_airport() -> Vector{Position}

Get trace coordinates from city center to airport.
"""
function get_trace_coords_city_center_to_airport()
    return TRACE_COORDS_CITY_CENTER_TO_AIRPORT
end

"""
    get_trace_coords_city_center_to_port() -> Vector{Position}

Get trace coordinates from city center to port.
"""
function get_trace_coords_city_center_to_port()
    return TRACE_COORDS_CITY_CENTER_TO_PORT
end

"""
    slippy_tile(lat::Float64, lon::Float64, zoom::Integer) -> Tuple{Int, Int}

Convert lat/lon to slippy tile coordinates (x, y).
"""
function slippy_tile(lat::Float64, lon::Float64, zoom::Integer)
    n = 2.0^zoom
    xtile = floor(Int, (lon + 180.0) / 360.0 * n)
    lat_rad = deg2rad(lat)
    ytile = floor(Int, (1.0 - log(tan(lat_rad) + 1.0 / cos(lat_rad)) / π) / 2.0 * n)
    return xtile, ytile
end

# Exports
export
    # Paths
    TEST_DATA_DIR,
    HAMBURG_OSM_PATH,
    HAMBURG_OSRM_BASE,
    # Coordinates
    HAMBURG_COORDINATES,
    TRACE_COORDS_CITY_CENTER_TO_ALTONA,
    TRACE_COORDS_CITY_CENTER_TO_AIRPORT,
    TRACE_COORDS_CITY_CENTER_TO_PORT,
    # Functions
    build_osrm_graph,
    get_test_osrm_base_path,
    get_test_osrm,
    get_hamburg_coordinates,
    get_trace_coords_city_center_to_altona,
    get_trace_coords_city_center_to_airport,
    get_trace_coords_city_center_to_port,
    slippy_tile

end # module TestUtils
