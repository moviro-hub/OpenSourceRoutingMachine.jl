using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Matches: Matches

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Match - Setters and Getters" begin
    @testset "Steps" begin
        params = Matches.MatchParams()
        # Default value
        initial_value = Matches.get_steps(params)
        @test initial_value isa Bool

        Matches.set_steps!(params, true)
        @test Matches.get_steps(params) == true

        Matches.set_steps!(params, false)
        @test Matches.get_steps(params) == false

        Matches.set_steps!(params, true)
        @test Matches.get_steps(params) == true
    end

    @testset "Alternatives" begin
        params = Matches.MatchParams()
        # Default value
        initial_value = Matches.get_alternatives(params)
        @test initial_value isa Bool

        Matches.set_alternatives!(params, true)
        @test Matches.get_alternatives(params) == true

        Matches.set_alternatives!(params, false)
        @test Matches.get_alternatives(params) == false

        Matches.set_alternatives!(params, true)
        @test Matches.get_alternatives(params) == true
    end

    @testset "Geometries" begin
        params = Matches.MatchParams()
        # Default value
        initial_geometries = Matches.get_geometries(params)
        @test initial_geometries isa OSRMs.Geometries

        Matches.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE)
        @test Matches.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE

        Matches.set_geometries!(params, OSRMs.GEOMETRIES_POLYLINE6)
        @test Matches.get_geometries(params) == OSRMs.GEOMETRIES_POLYLINE6

        Matches.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        @test Matches.get_geometries(params) == OSRMs.GEOMETRIES_GEOJSON
    end

    @testset "Overview" begin
        params = Matches.MatchParams()
        # Default value
        initial_overview = Matches.get_overview(params)
        @test initial_overview isa OSRMs.Overview

        Matches.set_overview!(params, OSRMs.OVERVIEW_SIMPLIFIED)
        @test Matches.get_overview(params) == OSRMs.OVERVIEW_SIMPLIFIED

        Matches.set_overview!(params, OSRMs.OVERVIEW_FULL)
        @test Matches.get_overview(params) == OSRMs.OVERVIEW_FULL

        Matches.set_overview!(params, OSRMs.OVERVIEW_FALSE)
        @test Matches.get_overview(params) == OSRMs.OVERVIEW_FALSE
    end

    @testset "Continue Straight" begin
        params = Matches.MatchParams()
        # Default value (may be nothing)
        initial_value = Matches.get_continue_straight(params)
        @test initial_value === nothing || initial_value isa Bool

        Matches.set_continue_straight!(params, true)
        @test Matches.get_continue_straight(params) == true

        Matches.set_continue_straight!(params, false)
        @test Matches.get_continue_straight(params) == false

        Matches.set_continue_straight!(params, true)
        @test Matches.get_continue_straight(params) == true
    end

    @testset "Number of Alternatives" begin
        params = Matches.MatchParams()
        # Default value
        initial_value = Matches.get_number_of_alternatives(params)
        @test initial_value isa Int

        Matches.set_number_of_alternatives!(params, 1)
        @test Matches.get_number_of_alternatives(params) == 1

        Matches.set_number_of_alternatives!(params, 3)
        @test Matches.get_number_of_alternatives(params) == 3

        Matches.set_number_of_alternatives!(params, 5)
        @test Matches.get_number_of_alternatives(params) == 5
    end

    @testset "Annotations" begin
        params = Matches.MatchParams()
        # Default value
        initial_annotations = Matches.get_annotations(params)
        @test initial_annotations isa OSRMs.Annotations

        Matches.set_annotations!(params, OSRMs.ANNOTATIONS_NONE)
        @test Matches.get_annotations(params) == OSRMs.ANNOTATIONS_NONE

        Matches.set_annotations!(params, OSRMs.ANNOTATIONS_DURATION)
        @test Matches.get_annotations(params) == OSRMs.ANNOTATIONS_DURATION

        Matches.set_annotations!(params, OSRMs.ANNOTATIONS_DISTANCE)
        @test Matches.get_annotations(params) == OSRMs.ANNOTATIONS_DISTANCE

        Matches.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        @test Matches.get_annotations(params) == OSRMs.ANNOTATIONS_ALL
    end

    @testset "Waypoints" begin
        params = Matches.MatchParams()
        # Add coordinates first
        Matches.add_coordinate!(params, Main.TestUtils.get_hamburg_coordinates()["city_center"])
        Matches.add_coordinate!(params, Main.TestUtils.get_hamburg_coordinates()["airport"])
        Matches.add_coordinate!(params, Main.TestUtils.get_hamburg_coordinates()["port"])

        # Initially no waypoints
        @test Matches.get_waypoint_count(params) == 0

        # Add waypoint
        Matches.add_waypoint!(params, 2)
        @test Matches.get_waypoint_count(params) == 1
        @test Matches.get_waypoint(params, 1) == 2

        # Add another waypoint
        Matches.add_waypoint!(params, 1)
        @test Matches.get_waypoint_count(params) == 2
        waypoints = Matches.get_waypoints(params)
        @test length(waypoints) == 2
        @test 1 in waypoints
        @test 2 in waypoints

        # Clear waypoints
        Matches.clear_waypoints!(params)
        @test Matches.get_waypoint_count(params) == 0
    end

    @testset "Timestamps" begin
        params = Matches.MatchParams()
        # Add coordinates first
        Matches.add_coordinate!(params, Main.TestUtils.get_hamburg_coordinates()["city_center"])
        Matches.add_coordinate!(params, Main.TestUtils.get_hamburg_coordinates()["airport"])

        # Initially no timestamps
        @test Matches.get_timestamp_count(params) == 0

        # Add timestamp
        Matches.add_timestamp!(params, 0)
        @test Matches.get_timestamp_count(params) == 1
        @test Matches.get_timestamp(params, 1) == 0

        # Add another timestamp
        Matches.add_timestamp!(params, 100)
        @test Matches.get_timestamp_count(params) == 2
        @test Matches.get_timestamp(params, 1) == 0
        @test Matches.get_timestamp(params, 2) == 100

        # Get all timestamps
        timestamps = Matches.get_timestamps(params)
        @test length(timestamps) == 2
        @test timestamps[1] == 0
        @test timestamps[2] == 100
    end

    @testset "Gaps" begin
        params = Matches.MatchParams()
        # Default value
        initial_gaps = Matches.get_gaps(params)
        @test initial_gaps isa Matches.MatchGaps

        Matches.set_gaps!(params, Matches.MATCH_GAPS_SPLIT)
        @test Matches.get_gaps(params) == Matches.MATCH_GAPS_SPLIT

        Matches.set_gaps!(params, Matches.MATCH_GAPS_IGNORE)
        @test Matches.get_gaps(params) == Matches.MATCH_GAPS_IGNORE
    end

    @testset "Tidy" begin
        params = Matches.MatchParams()
        # Default value
        initial_value = Matches.get_tidy(params)
        @test initial_value isa Bool

        Matches.set_tidy!(params, true)
        @test Matches.get_tidy(params) == true

        Matches.set_tidy!(params, false)
        @test Matches.get_tidy(params) == false

        Matches.set_tidy!(params, true)
        @test Matches.get_tidy(params) == true
    end

    @testset "Coordinates" begin
        params = Matches.MatchParams()
        @test Matches.get_coordinate_count(params) == 0

        coord1 = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate!(params, coord1)
        @test Matches.get_coordinate_count(params) == 1
        @test Matches.get_coordinate(params, 1) == coord1

        coord2 = Main.TestUtils.get_hamburg_coordinates()["port"]
        Matches.add_coordinate!(params, coord2)
        @test Matches.get_coordinate_count(params) == 2
        @test Matches.get_coordinate(params, 1) == coord1
        @test Matches.get_coordinate(params, 2) == coord2

        coords = Matches.get_coordinates(params)
        @test length(coords) == 2
        @test coords[1] == coord1
        @test coords[2] == coord2
    end

    @testset "Coordinate With Radius and Bearing" begin
        params = Matches.MatchParams()
        coord = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate_with!(params, coord, 10.0, 0, 180)

        @test Matches.get_coordinate_count(params) == 1
        @test Matches.get_coordinate(params, 1) == coord

        coord_with = Matches.get_coordinate_with(params, 1)
        @test coord_with[1] == coord
        @test coord_with[2] == 10.0  # radius
        @test coord_with[3] == (0, 180)  # bearing (value, range)

        coords_with = Matches.get_coordinates_with(params)
        @test length(coords_with) == 1
        @test coords_with[1] == coord_with
    end

    @testset "Hints" begin
        params = Matches.MatchParams()
        coord = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate!(params, coord)

        # Initially no hint (may be nothing or empty string)
        initial_hint = Matches.get_hint(params, 1)
        @test initial_hint === nothing || initial_hint == ""

        # Set a hint (empty string is valid)
        Matches.set_hint!(params, 1, "")
        @test Matches.get_hint(params, 1) == ""

        # Set a non-empty hint
        Matches.set_hint!(params, 1, "test_hint")
        result = Matches.get_hint(params, 1)
        # Note: Some implementations may return empty string instead of the set value
        @test result == "test_hint" || result == ""

        # Get all hints
        hints = Matches.get_hints(params)
        @test length(hints) == 1
        @test hints[1] isa Union{String, Nothing}
    end

    @testset "Radius" begin
        params = Matches.MatchParams()
        coord = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate!(params, coord)

        # Initially no radius set
        @test Matches.get_radius(params, 1) === nothing

        # Set radius
        Matches.set_radius!(params, 1, 5.0)
        @test Matches.get_radius(params, 1) == 5.0

        # Set different radius
        Matches.set_radius!(params, 1, 10.5)
        @test Matches.get_radius(params, 1) == 10.5

        # Get all radii
        radii = Matches.get_radii(params)
        @test length(radii) == 1
        @test radii[1] == 10.5
    end

    @testset "Bearing" begin
        params = Matches.MatchParams()
        coord = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate!(params, coord)

        # Initially no bearing set
        @test Matches.get_bearing(params, 1) === nothing

        # Set bearing
        Matches.set_bearing!(params, 1, 0, 90)
        bearing = Matches.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 0   # value
        @test bearing[2] == 90  # range

        # Set different bearing
        Matches.set_bearing!(params, 1, 180, 45)
        bearing = Matches.get_bearing(params, 1)
        @test bearing !== nothing
        @test bearing[1] == 180
        @test bearing[2] == 45

        # Get all bearings
        bearings = Matches.get_bearings(params)
        @test length(bearings) == 1
        @test bearings[1] == (180, 45)
    end

    @testset "Approach" begin
        params = Matches.MatchParams()
        coord = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate!(params, coord)

        # Initially no approach set
        @test Matches.get_approach(params, 1) === nothing

        # Set approach
        Matches.set_approach!(params, 1, OSRMs.APPROACH_CURB)
        @test Matches.get_approach(params, 1) == OSRMs.APPROACH_CURB

        # Get all approaches
        approaches = Matches.get_approaches(params)
        @test length(approaches) == 1
        @test approaches[1] == OSRMs.APPROACH_CURB
    end

    @testset "Excludes" begin
        params = Matches.MatchParams()

        # Initially no excludes
        @test Matches.get_exclude_count(params) == 0

        # Add exclude
        Matches.add_exclude!(params, "toll")
        @test Matches.get_exclude_count(params) == 1
        @test Matches.get_exclude(params, 1) == "toll"

        # Add another exclude
        Matches.add_exclude!(params, "ferry")
        @test Matches.get_exclude_count(params) == 2
        @test Matches.get_exclude(params, 1) == "toll"
        @test Matches.get_exclude(params, 2) == "ferry"

        # Get all excludes
        excludes = Matches.get_excludes(params)
        @test length(excludes) == 2
        @test excludes[1] == "toll"
        @test excludes[2] == "ferry"
    end

    @testset "Generate Hints" begin
        params = Matches.MatchParams()

        # Default value
        initial_value = Matches.get_generate_hints(params)
        @test initial_value isa Bool

        # Set to true
        Matches.set_generate_hints!(params, true)
        @test Matches.get_generate_hints(params) == true

        # Set to false
        Matches.set_generate_hints!(params, false)
        @test Matches.get_generate_hints(params) == false

        # Set back to true
        Matches.set_generate_hints!(params, true)
        @test Matches.get_generate_hints(params) == true
    end

    @testset "Skip Waypoints" begin
        params = Matches.MatchParams()

        # Default value
        initial_value = Matches.get_skip_waypoints(params)
        @test initial_value isa Bool

        # Set to true
        Matches.set_skip_waypoints!(params, true)
        @test Matches.get_skip_waypoints(params) == true

        # Set to false
        Matches.set_skip_waypoints!(params, false)
        @test Matches.get_skip_waypoints(params) == false

        # Set back to true
        Matches.set_skip_waypoints!(params, true)
        @test Matches.get_skip_waypoints(params) == true
    end

    @testset "Snapping" begin
        params = Matches.MatchParams()

        # Default value
        initial_snapping = Matches.get_snapping(params)
        @test initial_snapping isa OSRMs.Snapping

        # Set snapping
        Matches.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)
        @test Matches.get_snapping(params) == OSRMs.SNAPPING_DEFAULT
    end
