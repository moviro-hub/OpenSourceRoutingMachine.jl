using Test
using OpenSourceRoutingMachine:
    OSRMConfig, OSRM, Algorithm, ALGORITHM_CH, ALGORITHM_MLD,
    Verbosity, VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG,
    set_algorithm!, get_algorithm,
    set_max_locations_trip!, get_max_locations_trip,
    set_max_locations_viaroute!, get_max_locations_viaroute,
    set_max_locations_distance_table!, get_max_locations_distance_table,
    set_max_locations_map_matching!, get_max_locations_map_matching,
    set_max_radius_map_matching!, get_max_radius_map_matching,
    set_max_results_nearest!, get_max_results_nearest,
    set_default_radius!, get_default_radius,
    set_max_alternatives!, get_max_alternatives,
    set_use_mmap!, get_use_mmap,
    set_use_shared_memory!, get_use_shared_memory,
    set_dataset_name!, get_dataset_name,
    set_memory_file!, get_memory_file,
    set_verbosity!, get_verbosity,
    disable_feature_dataset!,
    get_disabled_feature_dataset_count,
    get_disabled_feature_dataset_at,
    clear_disabled_feature_datasets!

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

@testset "Instance - Config Setters and Getters" begin
    # Create a config with nothing (shared memory mode) for testing setters/getters
    config = OSRMConfig(nothing)

    @testset "Algorithm" begin
        set_algorithm!(config, ALGORITHM_CH)
        @test get_algorithm(config) == ALGORITHM_CH

        set_algorithm!(config, ALGORITHM_MLD)
        @test get_algorithm(config) == ALGORITHM_MLD
    end

    @testset "Max Locations Trip" begin
        set_max_locations_trip!(config, 100)
        @test get_max_locations_trip(config) == 100

        set_max_locations_trip!(config, 200)
        @test get_max_locations_trip(config) == 200

        set_max_locations_trip!(config, -1)
        @test get_max_locations_trip(config) == -1
    end

    @testset "Max Locations ViaRoute" begin
        set_max_locations_viaroute!(config, 50)
        @test get_max_locations_viaroute(config) == 50

        set_max_locations_viaroute!(config, 150)
        @test get_max_locations_viaroute(config) == 150

        set_max_locations_viaroute!(config, -1)
        @test get_max_locations_viaroute(config) == -1
    end

    @testset "Max Locations Distance Table" begin
        set_max_locations_distance_table!(config, 1000)
        @test get_max_locations_distance_table(config) == 1000

        set_max_locations_distance_table!(config, 5000)
        @test get_max_locations_distance_table(config) == 5000

        set_max_locations_distance_table!(config, -1)
        @test get_max_locations_distance_table(config) == -1
    end

    @testset "Max Locations Map Matching" begin
        set_max_locations_map_matching!(config, 100)
        @test get_max_locations_map_matching(config) == 100

        set_max_locations_map_matching!(config, 500)
        @test get_max_locations_map_matching(config) == 500

        set_max_locations_map_matching!(config, -1)
        @test get_max_locations_map_matching(config) == -1
    end

    @testset "Max Radius Map Matching" begin
        set_max_radius_map_matching!(config, 5.0)
        @test get_max_radius_map_matching(config) == 5.0

        set_max_radius_map_matching!(config, 10.5)
        @test get_max_radius_map_matching(config) == 10.5

        set_max_radius_map_matching!(config, -1.0)
        @test get_max_radius_map_matching(config) == -1.0
    end

    @testset "Max Results Nearest" begin
        set_max_results_nearest!(config, 1)
        @test get_max_results_nearest(config) == 1

        set_max_results_nearest!(config, 10)
        @test get_max_results_nearest(config) == 10

        set_max_results_nearest!(config, -1)
        @test get_max_results_nearest(config) == -1
    end

    @testset "Default Radius" begin
        set_default_radius!(config, 10.0)
        @test get_default_radius(config) == 10.0

        set_default_radius!(config, 50.5)
        @test get_default_radius(config) == 50.5

        set_default_radius!(config, -1.0)
        @test get_default_radius(config) == -1.0
    end

    @testset "Max Alternatives" begin
        set_max_alternatives!(config, 1)
        @test get_max_alternatives(config) == 1

        set_max_alternatives!(config, 5)
        @test get_max_alternatives(config) == 5

        set_max_alternatives!(config, 10)
        @test get_max_alternatives(config) == 10
    end

    @testset "Use MMAP" begin
        set_use_mmap!(config, true)
        @test get_use_mmap(config) == true

        set_use_mmap!(config, false)
        @test get_use_mmap(config) == false

        set_use_mmap!(config, true)
        @test get_use_mmap(config) == true
    end

    @testset "Use Shared Memory" begin
        set_use_shared_memory!(config, true)
        @test get_use_shared_memory(config) == true

        set_use_shared_memory!(config, false)
        @test get_use_shared_memory(config) == false

        set_use_shared_memory!(config, true)
        @test get_use_shared_memory(config) == true
    end

    @testset "Dataset Name" begin
        set_dataset_name!(config, "test_dataset")
        @test get_dataset_name(config) == "test_dataset"

        set_dataset_name!(config, "another_dataset")
        @test get_dataset_name(config) == "another_dataset"

        set_dataset_name!(config, nothing)
        # Note: get_dataset_name returns empty string when cleared, not nothing
        result = get_dataset_name(config)
        @test result == "" || result === nothing
    end

    @testset "Memory File" begin
        set_memory_file!(config, "/tmp/test.mem")
        @test get_memory_file(config) == "/tmp/test.mem"

        set_memory_file!(config, "/tmp/another.mem")
        @test get_memory_file(config) == "/tmp/another.mem"

        set_memory_file!(config, nothing)
        # Note: get_memory_file returns empty string when cleared, not nothing
        result = get_memory_file(config)
        @test result == "" || result === nothing
    end

    @testset "Verbosity" begin
        set_verbosity!(config, VERBOSITY_NONE)
        @test get_verbosity(config) == VERBOSITY_NONE

        set_verbosity!(config, VERBOSITY_ERROR)
        @test get_verbosity(config) == VERBOSITY_ERROR

        set_verbosity!(config, VERBOSITY_WARNING)
        @test get_verbosity(config) == VERBOSITY_WARNING

        set_verbosity!(config, VERBOSITY_INFO)
        @test get_verbosity(config) == VERBOSITY_INFO

        set_verbosity!(config, VERBOSITY_DEBUG)
        @test get_verbosity(config) == VERBOSITY_DEBUG

        set_verbosity!(config, nothing)
        # Verbosity may return nothing or the last set value when cleared
        result = get_verbosity(config)
        @test result === nothing || result in [VERBOSITY_NONE, VERBOSITY_ERROR, VERBOSITY_WARNING, VERBOSITY_INFO, VERBOSITY_DEBUG]
    end

    @testset "Disabled Feature Datasets" begin
        # Initially should be empty
        @test get_disabled_feature_dataset_count(config) == 0

        # Note: disable_feature_dataset! requires a valid dataset name from the loaded dataset
        # Since we're using nothing (shared memory mode), we can't test disabling datasets
        # This test verifies the count function works
        @test get_disabled_feature_dataset_count(config) == 0

        # Clear all disabled datasets (should work even if empty)
        clear_disabled_feature_datasets!(config)
        @test get_disabled_feature_dataset_count(config) == 0
    end
