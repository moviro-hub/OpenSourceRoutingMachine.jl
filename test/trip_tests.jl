using Test
using OpenSourceRoutingMachine: Position, OSRMError
using OpenSourceRoutingMachine.Trips:
    TripParams,
    TripResponse,
    TripSource,
    TripDestination,
    TRIP_SOURCE_FIRST,
    TRIP_DESTINATION_LAST,
    add_coordinate!,
    set_roundtrip!,
    set_source!,
    set_destination!,
    add_waypoint!,
    clear_waypoints!,
    trip,
    trip_response
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

    response = trip_response(osrm, params)
    @test response isa TripResponse
end

@testset "Trip - Parameters" begin
    params = TripParams()
    set_roundtrip!(params, true)
    set_roundtrip!(params, false)
    set_source!(params, TRIP_SOURCE_FIRST)
    set_destination!(params, TRIP_DESTINATION_LAST)
    clear_waypoints!(params)
    add_waypoint!(params, 1)
    add_waypoint!(params, 1)

    osrm = Fixtures.get_test_osrm()
    for coord in Fixtures.hamburg_coordinates()
        add_coordinate!(params, coord)
    end

    response = trip_response(osrm, params)
    @test response isa TripResponse
end

@testset "Trip - Error Handling" begin
    osrm = Fixtures.get_test_osrm()
    params = TripParams()
    add_coordinate!(params, Position(0.0, 0.0))
    add_coordinate!(params, Position(1.0, 1.0))

    maybe_response = try
        trip_response(osrm, params)
    catch e
        @test e isa OSRMError
        nothing
    end
    if maybe_response !== nothing
        @test maybe_response isa TripResponse
    end
end
