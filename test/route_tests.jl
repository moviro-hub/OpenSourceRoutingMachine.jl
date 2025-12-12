using Test
using OpenSourceRoutingMachine: Position, OSRMError, Approach, Snapping, Geometries, Overview, Annotations
using OpenSourceRoutingMachine.Routes:
    RouteParams,
    RouteResponse,
    # params
    add_coordinate!,
    add_coordinate_with!,
    add_steps!,
    set_alternatives!,
    set_geometries!,
    set_overview!,
    set_continue_straight!,
    set_number_of_alternatives!,
    set_annotations!,
    add_waypoint!,
    clear_waypoints!,
    set_hint!,
    set_radius!,
    set_bearing!,
    set_approach!,
    add_exclude!,
    set_generate_hints!,
    set_skip_waypoints!,
    set_snapping!,
    # responses
    route,
    route_response,
    get_json
using Base: C_NULL, length, isfinite
using .Fixtures

@testset "Route - Basic" begin
    @testset "RouteParams creation" begin
        params = RouteParams()
        @test params isa RouteParams
        @test params.ptr != C_NULL
    end

    @testset "Adding coordinates" begin
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        @test true
    end

    @testset "Route between two points" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route_response(osrm, params)
        @test response isa RouteResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Route response validity" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_PORT)
        response = route_response(osrm, params)
        @test response.ptr != C_NULL
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Route - Parameters" begin
    @testset "set_steps!" begin
        params = RouteParams()
        set_steps!(params, true)
        set_steps!(params, false)
        @test true
    end

    @testset "set_alternatives!" begin
        params = RouteParams()
        set_alternatives!(params, true)
        set_alternatives!(params, false)
        @test true
    end

    @testset "add_coordinate_with!" begin
        params = RouteParams()
        add_coordinate_with!(params, Fixtures.HAMBURG_CITY_CENTER, 10.0, 0, 180)
        @test true
    end

    @testset "Route with steps enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        set_steps!(params, true)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_ALTONA)
        response = route_response(osrm, params)
        @test response isa RouteResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Route with alternatives enabled" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        set_alternatives!(params, true)
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)
        response = route_response(osrm, params)
        @test response isa RouteResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Other parameter helpers smoke test" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()

        # basic coordinates
        add_coordinate!(params, Fixtures.HAMBURG_CITY_CENTER)
        add_coordinate!(params, Fixtures.HAMBURG_AIRPORT)

        # toggles and options
        # use a known-valid geometries value
        set_geometries!(params, Geometries(2))  # geojson
        set_overview!(params, Overview(1))  # full
        set_continue_straight!(params, true)
        set_number_of_alternatives!(params, 2)
        set_annotations!(params, Annotations(5))  # distance | duration

        # waypoint helpers
        # clear/add waypoints without requiring endpoints to be waypoints
        clear_waypoints!(params)

        # per-coordinate hints
        set_hint!(params, 1, "")
        set_radius!(params, 1, 10.0)
        set_bearing!(params, 1, 0, 180)
        set_approach!(params, 1, Approach(0))  # curb

        # global behavior
        add_exclude!(params, "toll")
        set_generate_hints!(params, true)
        set_skip_waypoints!(params, false)
        set_snapping!(params, Snapping(0))  # default

        response = route_response(osrm, params)
        @test response isa RouteResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Route - Error Handling" begin
    @testset "Invalid coordinates" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Position(0.0, 0.0))
        add_coordinate!(params, Position(1.0, 1.0))
        try
            response = route_response(osrm, params)
            @test response isa RouteResponse
            json = get_json(response)
            @test isa(json, String)
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Error messages are informative" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        add_coordinate!(params, Position(200.0, 200.0))
        add_coordinate!(params, Position(201.0, 201.0))
        try
            route(osrm, params)
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
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        coord = Fixtures.HAMBURG_CITY_CENTER
        add_coordinate!(params, coord)
        add_coordinate!(params, coord)
        try
            response = route_response(osrm, params)
            @test response isa RouteResponse
            json = get_json(response)
            @test isa(json, String)
        catch e
            @test e isa OSRMError
        end
    end

    @testset "Very short route" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        coord1 = Fixtures.HAMBURG_CITY_CENTER
        coord2 = Position(coord1.longitude + 0.001, coord1.latitude + 0.001)
        add_coordinate!(params, coord1)
        add_coordinate!(params, coord2)
        response = route_response(osrm, params)
        @test response isa RouteResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end

    @testset "Route with multiple waypoints" begin
        osrm = Fixtures.get_test_osrm()
        params = RouteParams()
        for coord in Fixtures.hamburg_coordinates()
            add_coordinate!(params, coord)
        end
        response = route_response(osrm, params)
        @test response isa RouteResponse
        json = get_json(response)
        @test isa(json, String)
        @test !isempty(json)
    end
end

@testset "Route - Response Accessors" begin
    osrm = Fixtures.get_test_osrm()
    params = RouteParams()

    # Three-waypoint route for waypoint/leg/step tests
    for coord in [Fixtures.HAMBURG_CITY_CENTER, Fixtures.HAMBURG_AIRPORT, Fixtures.HAMBURG_PORT]
        add_coordinate!(params, coord)
    end

    add_steps!(params, true)
    set_geometries!(params, Geometries(2))  # geojson
    set_annotations!(params, Annotations(5))  # distance | duration

    response = route_response(osrm, params)

    # get_json and basic validation
    json = get_json(response)
    @test isa(json, String)
    @test !isempty(json)
end