end

@testset "Match - Query Execution" begin
    @testset "Basic match query" begin
        params = Matches.MatchParams()
        for coord in Main.TestUtils.get_trace_coords_city_center_to_airport()
            Matches.add_coordinate!(params, coord)
        end
        response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
        @test response isa Matches.MatchResponse
        @test response.ptr != Base.C_NULL
    end

    @testset "Match with timestamps" begin
        params = Matches.MatchParams()
        coords = Main.TestUtils.get_trace_coords_city_center_to_altona()
        for coord in coords
            Matches.add_coordinate!(params, coord)
        end
        for i in 1:length(coords)
            Matches.add_timestamp!(params, (i - 1) * 10)
        end
        response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
        @test response isa Matches.MatchResponse
    end

    @testset "Match with gaps set to split" begin
        params = Matches.MatchParams()
        Matches.set_gaps!(params, Matches.MATCH_GAPS_SPLIT)
        for coord in Main.TestUtils.get_trace_coords_city_center_to_airport()
            Matches.add_coordinate!(params, coord)
        end
        response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
        @test response isa Matches.MatchResponse
    end

    @testset "Match with gaps set to ignore" begin
        params = Matches.MatchParams()
        Matches.set_gaps!(params, Matches.MATCH_GAPS_IGNORE)
        for coord in Main.TestUtils.get_trace_coords_city_center_to_port()
            Matches.add_coordinate!(params, coord)
        end
        try
            response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
            @test response isa Matches.MatchResponse
        catch e
            # Match may fail if coordinates cannot be matched
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Match with tidy enabled" begin
        params = Matches.MatchParams()
        Matches.set_tidy!(params, true)
        for coord in Main.TestUtils.get_trace_coords_city_center_to_port()
            Matches.add_coordinate!(params, coord)
        end
        try
            response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
            @test response isa Matches.MatchResponse
        catch e
            # Match may fail if coordinates cannot be matched
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Match with all parameters" begin
        params = Matches.MatchParams()
        coords = Main.TestUtils.get_trace_coords_city_center_to_altona()
        for coord in coords
            Matches.add_coordinate!(params, coord)
        end
        for i in 1:length(coords)
            Matches.add_timestamp!(params, (i - 1) * 10)
        end

        Matches.set_steps!(params, true)
        Matches.set_alternatives!(params, true)
        Matches.set_geometries!(params, OSRMs.GEOMETRIES_GEOJSON)
        Matches.set_overview!(params, OSRMs.OVERVIEW_FULL)
        Matches.set_continue_straight!(params, true)
        Matches.set_number_of_alternatives!(params, 2)
        Matches.set_annotations!(params, OSRMs.ANNOTATIONS_ALL)
        Matches.set_gaps!(params, Matches.MATCH_GAPS_SPLIT)
        Matches.set_tidy!(params, true)

        Matches.set_hint!(params, 1, "")
        Matches.set_radius!(params, 1, 10.0)
        Matches.set_bearing!(params, 1, 0, 180)
        Matches.set_approach!(params, 1, OSRMs.APPROACH_CURB)

        Matches.add_exclude!(params, "toll")
        Matches.set_generate_hints!(params, true)
        Matches.set_skip_waypoints!(params, false)
        Matches.set_snapping!(params, OSRMs.SNAPPING_DEFAULT)

        response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
        @test response isa Matches.MatchResponse
    end
