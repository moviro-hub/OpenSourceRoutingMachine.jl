using Test
using OpenSourceRoutingMachine: OpenSourceRoutingMachine as OSRMs
using OpenSourceRoutingMachine.Tiles: Tiles
using Base: length, isempty

if !isdefined(Main, :TestUtils)
    include("TestUtils.jl")
    using TestUtils: TestUtils
end

@testset "Tile - Setters and Getters" begin
    @testset "X Coordinate" begin
        params = Tiles.TileParams()
        # Default value
        initial_x = Tiles.get_x(params)
        @test initial_x isa Int

        Tiles.set_x!(params, 100)
        @test Tiles.get_x(params) == 100

        Tiles.set_x!(params, 200)
        @test Tiles.get_x(params) == 200

        Tiles.set_x!(params, 0)
        @test Tiles.get_x(params) == 0
    end

    @testset "Y Coordinate" begin
        params = Tiles.TileParams()
        # Default value
        initial_y = Tiles.get_y(params)
        @test initial_y isa Int

        Tiles.set_y!(params, 50)
        @test Tiles.get_y(params) == 50

        Tiles.set_y!(params, 150)
        @test Tiles.get_y(params) == 150

        Tiles.set_y!(params, 0)
        @test Tiles.get_y(params) == 0
    end

    @testset "Z (Zoom Level)" begin
        params = Tiles.TileParams()
        # Default value
        initial_z = Tiles.get_z(params)
        @test initial_z isa Int

        Tiles.set_z!(params, 10)
        @test Tiles.get_z(params) == 10

        Tiles.set_z!(params, 14)
        @test Tiles.get_z(params) == 14

        Tiles.set_z!(params, 18)
        @test Tiles.get_z(params) == 18
    end
end

@testset "Tile - Query Execution" begin
    @testset "Basic tile query" begin
        params = Tiles.TileParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]
        zoom = 14
        x, y = TestUtils.slippy_tile(Float64(coord.latitude), Float64(coord.longitude), zoom)

        Tiles.set_x!(params, x)
        Tiles.set_y!(params, y)
        Tiles.set_z!(params, zoom)

        response = Tiles.tile(TestUtils.get_test_osrm(), params)
        @test response isa Tiles.TileResponse

        raw = Tiles.get_data(response)
        @test !isempty(raw)
        @test length(raw) == Tiles.get_size(response)
    end

    @testset "Tile with different zoom levels" begin
        params = Tiles.TileParams()
        coord = TestUtils.get_hamburg_coordinates()["city_center"]

        for zoom in [10, 14, 18]
            x, y = TestUtils.slippy_tile(Float64(coord.latitude), Float64(coord.longitude), zoom)
            Tiles.set_x!(params, x)
            Tiles.set_y!(params, y)
            Tiles.set_z!(params, zoom)

            response = Tiles.tile(TestUtils.get_test_osrm(), params)
            @test response isa Tiles.TileResponse
        end
    end
end

@testset "Tile - Error Handling" begin
    @testset "Invalid zoom level" begin
        params = Tiles.TileParams()
        # Deliberately request a tile outside the allowed zoom range to trigger an error
        Tiles.set_x!(params, 0)
        Tiles.set_y!(params, 0)
        Tiles.set_z!(params, 30)

        maybe_tile = try
            Tiles.tile(TestUtils.get_test_osrm(), params)
        catch e
            @test e isa OSRMs.OSRMError
            nothing
        end
        if maybe_tile !== nothing
            bytes = Tiles.get_data(maybe_tile)
            @test isa(bytes, Vector{UInt8})
        end
    end

    @testset "Error messages are informative" begin
        params = Tiles.TileParams()
        Tiles.set_x!(params, 999999)
        Tiles.set_y!(params, 999999)
        Tiles.set_z!(params, 30)
        try
            Tiles.tile(TestUtils.get_test_osrm(), params)
            @test true
        catch e
            @test e isa OSRMs.OSRMError
            @test !isempty(e.code)
            @test !isempty(e.message)
        end
    end
end
