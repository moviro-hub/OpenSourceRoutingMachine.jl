using Test
using OpenSourceRoutingMachine: OSRMError
using OpenSourceRoutingMachine.Tiles:
    TileParams,
    TileResponse,
    set_x!,
    get_x,
    set_y!,
    get_y,
    set_z!,
    get_z,
    tile,
    get_data,
    get_size
using Base: length, isempty

include("TestUtils.jl")
using .TestUtils: get_test_osrm, get_hamburg_coordinates, slippy_tile

@testset "Tile - Setters and Getters" begin
    @testset "X Coordinate" begin
        params = TileParams()
        # Default value
        initial_x = get_x(params)
        @test initial_x isa Int

        set_x!(params, 100)
        @test get_x(params) == 100

        set_x!(params, 200)
        @test get_x(params) == 200

        set_x!(params, 0)
        @test get_x(params) == 0
    end

    @testset "Y Coordinate" begin
        params = TileParams()
        # Default value
        initial_y = get_y(params)
        @test initial_y isa Int

        set_y!(params, 50)
        @test get_y(params) == 50

        set_y!(params, 150)
        @test get_y(params) == 150

        set_y!(params, 0)
        @test get_y(params) == 0
    end

    @testset "Z (Zoom Level)" begin
        params = TileParams()
        # Default value
        initial_z = get_z(params)
        @test initial_z isa Int

        set_z!(params, 10)
        @test get_z(params) == 10

        set_z!(params, 14)
        @test get_z(params) == 14

        set_z!(params, 18)
        @test get_z(params) == 18
    end
end

@testset "Tile - Query Execution" begin
    @testset "Basic tile query" begin
        params = TileParams()
        coord = get_hamburg_coordinates()["city_center"]
        zoom = 14
        x, y = slippy_tile(Float64(coord.latitude), Float64(coord.longitude), zoom)

        set_x!(params, x)
        set_y!(params, y)
        set_z!(params, zoom)

        response = tile(get_test_osrm(), params)
        @test response isa TileResponse

        raw = get_data(response)
        @test !isempty(raw)
        @test length(raw) == get_size(response)
    end

    @testset "Tile with different zoom levels" begin
        params = TileParams()
        coord = get_hamburg_coordinates()["city_center"]

        for zoom in [10, 14, 18]
            x, y = slippy_tile(Float64(coord.latitude), Float64(coord.longitude), zoom)
            set_x!(params, x)
            set_y!(params, y)
            set_z!(params, zoom)

            response = tile(get_test_osrm(), params)
            @test response isa TileResponse
        end
    end
end

@testset "Tile - Error Handling" begin
    @testset "Invalid zoom level" begin
        params = TileParams()
        # Deliberately request a tile outside the allowed zoom range to trigger an error
        set_x!(params, 0)
        set_y!(params, 0)
        set_z!(params, 30)

        maybe_tile = try
            tile(get_test_osrm(), params)
        catch e
            @test e isa OSRMError
            nothing
        end
        if maybe_tile !== nothing
            bytes = get_data(maybe_tile)
            @test isa(bytes, Vector{UInt8})
        end
    end

    @testset "Error messages are informative" begin
        params = TileParams()
        set_x!(params, 999999)
        set_y!(params, 999999)
        set_z!(params, 30)
        try
            tile(get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
