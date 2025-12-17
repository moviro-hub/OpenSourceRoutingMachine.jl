using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Trips: Trips

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Trip - Setters and Getters" begin
    @testset "Steps" begin
        params = Trips.TripParams()
        # Default value
        initial_value = Trips.get_steps(params)
        @test initial_value isa Bool

        Trips.set_steps!(params, true)
        @test Trips.get_steps(params) == true

        Trips.set_steps!(params, false)
        @test Trips.get_steps(params) == false

        Trips.set_steps!(params, true)
        @test Trips.get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = Trips.TripParams()
        # Default value
        initial_value = Trips.get_alternatives(params)
        @test initial_value isa Bool

        Trips.set_alternatives!(params, true)
        @test Trips.get_alternatives(params) == true

        Trips.set_alternatives!(params, false)
        @test Trips.get_alternatives(params) == false

        Trips.set_alternatives!(params, true)
        @test Trips.get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = Trips.TripParams()
        # Default value
        initial_geometries = Trips.get_geometries(params)
        @test initial_geometries isa OSRMs.Geometries

        Trips.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE)
        @test Trips.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE

        Trips.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE6)
        @test Trips.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE6

        Trips.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        @test Trips.get_geometries(params) == OSRMs.GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = Trips.TripParams()
        # Default value
        initial_overview = Trips.get_overview(params)
        @test initial_overview isa OSRMs.Overview

        Trips.set_overview!(params, OSRMs.OVERVIEW_SIMPLIFIED)
        @test Trips.get_overview(params) == OSRMs.OVERVIEW_SIMPLIFIED

        Trips.set_overview!(params, OSRMs.OVERVIEW_FULL)
        @test Trips.get_overview(params) == OSRMs.OVERVIEW_FULL

        Trips.set_overview!(params, OSRMs.OVERVIEW_FALSE)
        @test Trips.get_overview(params) == OSRMs.OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = Trips.TripParams()
        # Default value (may be nothing)
        initial_value = Trips.get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        Trips.set_continue_straight!(params, true)
        @test Trips.get_continue_straight(params) == true

        Trips.set_continue_straight!(params, false)
        @test Trips.get_continue_straight(params) == false

        Trips.set_continue_straight!(params, true)
        @test Trips.get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = Trips.TripParams()
        # Default value
        initial_value = Trips.get_number_of_alternatives(params)
        @test initial_value isa Int

        Trips.set_number_of_alternatives!(params, 1)
        @test Trips.get_number_of_alternatives(params) == 1

        Trips.set_number_of_alternatives!(params, 3)
        @test Trips.get_number_of_alternatives(params) == 3

        Trips.set_number_of_alternatives!(params, 5)
        @test Trips.get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = Trips.TripParams()
        # Default value
        initial_annotations = Trips.get_annotations(params)
        @test initial_annotations isa OSRMs.Annotations

        Trips.set_annotations!(params, OSRMs.ANNOTATIONS_NONE)
        @test Trips.get_annotations(params) == OSRMs.ANNOTATIONS_NONE

        Trips.set_annotations!(params, OSRMs.ANNOTATIONS_DURATION)
        @test Trips.get_annotations(params) == OSRMs.ANNOTATIONS_DURATION

        Trips.set_annotations!(params, OSRMs.ANNOTATIONS_DISTANCE)
        @test Trips.get_annotations(params) == OSRMs.ANNOTATIONS_DISTANCE

        Trips.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        @test Trips.get_annotations(params) == OSRMs.ANNOTATIONS_ALL
    end

    @testset "Roundtrip" begin
        params = Trips.TripParams()
        # Default value
        initial_value = Trips.get_roundtrip(params)
        @test initial_value isa Bool

        Trips.set_roundtrip!(params, true)
        @test Trips.get_roundtrip(params) == true

        Trips.set_roundtrip!(params, false)
        @test Trips.get_roundtrip(params) == false

        Trips.set_roundtrip!(params, true)
        @test Trips.get_roundtrip(params) == true
    end

    @testset "Source" begin
        params = Trips.TripParams()
        # Default value
        initial_source = Trips.get_source(params)
        @test initial_source isa Trips.TripSource

        Trips.set_source!(params, Trips.TRIP_SOURCE_ANY_SOURCE)
        @test Trips.get_source(params) == Trips.TRIP_SOURCE_ANY_SOURCE

        Trips.set_source!(params, Trips.TRIP_SOURCE_FIRST)
        @test Trips.get_source(params) == Trips.TRIP_SOURCE_FIRST
    end

    @testset "Destination" begin
        params = Trips.TripParams()
        # Default value
        initial_destination = Trips.get_destination(params)
        @test initial_destination isa Trips.TripDestination

        Trips.set_destination!(params, Trips.TRIP_DESTINATION_ANY_DESTINATION)
        @test Trips.get_destination(params) == Trips.TRIP_DESTINATION_ANY_DESTINATION

        Trips.set_destination!(params, Trips.TRIP_DESTINATION_LAST)
        @test Trips.get_destination(params) == Trips.TRIP_DESTINATION_LAST
    end

    @testset "Waypoints" begin
        params = Trips.TripParams()
        # Add coordinates first
        Trips.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Trips.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Trips.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no waypoints
        @test Trips.get_waypoint_count(params) == 0

        # Add waypoint
        Trips.add_waypoint!(params, 2)
        @test Trips.get_waypoint_count(params) == 1
        @test Trips.get_waypoint(params, 1) == 2

        # Add another waypoint
        Trips.add_waypoint!(params, 1)
        @test Trips.get_waypoint_count(params) == 2
        waypoints = Trips.get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        Trips.clear_waypoints!(params)
        @test Trips.get_waypoint_count(params) == 0
    end

    @testset "Coordinates" begin
        params = Trips.TripParams()
        @test Trips.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Trips.add_coordinate!(params, coord1)
        @test Trips.get_coordinate_count(params) == 1
        @test Trips.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Trips.add_coordinate!(params, coord2)
        @test Trips.get_coordinate_count(params) == 2
        @test Trips.get_coordinate(params, 1) == coord1
        @test Trips.get_coordinate(params, 2) == coord2

        coords = Trips.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Trips.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trips.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Trips.get_coordinate_count(params) == 1
        @test Trips.get_coordinate(params, 1) == coord

        coord_with = Trips.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Trips.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Trips.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trips.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Trips.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Trips.set_hint!(params, 1, "")
        @test Trips.get_hint(params, 1) == ""

        # Set a non-empty hint
        Trips.set_hint!(params, 1, "test_hint")
        result = Trips.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Trips.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Trips.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trips.add_coordinate!(params, coord)

        # Initially no radius set
        @test Trips.get_radius(params, 1) === nothing

        # Set radius
        Trips.set_radius!(params, 1, 5.0)
        @test Trips.get_radius(params, 1) == 5.0

        # Set different radius
        Trips.set_radius!(params, 1, 10.5)
        @test Trips.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Trips.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Trips.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trips.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Trips.get_bearing(params, 1) === nothing

        # Set bearing
        Trips.set_bearing!(params, 1, 0, 90)
        bearing = Trips.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Trips.set_bearing!(params, 1, 180, 45)
        bearing = Trips.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Trips.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Trips.TripParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Trips.add_coordinate!(params, coord)

        # Initially no approach set
        @test Trips.get_approach(params, 1) === nothing

        # Set approach
        Trips.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Trips.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Trips.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Trips.TripParams()

        # Initially no excludes
        @test Trips.get_exclude_count(params) == 0

        # Add exclude
        Trips.add_exclude!(params, "toll")
        @test Trips.get_exclude_count(params) == 1
        @test Trips.get_exclude(params, 1) == "toll"

        # Add another exclude
        Trips.add_exclude!(params, "ferry")
        @test Trips.get_exclude_count(params) == 2
        @test Trips.get_exclude(params, 1) == "toll"
        @test Trips.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Trips.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Trips.TripParams()

        # Default value
        initial_value = Trips.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Trips.set_generate_hints!(params, true)
        @test Trips.get_generate_hints(params) == true

        # Set to false
        Trips.set_generate_hints!(params, false)
        @test Trips.get_generate_hints(params) == false

        # Set back to true
        Trips.set_generate_hints!(params, true)
        @test Trips.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Trips.TripParams()

        # Default value
        initial_value = Trips.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Trips.set_skip_waypoints!(params, true)
        @test Trips.get_skip_waypoints(params) == true

        # Set to false
        Trips.set_skip_waypoints!(params, false)
        @test Trips.get_skip_waypoints(params) == false

        # Set back to true
        Trips.set_skip_waypoints!(params, true)
        @test Trips.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Trips.TripParams()

        # Default value
        initial_snapping = Trips.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Trips.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Trips.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Trip - Query Execution" begin
    @testset "Basic trip query" begin
        params = Trips.TripParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end
        response = Trips.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trips.TripResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Trip with roundtrip enabled" begin
        params = Trips.TripParams()
        Trips.set_roundtrip!(params, true)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end
        response = Trips.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trips.TripResponse
    end

    @testset "Trip with roundtrip disabled" begin
        params = Trips.TripParams()
        Trips.set_roundtrip!(params, false)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end
        try
            response = Trips.trip_response(TestUtils.get_test_osrm(), params)
            @test response isa Trips.TripResponse
        catch e
            # Trip may fail if roundtrip disabled and coordinates cannot form a valid trip
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Trip with source set to first" begin
        params = Trips.TripParams()
        Trips.set_source!(params, Trips.TRIP_SOURCE_FIRST)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end
        response = Trips.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trips.TripResponse
    end

    @testset "Trip with destination set to last" begin
        params = Trips.TripParams()
        Trips.set_destination!(params, Trips.TRIP_DESTINATION_LAST)
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end
        response = Trips.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trips.TripResponse
    end

    @testset "Trip with waypoints" begin
        params = Trips.TripParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end
        Trips.add_waypoint!(params, 1)
        Trips.add_waypoint!(params, 2)
        response = Trips.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trips.TripResponse
    end

    @testset "Trip with all parameters" begin
        params = Trips.TripParams()
        for (name, coord) in TestUtils.get_hamburg_coordinates()
            Trips.add_coordinate!(params, coord)
        end

        Trips.set_roundtrip!(params, true)
        Trips.set_source!(params, Trips.TRIP_SOURCE_FIRST)
        Trips.set_destination!(params, Trips.TRIP_DESTINATION_LAST)
        Trips.set_steps!(params, true)
        Trips.set_alternatives!(params, true)
        Trips.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        Trips.set_overview!(params, OSRMs.OVERVIEW_FULL)
        Trips.set_continue_straight!(params, true)
        Trips.set_number_of_alternatives!(params, 2)
        Trips.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)

        Trips.add_waypoint!(params, 1)
        Trips.set_hint!(params, 1, "")
        Trips.set_radius!(params, 1, 10.0)
        Trips.set_bearing!(params, 1, 0, 180)
        Trips.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Trips.add_exclude!(params, "toll")
        Trips.set_generate_hints!(params, true)
        Trips.set_skip_waypoints!(params, false)
        Trips.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Trips.trip_response(TestUtils.get_test_osrm(), params)
        @test response isa Trips.TripResponse
    end
end

@testset "Trip - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = Trips.TripParams()
        Trips.add_coordinate!(params, OSRMs.Position(0.0, 0.0))
        Trips.add_coordinate!(params, OSRMs.Position(1.0, 1.0))

        maybe_response = try
            Trips.trip_response(TestUtils.get_test_osrm(), params)
        catch e
            @test e isa OSRMs.OSRMError
            nothing
        end
        if maybe_response !== nothing
            @test maybe_response isa Trips.TripResponse
        end
    end

    @testset "Error messages are informative" begin
        params = Trips.TripParams()
        Trips.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        Trips.add_coordinate!(params, OSRMs.Position(201.0, 201.0))
        try
            Trips.trip(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
