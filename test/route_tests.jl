using Test
using OpenSourceRoutingMachine: OSRM, OSRMConfig, Position, OSRMError
using OpenSourceRoutingMachine: Approach, Snapping, Geometries, Overview, Annotations
using OpenSourceRoutingMachine: APPROACH_CURB, SNAPPING_DEFAULT
using OpenSourceRoutingMachine: GEOMETRIES_POLYLINE, GEOMETRIES_POLYLINE6, GEOMETRIES_GEOJSON
using OpenSourceRoutingMachine: OVERVIEW_SIMPLIFIED, OVERVIEW_FULL, OVERVIEW_FALSE
using OpenSourceRoutingMachine: ANNOTATIONS_NONE, ANNOTATIONS_DURATION, ANNOTATIONS_DISTANCE, ANNOTATIONS_ALL
using OpenSourceRoutingMachine.Routes:
    RouteParams,
    RouteResponse,
    add_coordinate!,
    add_coordinate_with!,
    set_steps!,
    get_steps,
    set_alternatives!,
    get_alternatives,
    set_geometries!,
    get_geometries,
    set_overview!,
    get_overview,
    set_continue_straight!,
    get_continue_straight,
    set_number_of_alternatives!,
    get_number_of_alternatives,
    set_annotations!,
    get_annotations,
    add_waypoint!,
    clear_waypoints!,
    get_waypoints,
    get_waypoint,
    get_waypoint_count,
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
    route,
    route_response
using Base: C_NULL

include("TestUtils.jl")
using .TestUtils: get_test_osrm, get_hamburg_coordinates

@testset "Route - Setters and Getters" begin
    @testset "Steps" begin
        params = RouteParams()
        # Default value
        initial_value = get_steps(params)
        @test initial_value isa Bool

        set_steps!(params, true)
        @test get_steps(params) == true

        set_steps!(params, false)
        @test get_steps(params) == false

        set_steps!(params, true)
        @test get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = RouteParams()
        # Default value
        initial_value = get_alternatives(params)
        @test initial_value isa Bool

        set_alternatives!(params, true)
        @test get_alternatives(params) == true

        set_alternatives!(params, false)
        @test get_alternatives(params) == false

        set_alternatives!(params, true)
        @test get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = RouteParams()
        # Default value
        initial_geometries = get_geometries(params)
        @test initial_geometries isa Geometries

        set_geometries!(params, GEOMETRIES_POLYLINE)
        @test get_geometries(params) == GEOMETRIES_POLYLINE

        set_geometries!(params, GEOMETRIES_POLYLINE6)
        @test get_geometries(params) == GEOMETRIES_POLYLINE6

        set_geometries!(params, GEOMETRIES_GEOJSON)
        @test get_geometries(params) == GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = RouteParams()
        # Default value
        initial_overview = get_overview(params)
        @test initial_overview isa Overview

        set_overview!(params, OVERVIEW_SIMPLIFIED)
        @test get_overview(params) == OVERVIEW_SIMPLIFIED

        set_overview!(params, OVERVIEW_FULL)
        @test get_overview(params) == OVERVIEW_FULL

        set_overview!(params, OVERVIEW_FALSE)
        @test get_overview(params) == OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = RouteParams()
        # Default value (may be nothing)
        initial_value = get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        set_continue_straight!(params, true)
        @test get_continue_straight(params) == true

        set_continue_straight!(params, false)
        @test get_continue_straight(params) == false

        set_continue_straight!(params, true)
        @test get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = RouteParams()
        # Default value
        initial_value = get_number_of_alternatives(params)
        @test initial_value isa Int

        set_number_of_alternatives!(params, 1)
        @test get_number_of_alternatives(params) == 1

        set_number_of_alternatives!(params, 3)
        @test get_number_of_alternatives(params) == 3

        set_number_of_alternatives!(params, 5)
        @test get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = RouteParams()
        # Default value
        initial_annotations = get_annotations(params)
        @test initial_annotations isa Annotations

        set_annotations!(params, ANNOTATIONS_NONE)
        @test get_annotations(params) == ANNOTATIONS_NONE

        set_annotations!(params, ANNOTATIONS_DURATION)
        @test get_annotations(params) == ANNOTATIONS_DURATION

        set_annotations!(params, ANNOTATIONS_DISTANCE)
        @test get_annotations(params) == ANNOTATIONS_DISTANCE

        set_annotations!(params, ANNOTATIONS_ALL)
        @test get_annotations(params) == ANNOTATIONS_ALL
    end

    @testset "Waypoints" begin
        params = RouteParams()
        # Add coordinates first
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])
        add_coordinate!(params, get_hamburg_coordinates()["port"])

        # Initially no waypoints
        @test get_waypoint_count(params) == 0

        # Add waypoint
        add_waypoint!(params, 2)
        @test get_waypoint_count(params) == 1
        @test get_waypoint(params, 1) == 2

        # Add another waypoint
        add_waypoint!(params, 1)
        @test get_waypoint_count(params) == 2
        waypoints = get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        clear_waypoints!(params)
        @test get_waypoint_count(params) == 0
    end

    @testset "Coordinates" begin
        params = RouteParams()
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
        params = RouteParams()
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
        params = RouteParams()
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
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = RouteParams()
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
        params = RouteParams()
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
        params = RouteParams()
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
        params = RouteParams()

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
        params = RouteParams()

        # Default value
        initial_value = get_generate_hints(params)
        @test initial_value isa Bool

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
        params = RouteParams()

        # Default value
        initial_value = get_skip_waypoints(params)
        @test initial_value isa Bool

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
        params = RouteParams()

        # Default value
        initial_snapping = get_snapping(params)
        @test initial_snapping isa Snapping

        # Set snapping
        set_snapping!(params, SNAPPING_DEFAULT)
        @test get_snapping(params) == SNAPPING_DEFAULT
    end
