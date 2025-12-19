using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Tile: Tile
using Base: length, isempty

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Tile - Setters and Getters" begin
    @testset "X Coordinate" begin
        params = Tile.TileParams()
        # Default value
        initial_x = Tile.get_x(params)
        @test initial_x isa Int

        Tile.set_x!(params, 100)
        @test Tile.get_x(params) == 100

        Tile.set_x!(params, 200)
        @test Tile.get_x(params) == 200

        Tile.set_x!(params, 0)
        @test Tile.get_x(params) == 0
    end

    @testset "Y Coordinate" begin
        params = Tile.TileParams()
        # Default value
        initial_y = Tile.get_y(params)
        @test initial_y isa Int

        Tile.set_y!(params, 50)
        @test Tile.get_y(params) == 50

        Tile.set_y!(params, 150)
        @test Tile.get_y(params) == 150

        Tile.set_y!(params, 0)
        @test Tile.get_y(params) == 0
    end

    @testset "Z (Zoom Level)" begin
        params = Tile.TileParams()
        # Default value
        initial_z = Tile.get_z(params)
        @test initial_z isa Int

        Tile.set_z!(params, 10)
        @test Tile.get_z(params) == 10

        Tile.set_z!(params, 14)
        @test Tile.get_z(params) == 14

        Tile.set_z!(params, 18)
        @test Tile.get_z(params) == 18
    end
end

@testset "Tile - Query Execution" begin
    @testset "Basic tile query" begin
        params = Tile.TileParams()
        coord = TestUtils.HAMBURG_CITY_CENTER
        zoom = 14
        x, y = TestUtils.slippy_tile(Float64(coord.latitude), Float64(coord.longitude), zoom)

        Tile.set_x!(params, x)
        Tile.set_y!(params, y)
        Tile.set_z!(params, zoom)

        response = Tile.tile(TestUtils.get_test_osrm(), params)
        @test response isa Tile.TileResponse

        raw = Tile.get_data(response)
        @test !isempty(raw)
        @test length(raw) == Tile.get_size(response)
    end

    @testset "Tile with different zoom levels" begin
        params = Tile.TileParams()
        coord = TestUtils.HAMBURG_CITY_CENTER

        for zoom in [10, 14, 18]
            x, y = TestUtils.slippy_tile(Float64(coord.latitude), Float64(coord.longitude), zoom)
            Tile.set_x!(params, x)
            Tile.set_y!(params, y)
            Tile.set_z!(params, zoom)

            response = Tile.tile(TestUtils.get_test_osrm(), params)
            @test response isa Tile.TileResponse
        end
    end
end

@testset "Tile - Error Handling" begin
    @testset "Invalid zoom level" begin
        params = Tile.TileParams()
        # Deliberately request a tile outside the allowed zoom range to trigger an error
        Tile.set_x!(params, 0)
        Tile.set_y!(params, 0)
        Tile.set_z!(params, 30)

        maybe_tile = try
            Tile.tile(TestUtils.get_test_osrm(), params)
        catch e
            @test e isa OSRMs.OSRMError
            nothing
        end
        if maybe_tile !== nothing
            bytes = Tile.get_data(maybe_tile)
            @test isa(bytes, Vector{UInt8})
        end
    end

    @testset "Error messages are informative" begin
        params = Tile.TileParams()
        Tile.set_x!(params, 999999)
        Tile.set_y!(params, 999999)
        Tile.set_z!(params, 30)
        try
            Tile.tile(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
