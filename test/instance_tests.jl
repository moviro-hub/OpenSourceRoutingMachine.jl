using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

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
    matching_files = filter(
        f -> startswith(f, base_name) &&
            (occursin(r"\.osrm\.", f) || endswith(f, ".osrm")),
        all_files
    )
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
    return
end

@testset "Instance - Config Setters and Getters" begin
    # Create a config with nothing (shared memory mode) for testing setters/getters
    config = OSRMs.OSRMConfig(nothing)

    @testset "Algorithm" begin
        OSRMs.set_algorithm!(config, OSRMs.ALGORITHM_CH)
        @test OSRMs.get_algorithm(config) == OSRMs.ALGORITHM_CH

        OSRMs.set_algorithm!(config, OSRMs.ALGORITHM_MLD)
        @test OSRMs.get_algorithm(config) == OSRMs.ALGORITHM_MLD
    end

    @testset "Max Locations Trip" begin
        OSRMs.set_max_locations_trip!(config, 100)
        @test OSRMs.get_max_locations_trip(config) == 100

        OSRMs.set_max_locations_trip!(config, 200)
        @test OSRMs.get_max_locations_trip(config) == 200

        OSRMs.set_max_locations_trip!(config, -1)
        @test OSRMs.get_max_locations_trip(config) == -1
    end

    @testset "Max Locations ViaRoute" begin
        OSRMs.set_max_locations_viaroute!(config, 50)
        @test OSRMs.get_max_locations_viaroute(config) == 50

        OSRMs.set_max_locations_viaroute!(config, 150)
        @test OSRMs.get_max_locations_viaroute(config) == 150

        OSRMs.set_max_locations_viaroute!(config, -1)
        @test OSRMs.get_max_locations_viaroute(config) == -1
    end

    @testset "Max Locations Distance Table" begin
        OSRMs.set_max_locations_distance_table!(config, 1000)
        @test OSRMs.get_max_locations_distance_table(config) == 1000

        OSRMs.set_max_locations_distance_table!(config, 5000)
        @test OSRMs.get_max_locations_distance_table(config) == 5000

        OSRMs.set_max_locations_distance_table!(config, -1)
        @test OSRMs.get_max_locations_distance_table(config) == -1
    end

    @testset "Max Locations Map Matching" begin
        OSRMs.set_max_locations_map_matching!(config, 100)
        @test OSRMs.get_max_locations_map_matching(config) == 100

        OSRMs.set_max_locations_map_matching!(config, 500)
        @test OSRMs.get_max_locations_map_matching(config) == 500

        OSRMs.set_max_locations_map_matching!(config, -1)
        @test OSRMs.get_max_locations_map_matching(config) == -1
    end

    @testset "Max Radius Map Matching" begin
        OSRMs.set_max_radius_map_matching!(config, 5.0)
        @test OSRMs.get_max_radius_map_matching(config) == 5.0

        OSRMs.set_max_radius_map_matching!(config, 10.5)
        @test OSRMs.get_max_radius_map_matching(config) == 10.5

        OSRMs.set_max_radius_map_matching!(config, -1.0)
        @test OSRMs.get_max_radius_map_matching(config) == -1.0
    end

    @testset "Max Results Nearest" begin
        OSRMs.set_max_results_nearest!(config, 1)
        @test OSRMs.get_max_results_nearest(config) == 1

        OSRMs.set_max_results_nearest!(config, 10)
        @test OSRMs.get_max_results_nearest(config) == 10

        OSRMs.set_max_results_nearest!(config, -1)
        @test OSRMs.get_max_results_nearest(config) == -1
    end

    @testset "Default Radius" begin
        OSRMs.set_default_radius!(config, 10.0)
        @test OSRMs.get_default_radius(config) == 10.0

        OSRMs.set_default_radius!(config, 50.5)
        @test OSRMs.get_default_radius(config) == 50.5

        OSRMs.set_default_radius!(config, -1.0)
        @test OSRMs.get_default_radius(config) == -1.0
    end

    @testset "Max Alternatives" begin
        OSRMs.set_max_alternatives!(config, 1)
        @test OSRMs.get_max_alternatives(config) == 1

        OSRMs.set_max_alternatives!(config, 5)
        @test OSRMs.get_max_alternatives(config) == 5

        OSRMs.set_max_alternatives!(config, 10)
        @test OSRMs.get_max_alternatives(config) == 10
    end

    @testset "Use MMAP" begin
        OSRMs.set_use_mmap!(config, true)
        @test OSRMs.get_use_mmap(config) == true

        OSRMs.set_use_mmap!(config, false)
        @test OSRMs.get_use_mmap(config) == false

        OSRMs.set_use_mmap!(config, true)
        @test OSRMs.get_use_mmap(config) == true
    end

    @testset "Use Shared Memory" begin
        OSRMs.set_use_shared_memory!(config, true)
        @test OSRMs.get_use_shared_memory(config) == true

        OSRMs.set_use_shared_memory!(config, false)
        @test OSRMs.get_use_shared_memory(config) == false

        OSRMs.set_use_shared_memory!(config, true)
        @test OSRMs.get_use_shared_memory(config) == true
    end

    @testset "Dataset Name" begin
        OSRMs.set_dataset_name!(config, "test_dataset")
        @test OSRMs.get_dataset_name(config) == "test_dataset"

        OSRMs.set_dataset_name!(config, "another_dataset")
        @test OSRMs.get_dataset_name(config) == "another_dataset"

        OSRMs.set_dataset_name!(config, nothing)
        # Note: get_dataset_name returns empty string when cleared, not nothing
        result = OSRMs.get_dataset_name(config)
        @test result == "" || result === nothing
    end

    @testset "Memory File" begin
        OSRMs.set_memory_file!(config, "/tmp/test.mem")
        @test OSRMs.get_memory_file(config) == "/tmp/test.mem"

        OSRMs.set_memory_file!(config, "/tmp/another.mem")
        @test OSRMs.get_memory_file(config) == "/tmp/another.mem"

        OSRMs.set_memory_file!(config, nothing)
        # Note: get_memory_file returns empty string when cleared, not nothing
        result = OSRMs.get_memory_file(config)
        @test result == "" || result === nothing
    end

    @testset "Verbosity" begin
        OSRMs.set_verbosity!(config, OSRMs.VERBOSITY_NONE)
        @test OSRMs.get_verbosity(config) == OSRMs.VERBOSITY_NONE

        OSRMs.set_verbosity!(config, OSRMs.VERBOSITY_ERROR)
        @test OSRMs.get_verbosity(config) == OSRMs.VERBOSITY_ERROR

        OSRMs.set_verbosity!(config, OSRMs.VERBOSITY_WARNING)
        @test OSRMs.get_verbosity(config) == OSRMs.VERBOSITY_WARNING

        OSRMs.set_verbosity!(config, OSRMs.VERBOSITY_INFO)
        @test OSRMs.get_verbosity(config) == OSRMs.VERBOSITY_INFO

        OSRMs.set_verbosity!(config, OSRMs.VERBOSITY_DEBUG)
        @test OSRMs.get_verbosity(config) == OSRMs.VERBOSITY_DEBUG

        OSRMs.set_verbosity!(config, nothing)
        # Verbosity may return nothing or the last set value when cleared
        result = OSRMs.get_verbosity(config)
        @test result === nothing || result in [OSRMs.VERBOSITY_NONE, OSRMs.VERBOSITY_ERROR, OSRMs.VERBOSITY_WARNING, OSRMs.VERBOSITY_INFO, OSRMs.VERBOSITY_DEBUG]
    end

    @testset "Disabled Feature Datasets" begin
        # Initially should be empty
        @test OSRMs.get_disabled_feature_dataset_count(config) == 0

        # Note: disable_feature_dataset! requires a valid dataset name from the loaded dataset
        # Since we're using nothing (shared memory mode), we can't test disabling datasets
        # This test verifies the count function works
        @test OSRMs.get_disabled_feature_dataset_count(config) == 0

        # Clear all disabled datasets (should work even if empty)
        OSRMs.clear_disabled_feature_datasets!(config)
        @test OSRMs.get_disabled_feature_dataset_count(config) == 0
    end
end

@testset "Instance - MLD Dataset Loading" begin
    # Use the existing test dataset
    test_base = TestUtils.get_test_osrm_base_path()
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
        config = OSRMs.OSRMConfig(test_base)

        # Verify algorithm was auto-detected as MLD
        @test OSRMs.get_algorithm(config) == OSRMs.ALGORITHM_MLD

        # Create OSRM instance
        osrm = OSRMs.OSRM(config)

        # Verify instance was created
        @test osrm isa OSRMs.OSRM
        @test osrm.ptr != Base.C_NULL
        @test osrm.config isa OSRMs.OSRMConfig

        # Test that getters work on the OSRM instance as well
        @test OSRMs.get_algorithm(osrm) == OSRMs.ALGORITHM_MLD

        # Test setting and getting values on the OSRM instance
        OSRMs.set_max_locations_trip!(osrm, 100)
        @test OSRMs.get_max_locations_trip(osrm) == 100

        OSRMs.set_max_locations_viaroute!(osrm, 50)
        @test OSRMs.get_max_locations_viaroute(osrm) == 50

        OSRMs.set_max_alternatives!(osrm, 3)
        @test OSRMs.get_max_alternatives(osrm) == 3
    end
end