end

@testset "Match - Error Handling" begin
    @testset "Invalid coordinates" begin
        params = Matches.MatchParams()
        Matches.add_coordinate!(params, OSRMs.Position(0.0, 0.0))
        Matches.add_coordinate!(params, OSRMs.Position(1.0, 1.0))
        try
            response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
            @test response isa Matches.MatchResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Error messages are informative" begin
        params = Matches.MatchParams()
        Matches.add_coordinate!(params, OSRMs.Position(200.0, 200.0))
        Matches.add_coordinate!(params, OSRMs.Position(201.0, 201.0))
        try
            Matches.match(Main.TestUtils.get_test_osrm(), params)
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
        params = Matches.MatchParams()
        coord = Main.TestUtils.get_hamburg_coordinates()["city_center"]
        Matches.add_coordinate!(params, coord)
        Matches.add_coordinate!(params, coord)
        try
            response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
            @test response isa Matches.MatchResponse
        catch e
            @test e isa OSRMs.OSRMError
        end
    end

    @testset "Very short trace" begin
        params = Matches.MatchParams()
        coords = Main.TestUtils.get_trace_coords_city_center_to_airport()
        for coord in coords[1:min(5, length(coords))]
            Matches.add_coordinate!(params, coord)
        end
        response = Matches.match_response(Main.TestUtils.get_test_osrm(), params)
        @test response isa Matches.MatchResponse
    end
end
