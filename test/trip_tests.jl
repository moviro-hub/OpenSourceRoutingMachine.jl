using Test
using OpenSourceRoutingMachine: LatLon, OSRMError
using OpenSourceRoutingMachine.Trips:
    TripParams,
    TripResponse,
    add_coordinate!,
    add_roundtrip!,
    add_source!,
    add_destination!,
    add_waypoint!,
    clear_waypoints!,
    trip,
    get_distance,
    get_duration,
    get_waypoint_coordinate
using Base: C_NULL, length, isfinite
using .Fixtures

@testset "Trip - Basic" begin
    params = TripParams()
    @test params isa TripParams
    @test params.ptr != C_NULL

    osrm = Fixtures.get_test_osrm()
    for coord in Fixtures.hamburg_coordinates()
        add_coordinate!(params, coord)
    end

    response = trip(osrm, params)
    @test response isa TripResponse

    dist = try
        get_distance(response)
    catch e
        @test e isa OSRMError
        nothing
    end
    dur = try
        get_duration(response)
    catch e
        @test e isa OSRMError
        nothing
    end
    if dist !== nothing
        @test dist >= 0.0
    end
    if dur !== nothing
        @test dur >= 0.0
    end

    json_str = try
        as_json(response)
    catch e
        @test e isa OSRMError
        ""
    end
    if !isempty(json_str)
        @test isa(json_str, String)
        @test startswith(json_str, '{') || startswith(json_str, '[')
    end
end

@testset "Trip - Parameters" begin
    params = TripParams()
    add_roundtrip!(params, true)
    add_roundtrip!(params, false)
    add_source!(params, "first")
    add_destination!(params, "last")
    clear_waypoints!(params)
    add_waypoint!(params, 1)
    add_waypoint!(params, 1)

    osrm = Fixtures.get_test_osrm()
    for coord in Fixtures.hamburg_coordinates()
        add_coordinate!(params, coord)
    end

    response = trip(osrm, params)
    @test response isa TripResponse
end

@testset "Trip - Error Handling" begin
    osrm = Fixtures.get_test_osrm()
    params = TripParams()
    add_coordinate!(params, LatLon(0.0, 0.0))
    add_coordinate!(params, LatLon(1.0, 1.0))

    maybe_response = try
        trip(osrm, params)
    catch e
        @test e isa OSRMError
        nothing
    end
    if maybe_response !== nothing
        @test maybe_response isa TripResponse
    end
end
