"""
Test data management for downloading and building OSRM graphs.
"""
module TestData

using SHA
using OpenSourceRoutingMachine: build_mld_graph, Profile

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


"""
    build_osrm_graph(osm_path::String) -> String

Build an OSRM routing graph from OSM data using MLD algorithm.
Returns the base path (without .osrm extension) to the built graph.

Output files are created in the same directory as the input file (OSRM 6.0 default).

Steps:
1. osrm-extract: Extract routing data from OSM
2. osrm-partition: Partition the graph for MLD
3. osrm-customize: Customize the graph for MLD
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
    osrm_partition_file = "$base.osrm.partition"
    hashing_guard = "$base.osrm.hash"

    function _current_hash(path)
        return open(path, "r") do io
            bytes2hex(sha256(io))
        end
    end

    if isfile(osrm_partition_file) && isfile(hashing_guard)
        recorded = strip(read(hashing_guard, String))
        current = _current_hash(osm_path)
        if recorded == current
            @info "OSRM graph already up to date at $osrm_partition_file"
            return base
        end
    end

    @info "Building OSRM MLD graph from $osm_path using OpenSourceRoutingMachine Graph wrappers"
    build_mld_graph(osm_path; profile = Profile.car)

    current = _current_hash(osm_path)
    open(hashing_guard, "w") do io
        write(io, current)
    end

    return base
end

"""
    get_test_osrm_path() -> String

Get the path to the test OSRM graph, building it if necessary.
Returns the base path (without .osrm extension).
"""
function get_test_osrm_path()
    return build_osrm_graph(HAMBURG_OSM_PATH)
end

end # module
