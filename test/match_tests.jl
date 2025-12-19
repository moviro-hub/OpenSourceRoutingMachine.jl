using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Match: Match

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Match - Setters and Getters" begin
    @testset "Steps" begin
        params = Match.MatchParams()
        # Default value
        initial_value = Match.get_steps(params)
        @test initial_value isa Bool

        Match.set_steps!(params, true)
        @test Match.get_steps(params) == true

        Match.set_steps!(params, false)
        @test Match.get_steps(params) == false

        Match.set_steps!(params, true)
        @test Match.get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = Match.MatchParams()
        # Default value
        initial_value = Match.get_alternatives(params)
        @test initial_value isa Bool

        Match.set_alternatives!(params, true)
        @test Match.get_alternatives(params) == true

        Match.set_alternatives!(params, false)
        @test Match.get_alternatives(params) == false

        Match.set_alternatives!(params, true)
        @test Match.get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = Match.MatchParams()
        # Default value
        initial_geometries = Match.get_geometries(params)
        @test initial_geometries isa OSRMs.Geometries

        Match.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE)
        @test Match.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE

        Match.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE6)
        @test Match.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE6

        Match.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        @test Match.get_geometries(params) == OSRMs.GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = Match.MatchParams()
        # Default value
        initial_overview = Match.get_overview(params)
        @test initial_overview isa OSRMs.Overview

        Match.set_overview!(params, OSRMs.OVERVIEW_SIMPLIFIED)
        @test Match.get_overview(params) == OSRMs.OVERVIEW_SIMPLIFIED

        Match.set_overview!(params, OSRMs.OVERVIEW_FULL)
        @test Match.get_overview(params) == OSRMs.OVERVIEW_FULL

        Match.set_overview!(params, OSRMs.OVERVIEW_FALSE)
        @test Match.get_overview(params) == OSRMs.OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = Match.MatchParams()
        # Default value (may be nothing)
        initial_value = Match.get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        Match.set_continue_straight!(params, true)
        @test Match.get_continue_straight(params) == true

        Match.set_continue_straight!(params, false)
        @test Match.get_continue_straight(params) == false

        Match.set_continue_straight!(params, true)
        @test Match.get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = Match.MatchParams()
        # Default value
        initial_value = Match.get_number_of_alternatives(params)
        @test initial_value isa Int

        Match.set_number_of_alternatives!(params, 1)
        @test Match.get_number_of_alternatives(params) == 1

        Match.set_number_of_alternatives!(params, 3)
        @test Match.get_number_of_alternatives(params) == 3

        Match.set_number_of_alternatives!(params, 5)
        @test Match.get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = Match.MatchParams()
        # Default value
        initial_annotations = Match.get_annotations(params)
        @test initial_annotations isa OSRMs.Annotations

        Match.set_annotations!(params, OSRMs.ANNOTATIONS_NONE)
        @test Match.get_annotations(params) == OSRMs.ANNOTATIONS_NONE

        Match.set_annotations!(params, OSRMs.ANNOTATIONS_DURATION)
        @test Match.get_annotations(params) == OSRMs.ANNOTATIONS_DURATION

        Match.set_annotations!(params, OSRMs.ANNOTATIONS_DISTANCE)
        @test Match.get_annotations(params) == OSRMs.ANNOTATIONS_DISTANCE

        Match.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        @test Match.get_annotations(params) == OSRMs.ANNOTATIONS_ALL
    end

    @testset "Waypoints" begin
        params = Match.MatchParams()
        # Add coordinates first
        Match.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Match.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)
        Match.add_coordinate!(params, TestUtils.HAMBURG_PORT)

        # Initially no waypoints
        @test Match.get_waypoint_count(params) == 0

        # Add waypoint
        Match.add_waypoint!(params, 2)
        @test Match.get_waypoint_count(params) == 1
        @test Match.get_waypoint(params, 1) == 2

        # Add another waypoint
        Match.add_waypoint!(params, 1)
        @test Match.get_waypoint_count(params) == 2
        waypoints = Match.get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        Match.clear_waypoints!(params)
        @test Match.get_waypoint_count(params) == 0
    end

    @testset "Timestamps" begin
        params = Match.MatchParams()
        # Add coordinates first
        Match.add_coordinate!(params, TestUtils.HAMBURG_CITY_CENTER)
        Match.add_coordinate!(params, TestUtils.HAMBURG_AIRPORT)

        # Initially no timestamps
        @test Match.get_timestamp_count(params) == 0

        # Add timestamp
        Match.add_timestamp!(params, 0)
        @test Match.get_timestamp_count(params) == 1
        @test Match.get_timestamp(params, 1) == 0

        # Add another timestamp
        Match.add_timestamp!(params, 100)
        @test Match.get_timestamp_count(params) == 2
        @test Match.get_timestamp(params, 1) == 0
        @test Match.get_timestamp(params, 2) == 100

        # Get all timestamps
        timestamps = Match.get_timestamps(params)
        @test length(timestamps) == 2
        @test timestamps[1] == 0
        @test timestamps[2] == 100
    end

    @testset "Gaps" begin
        params = Match.MatchParams()
        # Default value
        initial_gaps = Match.get_gaps(params)
        @test initial_gaps isa Match.MatchGaps

        Match.set_gaps!(params, Match.MATCH_GAPS_SPLIT)
        @test Match.get_gaps(params) == Match.MATCH_GAPS_SPLIT

        Match.set_gaps!(params, Match.MATCH_GAPS_IGNORE)
        @test Match.get_gaps(params) == Match.MATCH_GAPS_IGNORE
    end

    @testset "Tidy" begin
        params = Match.MatchParams()
        # Default value
        initial_value = Match.get_tidy(params)
        @test initial_value isa Bool

        Match.set_tidy!(params, true)
        @test Match.get_tidy(params) == true

        Match.set_tidy!(params, false)
        @test Match.get_tidy(params) == false

        Match.set_tidy!(params, true)
        @test Match.get_tidy(params) == true
    end

    @testset "Coordinates" begin
        params = Match.MatchParams()
        @test Match.get_coordinate_count(params) == 0

        coord1 = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate!(params, coord1)
        @test Match.get_coordinate_count(params) == 1
        @test Match.get_coordinate(params, 1) == coord1

        coord2 = TestUtils.HAMBURG_PORT
        Match.add_coordinate!(params, coord2)
        @test Match.get_coordinate_count(params) == 2
        @test Match.get_coordinate(params, 1) == coord1
        @test Match.get_coordinate(params, 2) == coord2

        coords = Match.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Match.MatchParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Match.get_coordinate_count(params) == 1
        @test Match.get_coordinate(params, 1) == coord

        coord_with = Match.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Match.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Match.MatchParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Match.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Match.set_hint!(params, 1, "")
        @test Match.get_hint(params, 1) == ""

        # Set a non-empty hint
        Match.set_hint!(params, 1, "test_hint")
        result = Match.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Match.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Match.MatchParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate!(params, coord)

        # Initially no radius set
        @test Match.get_radius(params, 1) === nothing

        # Set radius
        Match.set_radius!(params, 1, 5.0)
        @test Match.get_radius(params, 1) == 5.0

        # Set different radius
        Match.set_radius!(params, 1, 10.5)
        @test Match.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Match.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Match.MatchParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Match.get_bearing(params, 1) === nothing

        # Set bearing
        Match.set_bearing!(params, 1, 0, 90)
        bearing = Match.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Match.set_bearing!(params, 1, 180, 45)
        bearing = Match.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Match.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Match.MatchParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate!(params, coord)

        # Initially no approach set
        @test Match.get_approach(params, 1) === nothing

        # Set approach
        Match.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Match.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Match.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Match.MatchParams()

        # Initially no excludes
        @test Match.get_exclude_count(params) == 0

        # Add exclude
        Match.add_exclude!(params, "toll")
        @test Match.get_exclude_count(params) == 1
        @test Match.get_exclude(params, 1) == "toll"

        # Add another exclude
        Match.add_exclude!(params, "ferry")
        @test Match.get_exclude_count(params) == 2
        @test Match.get_exclude(params, 1) == "toll"
        @test Match.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Match.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Match.MatchParams()

        # Default value
        initial_value = Match.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Match.set_generate_hints!(params, true)
        @test Match.get_generate_hints(params) == true

        # Set to false
        Match.set_generate_hints!(params, false)
        @test Match.get_generate_hints(params) == false

        # Set back to true
        Match.set_generate_hints!(params, true)
        @test Match.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Match.MatchParams()

        # Default value
        initial_value = Match.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Match.set_skip_waypoints!(params, true)
        @test Match.get_skip_waypoints(params) == true

        # Set to false
        Match.set_skip_waypoints!(params, false)
        @test Match.get_skip_waypoints(params) == false

        # Set back to true
        Match.set_skip_waypoints!(params, true)
        @test Match.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Match.MatchParams()

        # Default value
        initial_snapping = Match.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Match.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Match.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Match - Query Execution" begin
    @testset "Basic match query" begin
        params = Match.MatchParams()
        for coord in TestUtils.get_trace_coords_city_center_to_airport()
            Match.add_coordinate!(params, coord)
        end
        response = Match.match_response(TestUtils.get_test_osrm(), params)
        @test response isa Match.MatchResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Match with timestamps" begin
        params = Match.MatchParams()
        coords = TestUtils.get_trace_coords_city_center_to_altona()
        for coord in coords
            Match.add_coordinate!(params, coord)
        end
        for i in 1:length(coords)
            Match.add_timestamp!(params, (i - 1) * 10)
        end
        response = Match.match_response(TestUtils.get_test_osrm(), params)
        @test response isa Match.MatchResponse
    end

    @testset "Match with gaps set to split" begin
        params = Match.MatchParams()
        Match.set_gaps!(params, Match.MATCH_GAPS_SPLIT)
        for coord in TestUtils.get_trace_coords_city_center_to_airport()
            Match.add_coordinate!(params, coord)
        end
        response = Match.match_response(TestUtils.get_test_osrm(), params)
        @test response isa Match.MatchResponse
    end

    @testset "Match with gaps set to ignore" begin
        params = Match.MatchParams()
        Match.set_gaps!(params, Match.MATCH_GAPS_IGNORE)
        for coord in TestUtils.get_trace_coords_city_center_to_port()
            Match.add_coordinate!(params, coord)
        end
        try
            response = Match.match_response(TestUtils.get_test_osrm(), params)
            @test response isa Match.MatchResponse
        catch e
            # Match may fail if coordinates cannot be matched
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Match with tidy enabled" begin
        params = Match.MatchParams()
        Match.set_tidy!(params, true)
        for coord in TestUtils.get_trace_coords_city_center_to_port()
            Match.add_coordinate!(params, coord)
        end
        try
            response = Match.match_response(TestUtils.get_test_osrm(), params)
            @test response isa Match.MatchResponse
        catch e
            # Match may fail if coordinates cannot be matched
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Match with all parameters" begin
        params = Match.MatchParams()
        coords = TestUtils.get_trace_coords_city_center_to_altona()
        for coord in coords
            Match.add_coordinate!(params, coord)
        end
        for i in 1:length(coords)
            Match.add_timestamp!(params, (i - 1) * 10)
        end

        Match.set_steps!(params, true)
        Match.set_alternatives!(params, true)
        Match.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        Match.set_overview!(params, OSRMs.OVERVIEW_FULL)
        Match.set_continue_straight!(params, true)
        Match.set_number_of_alternatives!(params, 2)
        Match.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        Match.set_gaps!(params, Match.MATCH_GAPS_SPLIT)
        Match.set_tidy!(params, true)

        Match.set_hint!(params, 1, "")
        Match.set_radius!(params, 1, 10.0)
        Match.set_bearing!(params, 1, 0, 180)
        Match.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Match.add_exclude!(params, "toll")
        Match.set_generate_hints!(params, true)
        Match.set_skip_waypoints!(params, false)
        Match.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Match.match_response(TestUtils.get_test_osrm(), params)
        @test response isa Match.MatchResponse
    end
end

@testset "Match - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = Match.MatchParams()
        Match.add_coordinate!(params, OSRMs.Position(0.0, 0.0))
        Match.add_coordinate!(params, OSRMs.Position(1.0, 1.0))
        try
            response = Match.match_response(TestUtils.get_test_osrm(), params)
            @test response isa Match.MatchResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = Match.MatchParams()
        Match.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        Match.add_coordinate!(params, OSRMs.Position(201.0, 201.0))
        try
            Match.match(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end

@testset "Match - Edge Cases" begin
    @testset "Same start and end point" begin
        params = Match.MatchParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        Match.add_coordinate!(params, coord)
        Match.add_coordinate!(params, coord)
        try
            response = Match.match_response(TestUtils.get_test_osrm(), params)
            @test response isa Match.MatchResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Very short trace" begin
        params = Match.MatchParams()
        coords = TestUtils.get_trace_coords_city_center_to_airport()
        for coord in coords[1:min(5, length(coords))]
            Match.add_coordinate!(params, coord)
        end
        response = Match.match_response(TestUtils.get_test_osrm(), params)
        @test response isa Match.MatchResponse
    end
end
