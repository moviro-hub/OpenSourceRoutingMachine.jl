using Test
using OpenSourceRoutingMachine.Graphs: extract, contract, partition, customize, Profile, PROFILE_CAR

include("TestUtils.jl")
using .TestUtils: TEST_DATA_DIR, HAMBURG_OSM_PATH

"""
    get_osrm_base_path(osm_path::String) -> String

Get the base path (without .osrm extension) for OSRM files created from an OSM file.
"""
function get_osrm_base_path(osm_path::String)::String
    name = basename(osm_path)
    while true
        name_no_ext, ext = splitext(name)
        isempty(ext) && break
        name = name_no_ext
    end
    return joinpath(dirname(osm_path), name)
end

"""
    get_all_osrm_files(base_path::String) -> Vector{String}

Get all .osrm.* files (excluding .pbf) for a given base path.
"""
function get_all_osrm_files(base_path::String)::Vector{String}
    dir = dirname(base_path)
    base_name = basename(base_path)
    all_files = readdir(dir)
    # Match files that start with base_name and contain .osrm. or end with .osrm
    matching_files = filter(f -> startswith(f, base_name) &&
                                  (occursin(r"\.osrm\.", f) || endswith(f, ".osrm")),
                            all_files)
    return [joinpath(dir, f) for f in matching_files]
end

"""
    delete_osrm_files(base_path::String)

Delete all .osrm.* files (excluding .pbf) for a given base path.
"""
function delete_osrm_files(base_path::String)
    files = get_all_osrm_files(base_path)
    for file in files
        if isfile(file)
            rm(file)
        end
    end
end

"""
    ensure_only_pbf_exists(osm_path::String)

Ensure only the .pbf file exists, deleting all other .osrm.* files.
"""
function ensure_only_pbf_exists(osm_path::String)
    base_path = get_osrm_base_path(osm_path)
    delete_osrm_files(base_path)
    @test isfile(osm_path)
    files = get_all_osrm_files(base_path)
    @test isempty(files)
end

"""
    check_extract_files_exist(base_path::String)

Check that files created by extract() exist.
"""
function check_extract_files_exist(base_path::String)
    osrm_base = "$base_path.osrm"
    required_files = [
        "$osrm_base.ebg",
        "$osrm_base.ebg_nodes",
        "$osrm_base.enw",
        "$osrm_base.fileIndex",
        "$osrm_base.geometry",
        "$osrm_base.icd",
        "$osrm_base.names",
        "$osrm_base.nbg_nodes",
        "$osrm_base.properties",
        "$osrm_base.ramIndex",
        "$osrm_base.restrictions",
        "$osrm_base.timestamp",
        "$osrm_base.edges",
    ]
    for file in required_files
        @test isfile(file)
    end
end

"""
    check_contract_files_exist(base_path::String)

Check that files created by contract() exist.
"""
function check_contract_files_exist(base_path::String)
    osrm_base = "$base_path.osrm"
    required_file = "$osrm_base.hsgr"
    @test isfile(required_file)
end

"""
    check_partition_files_exist(base_path::String)

Check that files created by partition() exist.
"""
function check_partition_files_exist(base_path::String)
    osrm_base = "$base_path.osrm"
    required_files = [
        "$osrm_base.partition",
        "$osrm_base.cells",
        "$osrm_base.cnbg",
        "$osrm_base.cnbg_to_ebg",
    ]
    for file in required_files
        @test isfile(file)
    end
end

"""
    check_customize_files_exist(base_path::String)

Check that files created by customize() exist.
"""
function check_customize_files_exist(base_path::String)
    osrm_base = "$base_path.osrm"
    required_files = [
        "$osrm_base.cell_metrics",
        "$osrm_base.mldgr",
    ]
    for file in required_files
        @test isfile(file)
    end
end

@testset "Graph - CH (Contraction Hierarchy)" begin
    # Use a temporary copy of the PBF file for testing
    test_pbf = joinpath(TEST_DATA_DIR, "test_ch_hamburg-latest.osm.pbf")
    test_base = get_osrm_base_path(test_pbf)

    # Copy the original PBF if test file doesn't exist
    if !isfile(test_pbf)
        cp(HAMBURG_OSM_PATH, test_pbf)
    end

    @testset "Step 1: Ensure only PBF exists" begin
        ensure_only_pbf_exists(test_pbf)
    end

    @testset "Step 2: Extract" begin
        extract(test_pbf; profile=PROFILE_CAR)
        check_extract_files_exist(test_base)
    end

    @testset "Step 3: Contract" begin
        osrm_base_path = "$test_base.osrm"
        contract(osrm_base_path)
        check_contract_files_exist(test_base)
    end

    @testset "Step 4: Cleanup" begin
        delete_osrm_files(test_base)
        files = get_all_osrm_files(test_base)
        @test isempty(files)
        @test isfile(test_pbf)
    end
end

@testset "Graph - MLD (Multi-Level Dijkstra)" begin
    # Use a temporary copy of the PBF file for testing
    test_pbf = joinpath(TEST_DATA_DIR, "test_mld_hamburg-latest.osm.pbf")
    test_base = get_osrm_base_path(test_pbf)

    # Copy the original PBF if test file doesn't exist
    if !isfile(test_pbf)
        cp(HAMBURG_OSM_PATH, test_pbf)
    end

    @testset "Step 1: Ensure only PBF exists" begin
        ensure_only_pbf_exists(test_pbf)
    end

    @testset "Step 2: Extract" begin
        extract(test_pbf; profile=PROFILE_CAR)
        check_extract_files_exist(test_base)
    end

    @testset "Step 3: Partition" begin
        osrm_base_path = "$test_base.osrm"
        partition(osrm_base_path)
        check_partition_files_exist(test_base)
    end

    @testset "Step 4: Customize" begin
        osrm_base_path = "$test_base.osrm"
        customize(osrm_base_path)
        check_customize_files_exist(test_base)
    end

    @testset "Step 5: Cleanup" begin
        delete_osrm_files(test_base)
        files = get_all_osrm_files(test_base)
        @test isempty(files)
        @test isfile(test_pbf)
    end
end