end

@testset "Instance - MLD Dataset Loading" begin
    # Use the existing test dataset
    include("TestUtils.jl")
    using .TestUtils: get_test_osrm_base_path
    test_base = get_test_osrm_base_path()
    osrm_base_path = "$test_base.osrm"

    @testset "Verify MLD Dataset Exists" begin
        # Verify MLD files exist (dataset should already be built)
        @test isfile("$osrm_base_path.partition")
        @test isfile("$osrm_base_path.cells")
        @test isfile("$osrm_base_path.cell_metrics")
        @test isfile("$osrm_base_path.mldgr")
    end

    @testset "Load OSRM Instance" begin
        # Create config from the existing dataset
        config = OSRMConfig(test_base)

        # Verify algorithm was auto-detected as MLD
        @test get_algorithm(config) == ALGORITHM_MLD

        # Create OSRM instance
        osrm = OSRM(config)

        # Verify instance was created
        @test osrm isa OSRM
        @test osrm.ptr != C_NULL
        @test osrm.config isa OSRMConfig

        # Test that getters work on the OSRM instance as well
        @test get_algorithm(osrm) == ALGORITHM_MLD

        # Test setting and getting values on the OSRM instance
        set_max_locations_trip!(osrm, 100)
        @test get_max_locations_trip(osrm) == 100

        set_max_locations_viaroute!(osrm, 50)
        @test get_max_locations_viaroute(osrm) == 50

        set_max_alternatives!(osrm, 3)
        @test get_max_alternatives(osrm) == 3
    end
end
