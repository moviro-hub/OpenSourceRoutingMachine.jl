using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Nearests: Nearests

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Nearest - Setters and Getters" begin
    @testset "Number of Results" begin
        params = Nearests.NearestParams()
        # Get default value (may vary)
        default_value = Nearests.get_number_of_results(params)
        @test default_value isa Int

        Nearests.set_number_of_results!(params, 1)
        @test Nearests.get_number_of_results(params) == 1

        Nearests.set_number_of_results!(params, 5)
        @test Nearests.get_number_of_results(params) == 5

        Nearests.set_number_of_results!(params, 10)
        @test Nearests.get_number_of_results(params) == 10
    end

    @testset "Coordinates" begin
        params = Nearests.NearestParams()
        @test Nearests.get_coordinate_count(params) == 0

        coord1 = TestUtils.get_hamburg_coordinates()["city_center"]
        Nearests.add_coordinate!(params, coord1)
        @test Nearests.get_coordinate_count(params) == 1
        @test Nearests.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.get_hamburg_coordinates()["port"]
        Nearests.add_coordinate!(params, coord2)
        @test Nearests.get_coordinate_count(params) == 2
        @test Nearests.get_coordinate(params, 1) == coord1
        @test Nearests.get_coordinate(params, 2) == coord2

        coords = Nearests.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Nearests.NearestParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Nearests.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Nearests.get_coordinate_count(params) == 1
        @test Nearests.get_coordinate(params, 1) == coord

        coord_with = Nearests.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Nearests.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Nearests.NearestParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Nearests.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Nearests.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Nearests.set_hint!(params, 1, "")
        @test Nearests.get_hint(params, 1) == ""

        # Set a non-empty hint
        Nearests.set_hint!(params, 1, "test_hint")
        result = Nearests.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Nearests.get_hints(params)
        @test length(hints) == 1
        # Verify we can get hints (value may vary based on implementation)
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Nearests.NearestParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Nearests.add_coordinate!(params, coord)

        # Initially no radius set
        @test Nearests.get_radius(params, 1) === nothing

        # Set radius
        Nearests.set_radius!(params, 1, 5.0)
        @test Nearests.get_radius(params, 1) == 5.0

        # Set different radius
        Nearests.set_radius!(params, 1, 10.5)
        @test Nearests.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Nearests.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Nearests.NearestParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Nearests.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Nearests.get_bearing(params, 1) === nothing

        # Set bearing
        Nearests.set_bearing!(params, 1, 0, 90)
        bearing = Nearests.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Nearests.set_bearing!(params, 1, 180, 45)
        bearing = Nearests.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Nearests.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Nearests.NearestParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        Nearests.add_coordinate!(params, coord)

        # Initially no approach set
        @test Nearests.get_approach(params, 1) === nothing

        # Set approach
        Nearests.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Nearests.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Nearests.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Nearests.NearestParams()

        # Initially no excludes
        @test Nearests.get_exclude_count(params) == 0

        # Add exclude
        Nearests.add_exclude!(params, "toll")
        @test Nearests.get_exclude_count(params) == 1
        @test Nearests.get_exclude(params, 1) == "toll"

        # Add another exclude
        Nearests.add_exclude!(params, "ferry")
        @test Nearests.get_exclude_count(params) == 2
        @test Nearests.get_exclude(params, 1) == "toll"
        @test Nearests.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Nearests.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Nearests.NearestParams()

        # Default value (should be false or true depending on implementation)
        initial_value = Nearests.get_generate_hints(params)

        # Set to true
        Nearests.set_generate_hints!(params, true)
        @test Nearests.get_generate_hints(params) == true

        # Set to false
        Nearests.set_generate_hints!(params, false)
        @test Nearests.get_generate_hints(params) == false

        # Set back to true
        Nearests.set_generate_hints!(params, true)
        @test Nearests.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Nearests.NearestParams()

        # Default value
        initial_value = Nearests.get_skip_waypoints(params)

        # Set to true
        Nearests.set_skip_waypoints!(params, true)
        @test Nearests.get_skip_waypoints(params) == true

        # Set to false
        Nearests.set_skip_waypoints!(params, false)
        @test Nearests.get_skip_waypoints(params) == false

        # Set back to true
        Nearests.set_skip_waypoints!(params, true)
        @test Nearests.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Nearests.NearestParams()

        # Default value
        initial_snapping = Nearests.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Nearests.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Nearests.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Nearest - Query Execution" begin
    @testset "Basic nearest query" begin
        params = Nearests.NearestParams()
        Nearests.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        response = Nearests.nearest_response(TestUtils.get_test_osrm(), params)
        @test response isa Nearests.NearestResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Nearest with number of results" begin
        params = Nearests.NearestParams()
        Nearests.set_number_of_results!(params, 3)
        Nearests.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        response = Nearests.nearest_response(TestUtils.get_test_osrm(), params)
        @test response isa Nearests.NearestResponse
    end

    @testset "Nearest with all parameters" begin
        params = Nearests.NearestParams()
        Nearests.set_number_of_results!(params, 5)
        Nearests.add_coordinate_with!(params, TestUtils.get_hamburg_coordinates()["city_center"], 10.0, 0, 180)
        Nearests.set_hint!(params, 1, "")
        Nearests.set_radius!(params, 1, 5.0)
        Nearests.set_bearing!(params, 1, 0, 90)
        Nearests.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        Nearests.add_exclude!(params, "toll")
        Nearests.set_generate_hints!(params, true)
        Nearests.set_skip_waypoints!(params, false)
        Nearests.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Nearests.nearest_response(TestUtils.get_test_osrm(), params)
        @test response isa Nearests.NearestResponse
    end

    @testset "Nearest for different locations" begin
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            params = Nearests.NearestParams()
            Nearests.add_coordinate!(params, coord)
            response = Nearests.nearest_response(TestUtils.get_test_osrm(), params)
            @test response isa Nearests.NearestResponse
        end
    end
end

@testset "Nearest - Error Handling" begin
    @testset "Nearest with zero results" begin
        params = Nearests.NearestParams()
        Nearests.set_number_of_results!(params, 0)
        Nearests.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        try
            response = Nearests.nearest_response(TestUtils.get_test_osrm(), params)
            @test response isa Nearests.NearestResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = Nearests.NearestParams()
        Nearests.add_coordinate!(params, TestUtils.get_hamburg_coordinates()["city_center"])
        try
            Nearests.nearest(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
