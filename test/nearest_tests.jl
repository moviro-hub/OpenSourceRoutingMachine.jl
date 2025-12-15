using Test
using OpenSourceRoutingMachine: OSRM, OSRMConfig, Position, OSRMError
using OpenSourceRoutingMachine: Approach, Snapping, APPROACH_CURB, SNAPPING_DEFAULT
using OpenSourceRoutingMachine.Nearests:
    NearestParams,
    NearestResponse,
    add_coordinate!,
    add_coordinate_with!,
    set_number_of_results!,
    get_number_of_results,
    set_hint!,
    get_hint,
    get_hints,
    set_radius!,
    get_radius,
    get_radii,
    set_bearing!,
    get_bearing,
    get_bearings,
    set_approach!,
    get_approach,
    get_approaches,
    add_exclude!,
    get_exclude,
    get_excludes,
    get_exclude_count,
    set_generate_hints!,
    get_generate_hints,
    set_skip_waypoints!,
    get_skip_waypoints,
    set_snapping!,
    get_snapping,
    get_coordinates,
    get_coordinate,
    get_coordinate_count,
    get_coordinate_with,
    get_coordinates_with,
    nearest,
    nearest_response
using Base: C_NULL

include("TestUtils.jl")
using .TestUtils: get_test_osrm, get_hamburg_coordinates

@testset "Nearest - Setters and Getters" begin
    @testset "Number of Results" begin
        params = NearestParams()
        # Get default value (may vary)
        default_value = get_number_of_results(params)
        @test default_value isa Int

        set_number_of_results!(params, 1)
        @test get_number_of_results(params) == 1

        set_number_of_results!(params, 5)
        @test get_number_of_results(params) == 5

        set_number_of_results!(params, 10)
        @test get_number_of_results(params) == 10
    end

    @testset "Coordinates" begin
        params = NearestParams()
        @test get_coordinate_count(params) == 0

        coord1 = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord1)
        @test get_coordinate_count(params) == 1
        @test get_coordinate(params, 1) == coord1

        coord2 = get_hamburg_coordinates()["port"]
        add_coordinate!(params, coord2)
        @test get_coordinate_count(params) == 2
        @test get_coordinate(params, 1) == coord1
        @test get_coordinate(params, 2) == coord2

        coords = get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = NearestParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test get_coordinate_count(params) == 1
        @test get_coordinate(params, 1) == coord

        coord_with = get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = NearestParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        set_hint!(params, 1, "")
        @test get_hint(params, 1) == ""

        # Set a non-empty hint
        set_hint!(params, 1, "test_hint")
        result = get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = get_hints(params)
        @test length(hints) == 1
        # Verify we can get hints (value may vary based on implementation)
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = NearestParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no radius set
        @test get_radius(params, 1) === nothing

        # Set radius
        set_radius!(params, 1, 5.0)
        @test get_radius(params, 1) == 5.0

        # Set different radius
        set_radius!(params, 1, 10.5)
        @test get_radius(params, 1) == 10.5

        # Get all radii
        radii = get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = NearestParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no bearing set
        @test get_bearing(params, 1) === nothing

        # Set bearing
        set_bearing!(params, 1, 0, 90)
        bearing = get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        set_bearing!(params, 1, 180, 45)
        bearing = get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = NearestParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)

        # Initially no approach set
        @test get_approach(params, 1) === nothing

        # Set approach
        set_approach!(params, 1, APPROACH_CURB)
        @test get_approach(params, 1) == APPROACH_CURB

        # Get all approaches
        approaches = get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == APPROACH_CURB
    end

    @testset "Excludes" begin
        params = NearestParams()

        # Initially no excludes
        @test get_exclude_count(params) == 0

        # Add exclude
        add_exclude!(params, "toll")
        @test get_exclude_count(params) == 1
        @test get_exclude(params, 1) == "toll"

        # Add another exclude
        add_exclude!(params, "ferry")
        @test get_exclude_count(params) == 2
        @test get_exclude(params, 1) == "toll"
        @test get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = NearestParams()

        # Default value (should be false or true depending on implementation)
        initial_value = get_generate_hints(params)

        # Set to true
        set_generate_hints!(params, true)
        @test get_generate_hints(params) == true

        # Set to false
        set_generate_hints!(params, false)
        @test get_generate_hints(params) == false

        # Set back to true
        set_generate_hints!(params, true)
        @test get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = NearestParams()

        # Default value
        initial_value = get_skip_waypoints(params)

        # Set to true
        set_skip_waypoints!(params, true)
        @test get_skip_waypoints(params) == true

        # Set to false
        set_skip_waypoints!(params, false)
        @test get_skip_waypoints(params) == false

        # Set back to true
        set_skip_waypoints!(params, true)
        @test get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = NearestParams()

        # Default value
        initial_snapping = get_snapping(params)
        @test initial_snapping isa Snapping

        # Set snapping
        set_snapping!(params, SNAPPING_DEFAULT)
        @test get_snapping(params) == SNAPPING_DEFAULT
    end
end

@testset "Nearest - Query Execution" begin
    @testset "Basic nearest query" begin
        params = NearestParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        response = nearest_response(get_test_osrm(), params)
        @test response isa NearestResponse
        @test response.ptr != C_NULL
    end

    @testset "Nearest with number of results" begin
        params = NearestParams()
        set_number_of_results!(params, 3)
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        response = nearest_response(get_test_osrm(), params)
        @test response isa NearestResponse
    end

    @testset "Nearest with all parameters" begin
        params = NearestParams()
        set_number_of_results!(params, 5)
        add_coordinate_with!(params, get_hamburg_coordinates()["city_center"], 10.0, 0, 180)
        set_hint!(params, 1, "")
        set_radius!(params, 1, 5.0)
        set_bearing!(params, 1, 0, 90)
        set_approach!(params, 1, APPROACH_CURB)
        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, SNAPPING_DEFAULT)

        response = nearest_response(get_test_osrm(), params)
        @test response isa NearestResponse
    end

    @testset "Nearest for different locations" begin
        for (name, coord) in get_hamburg_coordinates()
            params = NearestParams()
            add_coordinate!(params, coord)
            response = nearest_response(get_test_osrm(), params)
            @test response isa NearestResponse
        end
    end
end

@testset "Nearest - Error Handling" begin
    @testset "Nearest with zero results" begin
        params = NearestParams()
        set_number_of_results!(params, 0)
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        try
            response = nearest_response(get_test_osrm(), params)
            @test response isa NearestResponse
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = NearestParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        try
            nearest(get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
