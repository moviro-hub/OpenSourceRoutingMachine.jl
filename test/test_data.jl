"""
Test data management for downloading and building OSRM graphs.
"""
module TestData

using SHA
using OpenSourceRoutingMachine: build_mld_graph, Profile

const TEST_DATA_DIR = joinpath(@__DIR__, "data")
const HAMBURG_OSM_PATH = joinpath(TEST_DATA_DIR, "hamburg-latest.osm.pbf")
const HAMBURG_OSRM_BASE = joinpath(TEST_DATA_DIR, "osrm-mld", "hamburg-latest")


"""
    build_osrm_graph(osm_path::String, output_base::String) -> String

Build an OSRM routing graph from OSM data using the CH algorithm.
Returns the base path (without .osrm extension) to the built graph.

Steps:
1. osrm-extract: Extract routing data from OSM
2. osrm-contract: Build contraction hierarchies
"""
function build_osrm_graph(osm_path::String, output_base::String)
    if !isfile(osm_path)
        error("OSM file not found: $osm_path")
    end

    mkpath(dirname(output_base))

    osrm_partition_file = "$output_base.osrm.partition"
    hashing_guard = "$output_base.osrm.hash"

    function _current_hash(path)
        open(path, "r") do io
            bytes2hex(sha256(io))
        end
    end

    if isfile(osrm_partition_file) && isfile(hashing_guard)
        recorded = strip(read(hashing_guard, String))
        current = _current_hash(osm_path)
        if recorded == current
            @info "OSRM graph already up to date at $osrm_partition_file"
            return output_base
        end
    end

    @info "Building OSRM MLD graph from $osm_path using OpenSourceRoutingMachine Graph wrappers"
    build_mld_graph(osm_path; profile=Profile.car, output_base=output_base)

    current = _current_hash(osm_path)
    open(hashing_guard, "w") do io
        write(io, current)
    end

    return output_base
end

"""
    get_test_osrm_path() -> String

Get the path to the test OSRM graph, building it if necessary.
Returns the base path (without .osrm extension).
"""
function get_test_osrm_path()
    return build_osrm_graph(HAMBURG_OSM_PATH, HAMBURG_OSRM_BASE)
end

end # module
