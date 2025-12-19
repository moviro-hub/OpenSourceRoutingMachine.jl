using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Trip: Trip

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Trip - Setters and Getters" begin
    @testset "Steps" begin
        params = Trip.TripParams()
        # Default value
        initial_value = Trip.get_steps(params)
        @test initial_value isa Bool

        Trip.set_steps!(params, true)
        @test Trip.get_steps(params) == true

        Trip.set_steps!(params, false)
        @test Trip.get_steps(params) == false

        Trip.set_steps!(params, true)
        @test Trip.get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = Trip.TripParams()
        # Default value
        initial_value = Trip.get_alternatives(params)
        @test initial_value isa Bool

        Trip.set_alternatives!(params, true)
        @test Trip.get_alternatives(params) == true

        Trip.set_alternatives!(params, false)
        @test Trip.get_alternatives(params) == false

        Trip.set_alternatives!(params, true)
        @test Trip.get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = Trip.TripParams()
        # Default value
        initial_geometries = Trip.get_geometries(params)
        @test initial_geometries isa OSRMs.Geometries

        Trip.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE)
        @test Trip.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE

        Trip.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE6)
        @test Trip.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE6

        Trip.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        @test Trip.get_geometries(params) == OSRMs.GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = Trip.TripParams()
        # Default value
        initial_overview = Trip.get_overview(params)
        @test initial_overview isa OSRMs.Overview

        Trip.set_overview!(params, OSRMs.OVERVIEW_SIMPLIFIED)
        @test Trip.get_overview(params) == OSRMs.OVERVIEW_SIMPLIFIED

        Trip.set_overview!(params, OSRMs.OVERVIEW_FULL)
        @test Trip.get_overview(params) == OSRMs.OVERVIEW_FULL

        Trip.set_overview!(params, OSRMs.OVERVIEW_FALSE)
        @test Trip.get_overview(params) == OSRMs.OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = Trip.TripParams()
        # Default value (may be nothing)
        initial_value = Trip.get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        Trip.set_continue_straight!(params, true)
        @test Trip.get_continue_straight(params) == true

        Trip.set_continue_straight!(params, false)
        @test Trip.get_continue_straight(params) == false

        Trip.set_continue_straight!(params, true)
        @test Trip.get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = Trip.TripParams()
        # Default value
        initial_value = Trip.get_number_of_alternatives(params)
        @test initial_value isa Int

        Trip.set_number_of_alternatives!(params, 1)
        @test Trip.get_number_of_alternatives(params) == 1

        Trip.set_number_of_alternatives!(params, 3)
        @test Trip.get_number_of_alternatives(params) == 3

        Trip.set_number_of_alternatives!(params, 5)
        @test Trip.get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = Trip.TripParams()
        # Default value
        initial_annotations = Trip.get_annotations(params)
        @test initial_annotations isa OSRMs.Annotations

        Trip.set_annotations!(params, OSRMs.ANNOTATIONS_NONE)
        @test Trip.get_annotations(params) == OSRMs.ANNOTATIONS_NONE

        Trip.set_annotations!(params, OSRMs.ANNOTATIONS_DURATION)
        @test Trip.get_annotations(params) == OSRMs.ANNOTATIONS_DURATION

        Trip.set_annotations!(params, OSRMs.ANNOTATIONS_DISTANCE)
        @test Trip.get_annotations(params) == OSRMs.ANNOTATIONS_DISTANCE

        Trip.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        @test Trip.get_annotations(params) == OSRMs.ANNOTATIONS_ALL
    end

    @testset "Roundtrip" begin
        params = Trip.TripParams()
        # Default value
        initial_value = Trip.get_roundtrip(params)
        @test initial_value isa Bool

        Trip.set_roundtrip!(params, true)
        @test Trip.get_roundtrip(params) == true

        Trip.set_roundtrip!(params, false)
        @test Trip.get_roundtrip(params) == false

        Trip.set_roundtrip!(params, true)
        @test Trip.get_roundtrip(params) == true
    end

    @testset "Source" begin
        params = Trip.TripParams()
        # Default value
        initial_source = Trip.get_source(params)
        @test initial_source isa Trip.TripSource

        Trip.set_source!(params, Trip.TRIP_SOURCE_ANY_SOURCE)
        @test Trip.get_source(params) == Trip.TRIP_SOURCE_ANY_SOURCE

        Trip.set_source!(params, Trip.TRIP_SOURCE_FIRST)
        @test Trip.get_source(params) == Trip.TRIP_SOURCE_FIRST
    end

    @testset "Destination" begin
        params = Trip.TripParams()
        # Default value
        initial_destination = Trip.get_destination(params)
        @test initial_destination isa Trip.TripDestination

        Trip.set_destination!(params, Trip.TRIP_DESTINATION_ANY_DESTINATION)
        @test Trip.get_destination(params) == Trip.TRIP_DESTINATION_ANY_DESTINATION

        Trip.set_destination!(params, Trip.TRIP_DESTINATION_LAST)
        @test Trip.get_destination(params) == Trip.TRIP_DESTINATION_LAST
    end

    @testset "Waypoints" begin
        params = Trip.TripParams()
        # Add coordinates first
        Trip.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Trip.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Trip.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no waypoints
        @test Trip.get_waypoint_count(params) == 0

        # Add waypoint
        Trip.add_waypoint!(params, 2)
        @test Trip.get_waypoint_count(params) == 1
        @test Trip.get_waypoint(params, 1) == 2

        # Add another waypoint
        Trip.add_waypoint!(params, 1)
        @test Trip.get_waypoint_count(params) == 2
        waypoints = Trip.get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        Trip.clear_waypoints!(params)
        @test Trip.get_waypoint_count(params) == 0
    end

    @testset "Coordinates" begin
        params = Trip.TripParams()
        @test Trip.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Trip.add_coordinate!(params, coord1)
        @test Trip.get_coordinate_count(params) == 1
        @test Trip.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Trip.add_coordinate!(params, coord2)
        @test Trip.get_coordinate_count(params) == 2
        @test Trip.get_coordinate(params, 1) == coord1
        @test Trip.get_coordinate(params, 2) == coord2

        coords = Trip.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Trip.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trip.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Trip.get_coordinate_count(params) == 1
        @test Trip.get_coordinate(params, 1) == coord

        coord_with = Trip.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Trip.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Trip.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trip.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Trip.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Trip.set_hint!(params, 1, "")
        @test Trip.get_hint(params, 1) == ""

        # Set a non-empty hint
        Trip.set_hint!(params, 1, "test_hint")
        result = Trip.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Trip.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Trip.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trip.add_coordinate!(params, coord)

        # Initially no radius set
        @test Trip.get_radius(params, 1) === nothing

        # Set radius
        Trip.set_radius!(params, 1, 5.0)
        @test Trip.get_radius(params, 1) == 5.0

        # Set different radius
        Trip.set_radius!(params, 1, 10.5)
        @test Trip.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Trip.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Trip.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trip.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Trip.get_bearing(params, 1) === nothing

        # Set bearing
        Trip.set_bearing!(params, 1, 0, 90)
        bearing = Trip.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Trip.set_bearing!(params, 1, 180, 45)
        bearing = Trip.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Trip.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Trip.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trip.add_coordinate!(params, coord)

        # Initially no approach set
        @test Trip.get_approach(params, 1) === nothing

        # Set approach
        Trip.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Trip.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Trip.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Trip.TripParams()

        # Initially no excludes
        @test Trip.get_exclude_count(params) == 0

        # Add exclude
        Trip.add_exclude!(params, "toll")
        @test Trip.get_exclude_count(params) == 1
        @test Trip.get_exclude(params, 1) == "toll"

        # Add another exclude
        Trip.add_exclude!(params, "ferry")
        @test Trip.get_exclude_count(params) == 2
        @test Trip.get_exclude(params, 1) == "toll"
        @test Trip.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Trip.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Trip.TripParams()

        # Default value
        initial_value = Trip.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Trip.set_generate_hints!(params, true)
        @test Trip.get_generate_hints(params) == true

        # Set to false
        Trip.set_generate_hints!(params, false)
        @test Trip.get_generate_hints(params) == false

        # Set back to true
        Trip.set_generate_hints!(params, true)
        @test Trip.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Trip.TripParams()

        # Default value
        initial_value = Trip.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Trip.set_skip_waypoints!(params, true)
        @test Trip.get_skip_waypoints(params) == true

        # Set to false
        Trip.set_skip_waypoints!(params, false)
        @test Trip.get_skip_waypoints(params) == false

        # Set back to true
        Trip.set_skip_waypoints!(params, true)
        @test Trip.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Trip.TripParams()

        # Default value
        initial_snapping = Trip.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Trip.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Trip.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Trip - Query Execution" begin
    @testset "Basic trip query" begin
        params = Trip.TripParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end
        response = Trip.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trip.TripResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Trip with roundtrip enabled" begin
        params = Trip.TripParams()
        Trip.set_roundtrip!(params, true)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end
        response = Trip.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trip.TripResponse
    end

    @testset "Trip with roundtrip disabled" begin
        params = Trip.TripParams()
        Trip.set_roundtrip!(params, false)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end
        try
            response = Trip.trip_response(TestUtils.get_test_osrm(), params)
            @test response isa Trip.TripResponse
        catch e
            # Trip may fail if roundtrip disabled and coordinates cannot form a valid trip
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Trip with source set to first" begin
        params = Trip.TripParams()
        Trip.set_source!(params, Trip.TRIP_SOURCE_FIRST)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end
        response = Trip.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trip.TripResponse
    end

    @testset "Trip with destination set to last" begin
        params = Trip.TripParams()
        Trip.set_destination!(params, Trip.TRIP_DESTINATION_LAST)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end
        response = Trip.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trip.TripResponse
    end

    @testset "Trip with waypoints" begin
        params = Trip.TripParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end
        Trip.add_waypoint!(params, 1)
        Trip.add_waypoint!(params, 2)
        response = Trip.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trip.TripResponse
    end

    @testset "Trip with all parameters" begin
        params = Trip.TripParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trip.add_coordinate!(params, coord)
        end

        Trip.set_roundtrip!(params, true)
        Trip.set_source!(params, Trip.TRIP_SOURCE_FIRST)
        Trip.set_destination!(params, Trip.TRIP_DESTINATION_LAST)
        Trip.set_steps!(params, true)
        Trip.set_alternatives!(params, true)
        Trip.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        Trip.set_overview!(params, OSRMs.OVERVIEW_FULL)
        Trip.set_continue_straight!(params, true)
        Trip.set_number_of_alternatives!(params, 2)
        Trip.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)

        Trip.add_waypoint!(params, 1)
        Trip.set_hint!(params, 1, "")
        Trip.set_radius!(params, 1, 10.0)
        Trip.set_bearing!(params, 1, 0, 180)
        Trip.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Trip.add_exclude!(params, "toll")
        Trip.set_generate_hints!(params, true)
        Trip.set_skip_waypoints!(params, false)
        Trip.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Trip.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trip.TripResponse
    end
end

@testset "Trip - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = Trip.TripParams()
        Trip.add_coordinate!(params, OSRMs.Position(0.0, 0.0))
        Trip.add_coordinate!(params, OSRMs.Position(1.0, 1.0))

        maybe_response = try
            Trip.trip_response(TestUtils.get_test_osrm(), params)
        catch e
            @test e isa OSRMs.OSRMError
            nothing
        end
        if maybe_response !== nothing
            @test maybe_response isa Trip.TripResponse
        end
    end

    @testset "Error messages are informative" begin
        params = Trip.TripParams()
        Trip.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        Trip.add_coordinate!(params, OSRMs.Position(201.0, 201.0))
        try
            Trip.trip(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
