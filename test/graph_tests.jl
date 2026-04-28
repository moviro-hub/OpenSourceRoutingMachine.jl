using Test
using OpenSourceRoutingMachine.Graph: extract, contract, partition, customize, Profile, PROFILE_CAR

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Graph - CH (Contraction Hierarchy)" begin
    # Use a temporary copy of the PBF file for testing
    test_pbf = TestUtils.get_or_create_test_pbf("test_ch")
    test_base = TestUtils.get_osrm_base_path(test_pbf)

    @testset "Step 1: Ensure only PBF exists" begin
        @test TestUtils.ensure_only_pbf_exists(test_pbf)
    end

    @testset "Step 2: Extract" begin
        extract(test_pbf; profile = PROFILE_CAR)
        @test TestUtils.check_extract_files_exist(test_base)
    end

    @testset "Step 3: Contract" begin
        osrm_base_path = "$test_base.osrm"
        contract(osrm_base_path)
        @test TestUtils.check_contract_files_exist(test_base)
    end

    @testset "Step 4: Cleanup" begin
        TestUtils.delete_osrm_files(test_base)
        files = TestUtils.get_all_osrm_files(test_base)
        @test isempty(files)
        @test isfile(test_pbf)
    end
end

@testset "Graph - MLD (Multi-Level Dijkstra)" begin
    # Use a temporary copy of the PBF file for testing
    test_pbf = TestUtils.get_or_create_test_pbf("test_mld")
    test_base = TestUtils.get_osrm_base_path(test_pbf)

    @testset "Step 1: Ensure only PBF exists" begin
        @test TestUtils.ensure_only_pbf_exists(test_pbf)
    end

    @testset "Step 2: Extract" begin
        extract(test_pbf; profile = PROFILE_CAR)
        @test TestUtils.check_extract_files_exist(test_base)
    end

    @testset "Step 3: Partition" begin
        osrm_base_path = "$test_base.osrm"
        partition(osrm_base_path)
        @test TestUtils.check_partition_files_exist(test_base)
    end

    @testset "Step 4: Customize" begin
        osrm_base_path = "$test_base.osrm"
        customize(osrm_base_path)
        @test TestUtils.check_customize_files_exist(test_base)
    end

    @testset "Step 5: Cleanup" begin
        TestUtils.delete_osrm_files(test_base)
        files = TestUtils.get_all_osrm_files(test_base)
        @test isempty(files)
        @test isfile(test_pbf)
    end
end

@testset "Graph - MLD with spaces in path" begin
    # Regression test: OSRM's Boost.ProgramOptions rejects positional
    # arguments that contain spaces.  The _run_osrm_cmd workaround
    # symlinks files into a temp directory to avoid this.
    space_dir = mktempdir() * "/path with spaces"
    mkpath(space_dir)

    test_pbf = joinpath(space_dir, "hamburg.osm.pbf")
    cp(TestUtils.HAMBURG_OSM_PATH, test_pbf)
    test_base = TestUtils.get_osrm_base_path(test_pbf)

    @testset "Extract with spaces" begin
        extract(test_pbf; profile = PROFILE_CAR)
        @test TestUtils.check_extract_files_exist(test_base)
    end

    @testset "Partition with spaces" begin
        partition("$test_base.osrm")
        @test TestUtils.check_partition_files_exist(test_base)
    end

    @testset "Customize with spaces" begin
        customize("$test_base.osrm")
        @test TestUtils.check_customize_files_exist(test_base)
    end

    @testset "Route with spaces" begin
        using OpenSourceRoutingMachine
        using OpenSourceRoutingMachine.Route
        osrm = OSRM("$test_base.osrm")
        params = RouteParams()
        set_geometries!(params, GEOMETRIES_GEOJSON)
        set_overview!(params, OVERVIEW_FULL)
        add_coordinate!(params, Position(9.9937, 53.5511))
        add_coordinate!(params, Position(10.0055, 53.6303))
        response = route(osrm, params)
        @test length(response.routes) >= 1
        @test response.routes[1].distance > 0
        # Finalize the OSRM instance so file handles are released
        # before cleanup — Windows locks open files (EBUSY).
        finalize(osrm)
    end

    rm(space_dir; recursive = true, force = true)
end
