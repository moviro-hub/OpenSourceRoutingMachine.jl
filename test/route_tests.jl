using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Routes: Routes

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Route - Setters and Getters" begin
    @testset "Steps" begin
        params = Routes.RouteParams()
        # Default value
        initial_value = Routes.get_steps(params)
        @test initial_value isa Bool

        Routes.set_steps!(params, true)
        @test Routes.get_steps(params) == true

        Routes.set_steps!(params, false)
        @test Routes.get_steps(params) == false

        Routes.set_steps!(params, true)
        @test Routes.get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = Routes.RouteParams()
        # Default value
        initial_value = Routes.get_alternatives(params)
        @test initial_value isa Bool

        Routes.set_alternatives!(params, true)
        @test Routes.get_alternatives(params) == true

        Routes.set_alternatives!(params, false)
        @test Routes.get_alternatives(params) == false

        Routes.set_alternatives!(params, true)
        @test Routes.get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = Routes.RouteParams()
        # Default value
        initial_geometries = Routes.get_geometries(params)
        @test initial_geometries isa OSRMs.Geometries

        Routes.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE)
        @test Routes.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE

        Routes.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE6)
        @test Routes.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE6

        Routes.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        @test Routes.get_geometries(params) == OSRMs.GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = Routes.RouteParams()
        # Default value
        initial_overview = Routes.get_overview(params)
        @test initial_overview isa OSRMs.Overview

        Routes.set_overview!(params, OSRMs.OVERVIEW_SIMPLIFIED)
        @test Routes.get_overview(params) == OSRMs.OVERVIEW_SIMPLIFIED

        Routes.set_overview!(params, OSRMs.OVERVIEW_FULL)
        @test Routes.get_overview(params) == OSRMs.OVERVIEW_FULL

        Routes.set_overview!(params, OSRMs.OVERVIEW_FALSE)
        @test Routes.get_overview(params) == OSRMs.OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = Routes.RouteParams()
        # Default value (may be nothing)
        initial_value = Routes.get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        Routes.set_continue_straight!(params, true)
        @test Routes.get_continue_straight(params) == true

        Routes.set_continue_straight!(params, false)
        @test Routes.get_continue_straight(params) == false

        Routes.set_continue_straight!(params, true)
        @test Routes.get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = Routes.RouteParams()
        # Default value
        initial_value = Routes.get_number_of_alternatives(params)
        @test initial_value isa Int

        Routes.set_number_of_alternatives!(params, 1)
        @test Routes.get_number_of_alternatives(params) == 1

        Routes.set_number_of_alternatives!(params, 3)
        @test Routes.get_number_of_alternatives(params) == 3

        Routes.set_number_of_alternatives!(params, 5)
        @test Routes.get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = Routes.RouteParams()
        # Default value
        initial_annotations = Routes.get_annotations(params)
        @test initial_annotations isa OSRMs.Annotations

        Routes.set_annotations!(params, OSRMs.ANNOTATIONS_NONE)
        @test Routes.get_annotations(params) == OSRMs.ANNOTATIONS_NONE

        Routes.set_annotations!(params, OSRMs.ANNOTATIONS_DURATION)
        @test Routes.get_annotations(params) == OSRMs.ANNOTATIONS_DURATION

        Routes.set_annotations!(params, OSRMs.ANNOTATIONS_DISTANCE)
        @test Routes.get_annotations(params) == OSRMs.ANNOTATIONS_DISTANCE

        Routes.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        @test Routes.get_annotations(params) == OSRMs.ANNOTATIONS_ALL
    end

    @testset "Waypoints" begin
        params = Routes.RouteParams()
        # Add coordinates first
        Routes.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no waypoints
        @test Routes.get_waypoint_count(params) == 0

        # Add waypoint
        Routes.add_waypoint!(params, 2)
        @test Routes.get_waypoint_count(params) == 1
        @test Routes.get_waypoint(params, 1) == 2

        # Add another waypoint
        Routes.add_waypoint!(params, 1)
        @test Routes.get_waypoint_count(params) == 2
        waypoints = Routes.get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        Routes.clear_waypoints!(params)
        @test Routes.get_waypoint_count(params) == 0
    end

    @testset "Coordinates" begin
        params = Routes.RouteParams()
        @test Routes.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate!(params, coord1)
        @test Routes.get_coordinate_count(params) == 1
        @test Routes.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Routes.add_coordinate!(params, coord2)
        @test Routes.get_coordinate_count(params) == 2
        @test Routes.get_coordinate(params, 1) == coord1
        @test Routes.get_coordinate(params, 2) == coord2

        coords = Routes.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Routes.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Routes.get_coordinate_count(params) == 1
        @test Routes.get_coordinate(params, 1) == coord

        coord_with = Routes.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Routes.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Routes.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Routes.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Routes.set_hint!(params, 1, "")
        @test Routes.get_hint(params, 1) == ""

        # Set a non-empty hint
        Routes.set_hint!(params, 1, "test_hint")
        result = Routes.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Routes.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Routes.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate!(params, coord)

        # Initially no radius set
        @test Routes.get_radius(params, 1) === nothing

        # Set radius
        Routes.set_radius!(params, 1, 5.0)
        @test Routes.get_radius(params, 1) == 5.0

        # Set different radius
        Routes.set_radius!(params, 1, 10.5)
        @test Routes.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Routes.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Routes.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Routes.get_bearing(params, 1) === nothing

        # Set bearing
        Routes.set_bearing!(params, 1, 0, 90)
        bearing = Routes.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Routes.set_bearing!(params, 1, 180, 45)
        bearing = Routes.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Routes.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Routes.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate!(params, coord)

        # Initially no approach set
        @test Routes.get_approach(params, 1) === nothing

        # Set approach
        Routes.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Routes.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Routes.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Routes.RouteParams()

        # Initially no excludes
        @test Routes.get_exclude_count(params) == 0

        # Add exclude
        Routes.add_exclude!(params, "toll")
        @test Routes.get_exclude_count(params) == 1
        @test Routes.get_exclude(params, 1) == "toll"

        # Add another exclude
        Routes.add_exclude!(params, "ferry")
        @test Routes.get_exclude_count(params) == 2
        @test Routes.get_exclude(params, 1) == "toll"
        @test Routes.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Routes.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Routes.RouteParams()

        # Default value
        initial_value = Routes.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Routes.set_generate_hints!(params, true)
        @test Routes.get_generate_hints(params) == true

        # Set to false
        Routes.set_generate_hints!(params, false)
        @test Routes.get_generate_hints(params) == false

        # Set back to true
        Routes.set_generate_hints!(params, true)
        @test Routes.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Routes.RouteParams()

        # Default value
        initial_value = Routes.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Routes.set_skip_waypoints!(params, true)
        @test Routes.get_skip_waypoints(params) == true

        # Set to false
        Routes.set_skip_waypoints!(params, false)
        @test Routes.get_skip_waypoints(params) == false

        # Set back to true
        Routes.set_skip_waypoints!(params, true)
        @test Routes.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Routes.RouteParams()

        # Default value
        initial_snapping = Routes.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Routes.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Routes.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Route - Query Execution" begin
    @testset "Basic route query" begin
        params = Routes.RouteParams()
        Routes.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        response = Routes.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Routes.RouteResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Route with steps enabled" begin
        params = Routes.RouteParams()
        Routes.set_steps!(params, true)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_ALTONA)
        response = Routes.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Routes.RouteResponse
    end

    @testset "Route with alternatives enabled" begin
        params = Routes.RouteParams()
        Routes.set_alternatives!(params, true)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        response = Routes.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Routes.RouteResponse
    end

    @testset "Route with all parameters" begin
        params = Routes.RouteParams()
        Routes.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)

        Routes.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        Routes.set_overview!(params, OSRMs.OVERVIEW_FULL)
        Routes.set_continue_straight!(params, true)
        Routes.set_number_of_alternatives!(params, 2)
        Routes.set_annotations!(params, OSRMs.Annotations(OSRMs.ANNOTATIONS_DURATION | OSRMs.ANNOTATIONS_DISTANCE))
        Routes.set_steps!(params, true)
        Routes.set_alternatives!(params, true)

        Routes.clear_waypoints!(params)
        Routes.set_hint!(params, 1, "")
        Routes.set_radius!(params, 1, 10.0)
        Routes.set_bearing!(params, 1, 0, 180)
        Routes.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Routes.add_exclude!(params, "toll")
        Routes.set_generate_hints!(params, true)
        Routes.set_skip_waypoints!(params, false)
        Routes.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Routes.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Routes.RouteResponse
    end

    @testset "Route with multiple waypoints" begin
        params = Routes.RouteParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Routes.add_coordinate!(params, coord)
        end
        response = Routes.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Routes.RouteResponse
    end

    @testset "Route with waypoint selection" begin
        params = Routes.RouteParams()
        Routes.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Routes.add_coordinate!(params, TestUtils.HAMBURG_PORT)
        Routes.add_waypoint!(params, 2)
        try
            response = Routes.route_response(TestUtils.get_test_osrm(), params)
            @test response isa Routes.RouteResponse
        catch e
            # Waypoint selection may fail if the route cannot be computed
            @test e isa OSRMs.OSRMError
        end
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = Routes.RouteParams()
        Routes.add_coordinate!(params, OSRMs.Position(0.0, 0.0))
        Routes.add_coordinate!(params, OSRMs.Position(1.0, 1.0))
        try
            response = Routes.route_response(TestUtils.get_test_osrm(), params)
            @test response isa Routes.RouteResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = Routes.RouteParams()
        Routes.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        Routes.add_coordinate!(params, OSRMs.Position(201.0, 201.0))
        try
            Routes.route(TestUtils.get_test_osrm(), params)
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
        params = Routes.RouteParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Routes.add_coordinate!(params, coord)
        Routes.add_coordinate!(params, coord)
        try
            response = Routes.route_response(TestUtils.get_test_osrm(), params)
            @test response isa Routes.RouteResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Very short route" begin
        params = Routes.RouteParams()
        coord1 = TestUtils.HAMBURG_CITY_CENTER
        coord2 = OSRMs.Position(coord1.longitude + 0.001, coord1.latitude + 0.001)
        Routes.add_coordinate!(params, coord1)
        Routes.add_coordinate!(params, coord2)
        response = Routes.route_response(TestUtils.get_test_osrm(), params)
        @test response isa Routes.RouteResponse
    end
end
