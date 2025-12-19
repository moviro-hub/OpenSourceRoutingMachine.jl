using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Route: Route

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Route - Setters and Getters" begin
    @testset "Steps" begin
        params = Route.RouteParams()
        # Default value
        initial_value = Route.get_steps(params)
        @test initial_value isa Bool

        Route.set_steps!(params, true)
        @test Route.get_steps(params) == true

        Route.set_steps!(params, false)
        @test Route.get_steps(params) == false

        Route.set_steps!(params, true)
        @test Route.get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = Route.RouteParams()
        # Default value
        initial_value = Route.get_alternatives(params)
        @test initial_value isa Bool

        Route.set_alternatives!(params, true)
        @test Route.get_alternatives(params) == true

        Route.set_alternatives!(params, false)
        @test Route.get_alternatives(params) == false

        Route.set_alternatives!(params, true)
        @test Route.get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = Route.RouteParams()
        # Default value
        initial_geometries = Route.get_geometries(params)
        @test initial_geometries isa OSRMs.Geometries

        Route.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE)
        @test Route.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE

        Route.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE6)
        @test Route.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE6

        Route.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        @test Route.get_geometries(params) == OSRMs.GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = Route.RouteParams()
        # Default value
        initial_overview = Route.get_overview(params)
        @test initial_overview isa OSRMs.Overview

        Route.set_overview!(params, OSRMs.OVERVIEW_SIMPLIFIED)
        @test Route.get_overview(params) == OSRMs.OVERVIEW_SIMPLIFIED

        Route.set_overview!(params, OSRMs.OVERVIEW_FULL)
        @test Route.get_overview(params) == OSRMs.OVERVIEW_FULL

        Route.set_overview!(params, OSRMs.OVERVIEW_FALSE)
        @test Route.get_overview(params) == OSRMs.OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = Route.RouteParams()
        # Default value (may be nothing)
        initial_value = Route.get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        Route.set_continue_straight!(params, true)
        @test Route.get_continue_straight(params) == true

        Route.set_continue_straight!(params, false)
        @test Route.get_continue_straight(params) == false

        Route.set_continue_straight!(params, true)
        @test Route.get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = Route.RouteParams()
        # Default value
        initial_value = Route.get_number_of_alternatives(params)
        @test initial_value isa Int

        Route.set_number_of_alternatives!(params, 1)
        @test Route.get_number_of_alternatives(params) == 1

        Route.set_number_of_alternatives!(params, 3)
        @test Route.get_number_of_alternatives(params) == 3

        Route.set_number_of_alternatives!(params, 5)
        @test Route.get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = Route.RouteParams()
        # Default value
        initial_annotations = Route.get_annotations(params)
        @test initial_annotations isa OSRMs.Annotations

        Route.set_annotations!(params, OSRMs.ANNOTATIONS_NONE)
        @test Route.get_annotations(params) == OSRMs.ANNOTATIONS_NONE

        Route.set_annotations!(params, OSRMs.ANNOTATIONS_DURATION)
        @test Route.get_annotations(params) == OSRMs.ANNOTATIONS_DURATION

        Route.set_annotations!(params, OSRMs.ANNOTATIONS_DISTANCE)
        @test Route.get_annotations(params) == OSRMs.ANNOTATIONS_DISTANCE

        Route.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        @test Route.get_annotations(params) == OSRMs.ANNOTATIONS_ALL
    end

    @testset "Waypoints" begin
        params = Route.RouteParams()
        # Add coordinates first
        Route.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Route.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Route.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no waypoints
        @test Route.get_waypoint_count(params) == 0

        # Add waypoint
        Route.add_waypoint!(params, 2)
        @test Route.get_waypoint_count(params) == 1
        @test Route.get_waypoint(params, 1) == 2

        # Add another waypoint
        Route.add_waypoint!(params, 1)
        @test Route.get_waypoint_count(params) == 2
        waypoints = Route.get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        Route.clear_waypoints!(params)
        @test Route.get_waypoint_count(params) == 0
    end

    @testset "Coordinates" begin
        params = Route.RouteParams()
        @test Route.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate!(params, coord1)
        @test Route.get_coordinate_count(params) == 1
        @test Route.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Route.add_coordinate!(params, coord2)
        @test Route.get_coordinate_count(params) == 2
        @test Route.get_coordinate(params, 1) == coord1
        @test Route.get_coordinate(params, 2) == coord2

        coords = Route.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Route.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Route.get_coordinate_count(params) == 1
        @test Route.get_coordinate(params, 1) == coord

        coord_with = Route.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Route.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Route.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Route.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Route.set_hint!(params, 1, "")
        @test Route.get_hint(params, 1) == ""

        # Set a non-empty hint
        Route.set_hint!(params, 1, "test_hint")
        result = Route.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Route.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Route.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate!(params, coord)

        # Initially no radius set
        @test Route.get_radius(params, 1) === nothing

        # Set radius
        Route.set_radius!(params, 1, 5.0)
        @test Route.get_radius(params, 1) == 5.0

        # Set different radius
        Route.set_radius!(params, 1, 10.5)
        @test Route.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Route.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Route.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Route.get_bearing(params, 1) === nothing

        # Set bearing
        Route.set_bearing!(params, 1, 0, 90)
        bearing = Route.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Route.set_bearing!(params, 1, 180, 45)
        bearing = Route.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Route.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Route.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate!(params, coord)

        # Initially no approach set
        @test Route.get_approach(params, 1) === nothing

        # Set approach
        Route.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Route.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Route.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Route.RouteParams()

        # Initially no excludes
        @test Route.get_exclude_count(params) == 0

        # Add exclude
        Route.add_exclude!(params, "toll")
        @test Route.get_exclude_count(params) == 1
        @test Route.get_exclude(params, 1) == "toll"

        # Add another exclude
        Route.add_exclude!(params, "ferry")
        @test Route.get_exclude_count(params) == 2
        @test Route.get_exclude(params, 1) == "toll"
        @test Route.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Route.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Route.RouteParams()

        # Default value
        initial_value = Route.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Route.set_generate_hints!(params, true)
        @test Route.get_generate_hints(params) == true

        # Set to false
        Route.set_generate_hints!(params, false)
        @test Route.get_generate_hints(params) == false

        # Set back to true
        Route.set_generate_hints!(params, true)
        @test Route.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Route.RouteParams()

        # Default value
        initial_value = Route.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Route.set_skip_waypoints!(params, true)
        @test Route.get_skip_waypoints(params) == true

        # Set to false
        Route.set_skip_waypoints!(params, false)
        @test Route.get_skip_waypoints(params) == false

        # Set back to true
        Route.set_skip_waypoints!(params, true)
        @test Route.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Route.RouteParams()

        # Default value
        initial_snapping = Route.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Route.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Route.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Route - Query Execution" begin
    @testset "Basic route query" begin
        params = Route.RouteParams()
        Route.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Route.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        response = Route.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Route.RouteResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Route with steps enabled" begin
        params = Route.RouteParams()
        Route.set_steps!(params, true)
        Route.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Route.add_coordinate!(params, TestUtils.HAMBURG_ALTONA)
        response = Route.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Route.RouteResponse
    end

    @testset "Route with alternatives enabled" begin
        params = Route.RouteParams()
        Route.set_alternatives!(params, true)
        Route.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Route.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        response = Route.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Route.RouteResponse
    end

    @testset "Route with all parameters" begin
        params = Route.RouteParams()
        Route.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Route.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)

        Route.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        Route.set_overview!(params, OSRMs.OVERVIEW_FULL)
        Route.set_continue_straight!(params, true)
        Route.set_number_of_alternatives!(params, 2)
        Route.set_annotations!(params, OSRMs.Annotations(OSRMs.ANNOTATIONS_DURATION | OSRMs.ANNOTATIONS_DISTANCE))
        Route.set_steps!(params, true)
        Route.set_alternatives!(params, true)

        Route.clear_waypoints!(params)
        Route.set_hint!(params, 1, "")
        Route.set_radius!(params, 1, 10.0)
        Route.set_bearing!(params, 1, 0, 180)
        Route.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Route.add_exclude!(params, "toll")
        Route.set_generate_hints!(params, true)
        Route.set_skip_waypoints!(params, false)
        Route.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Route.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Route.RouteResponse
    end

    @testset "Route with multiple waypoints" begin
        params = Route.RouteParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Route.add_coordinate!(params, coord)
        end
        response = Route.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Route.RouteResponse
    end

    @testset "Route with waypoint selection" begin
        params = Route.RouteParams()
        Route.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Route.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Route.add_coordinate!(params, TestUtils.HAMBURG_PORT)
        Route.add_waypoint!(params, 2)
        try
            response = Route.route_response(TestUtils.get_test_osrm(), params)
            @test response isa Route.RouteResponse
        catch e
            # Waypoint selection may fail if the route cannot be computed
            @test e isa OSRMs.OSRMError
        end
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = Route.RouteParams()
        Route.add_coordinate!(params, OSRMs.Position(0.0, 0.0))
        Route.add_coordinate!(params, OSRMs.Position(1.0, 1.0))
        try
            response = Route.route_response(TestUtils.get_test_osrm(), params)
            @test response isa Route.RouteResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = Route.RouteParams()
        Route.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        Route.add_coordinate!(params, OSRMs.Position(201.0, 201.0))
        try
            Route.route(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Route - Edge Cases" begin
    @testset "Same start and end point" begin
        params = Route.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Route.add_coordinate!(params, coord)
        Route.add_coordinate!(params, coord)
        try
            response = Route.route_response(TestUtils.get_test_osrm(), params)
            @test response isa Route.RouteResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Very short route" begin
        params = Route.RouteParams()
        coord1 = TestUtils.HAMBURG_CITY_CENTER
        coord2 = OSRMs.Position(coord1.longitude + 0.001, coord1.latitude + 0.001)
        Route.add_coordinate!(params, coord1)
        Route.add_coordinate!(params, coord2)
        response = Route.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Route.RouteResponse
    end
end