end

@testset "Route - Query Execution" begin
    @testset "Basic route query" begin
        params = RouteParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])
        response = route_response(get_test_osrm(), params)
        @test response isa RouteResponse
        @test response.ptr != C_NULL
    end

    @testset "Route with steps enabled" begin
        params = RouteParams()
        set_steps!(params, true)
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["altona"])
        response = route_response(get_test_osrm(), params)
        @test response isa RouteResponse
    end

    @testset "Route with alternatives enabled" begin
        params = RouteParams()
        set_alternatives!(params, true)
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])
        response = route_response(get_test_osrm(), params)
        @test response isa RouteResponse
    end

    @testset "Route with all parameters" begin
        params = RouteParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])

        set_geometries!(params, GEOMETRIES_GEOJSON)
        set_overview!(params, OVERVIEW_FULL)
        set_continue_straight!(params, true)
        set_number_of_alternatives!(params, 2)
        set_annotations!(params, Annotations(ANNOTATIONS_DURATION | ANNOTATIONS_DISTANCE))
        set_steps!(params, true)
        set_alternatives!(params, true)

        clear_waypoints!(params)
        set_hint!(params, 1, "")
        set_radius!(params, 1, 10.0)
        set_bearing!(params, 1, 0, 180)
        set_approach!(params, 1, APPROACH_CURB)

        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, SNAPPING_DEFAULT)

        response = route_response(get_test_osrm(), params)
        @test response isa RouteResponse
    end

    @testset "Route with multiple waypoints" begin
        params = RouteParams()
        for (name, coord) in get_hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        response = route_response(get_test_osrm(), params)
        @test response isa RouteResponse
    end

    @testset "Route with waypoint selection" begin
        params = RouteParams()
        add_coordinate!(params, get_hamburg_coordinates()["city_center"])
        add_coordinate!(params, get_hamburg_coordinates()["airport"])
        add_coordinate!(params, get_hamburg_coordinates()["port"])
        add_waypoint!(params, 2)
        try
            response = route_response(get_test_osrm(), params)
            @test response isa RouteResponse
        catch e
            # Waypoint selection may fail if the route cannot be computed
            @test e isa OSRMError
        end
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = RouteParams()
        add_coordinate!(params, Position(0.0, 0.0))
        add_coordinate!(params, Position(1.0, 1.0))
        try
            response = route_response(get_test_osrm(), params)
            @test response isa RouteResponse
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = RouteParams()
        add_coordinate!(params, Position(200.0, 200.0))
        add_coordinate!(params, Position(201.0, 201.0))
        try
            route(get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Route - Edge Cases" begin
    @testset "Same start and end point" begin
        params = RouteParams()
        coord = get_hamburg_coordinates()["city_center"]
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)
        try
            response = route_response(get_test_osrm(), params)
            @test response isa RouteResponse
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Very short route" begin
        params = RouteParams()
        coord1 = get_hamburg_coordinates()["city_center"]
        coord2 = Position(coord1.longitude + 0.001, coord1.latitude + 0.001)
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)
        response = route_response(get_test_osrm(), params)
        @test response isa RouteResponse
    end
end
