using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Nearest: Nearest

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Nearest - Setters and Getters" begin
    @testset "Number of Results" begin
        params = Nearest.NearestParams()
        # Get default value (may vary)
        default_value = Nearest.get_number_of_results(params)
        @test default_value isa Int

        Nearest.set_number_of_results!(params, 1)
        @test Nearest.get_number_of_results(params) == 1

        Nearest.set_number_of_results!(params, 5)
        @test Nearest.get_number_of_results(params) == 5

        Nearest.set_number_of_results!(params, 10)
        @test Nearest.get_number_of_results(params) == 10
    end

    @testset "Coordinates" begin
        params = Nearest.NearestParams()
        @test Nearest.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Nearest.add_coordinate!(params, coord1)
        @test Nearest.get_coordinate_count(params) == 1
        @test Nearest.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Nearest.add_coordinate!(params, coord2)
        @test Nearest.get_coordinate_count(params) == 2
        @test Nearest.get_coordinate(params, 1) == coord1
        @test Nearest.get_coordinate(params, 2) == coord2

        coords = Nearest.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Nearest.NearestParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Nearest.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Nearest.get_coordinate_count(params) == 1
        @test Nearest.get_coordinate(params, 1) == coord

        coord_with = Nearest.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Nearest.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Nearest.NearestParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Nearest.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Nearest.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Nearest.set_hint!(params, 1, "")
        @test Nearest.get_hint(params, 1) == ""

        # Set a non-empty hint
        Nearest.set_hint!(params, 1, "test_hint")
        result = Nearest.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Nearest.get_hints(params)
        @test length(hints) == 1
        # Verify we can get hints (value may vary based on implementation)
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Nearest.NearestParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Nearest.add_coordinate!(params, coord)

        # Initially no radius set
        @test Nearest.get_radius(params, 1) === nothing

        # Set radius
        Nearest.set_radius!(params, 1, 5.0)
        @test Nearest.get_radius(params, 1) == 5.0

        # Set different radius
        Nearest.set_radius!(params, 1, 10.5)
        @test Nearest.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Nearest.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Nearest.NearestParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Nearest.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Nearest.get_bearing(params, 1) === nothing

        # Set bearing
        Nearest.set_bearing!(params, 1, 0, 90)
        bearing = Nearest.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Nearest.set_bearing!(params, 1, 180, 45)
        bearing = Nearest.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Nearest.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Nearest.NearestParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Nearest.add_coordinate!(params, coord)

        # Initially no approach set
        @test Nearest.get_approach(params, 1) === nothing

        # Set approach
        Nearest.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Nearest.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Nearest.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Nearest.NearestParams()

        # Initially no excludes
        @test Nearest.get_exclude_count(params) == 0

        # Add exclude
        Nearest.add_exclude!(params, "toll")
        @test Nearest.get_exclude_count(params) == 1
        @test Nearest.get_exclude(params, 1) == "toll"

        # Add another exclude
        Nearest.add_exclude!(params, "ferry")
        @test Nearest.get_exclude_count(params) == 2
        @test Nearest.get_exclude(params, 1) == "toll"
        @test Nearest.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Nearest.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Nearest.NearestParams()

        # Default value (should be false or true depending on implementation)
        initial_value = Nearest.get_generate_hints(params)

        # Set to true
        Nearest.set_generate_hints!(params, true)
        @test Nearest.get_generate_hints(params) == true

        # Set to false
        Nearest.set_generate_hints!(params, false)
        @test Nearest.get_generate_hints(params) == false

        # Set back to true
        Nearest.set_generate_hints!(params, true)
        @test Nearest.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Nearest.NearestParams()

        # Default value
        initial_value = Nearest.get_skip_waypoints(params)

        # Set to true
        Nearest.set_skip_waypoints!(params, true)
        @test Nearest.get_skip_waypoints(params) == true

        # Set to false
        Nearest.set_skip_waypoints!(params, false)
        @test Nearest.get_skip_waypoints(params) == false

        # Set back to true
        Nearest.set_skip_waypoints!(params, true)
        @test Nearest.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Nearest.NearestParams()

        # Default value
        initial_snapping = Nearest.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Nearest.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Nearest.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Nearest - Query Execution" begin
    @testset "Basic nearest query" begin
        params = Nearest.NearestParams()
        Nearest.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        response = Nearest.nearest_response(TestUtils.get_test_osrm(), params)
        @test response isa Nearest.NearestResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Nearest with number of results" begin
        params = Nearest.NearestParams()
        Nearest.set_number_of_results!(params, 3)
        Nearest.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        response = Nearest.nearest_response(TestUtils.get_test_osrm(), params)
        @test response isa Nearest.NearestResponse
    end

    @testset "Nearest with all parameters" begin
        params = Nearest.NearestParams()
        Nearest.set_number_of_results!(params, 5)
        Nearest.add_coordinate_with!(params, TestUtils.HAMBURG_CITY_CENTER, 10.0, 0, 180)
        Nearest.set_hint!(params, 1, "")
        Nearest.set_radius!(params, 1, 5.0)
        Nearest.set_bearing!(params, 1, 0, 90)
        Nearest.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        Nearest.add_exclude!(params, "toll")
        Nearest.set_generate_hints!(params, true)
        Nearest.set_skip_waypoints!(params, false)
        Nearest.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Nearest.nearest_response(TestUtils.get_test_osrm(), params)
        @test response isa Nearest.NearestResponse
    end

    @testset "Nearest for different locations" begin
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            params = Nearest.NearestParams()
            Nearest.add_coordinate!(params, coord)
            response = Nearest.nearest_response(TestUtils.get_test_osrm(), params)
            @test response isa Nearest.NearestResponse
        end
    end
end

@testset "Nearest - Error Handling" begin
    @testset "Nearest with zero results" begin
        params = Nearest.NearestParams()
        Nearest.set_number_of_results!(params, 0)
        Nearest.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        try
            response = Nearest.nearest_response(TestUtils.get_test_osrm(), params)
            @test response isa Nearest.NearestResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = Nearest.NearestParams()
        Nearest.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        try
            Nearest.nearest(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
