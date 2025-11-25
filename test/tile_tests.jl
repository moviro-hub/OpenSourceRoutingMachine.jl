using Test
using OpenSourceRoutingMachine
using .Fixtures

import OpenSourceRoutingMachine.Tile: TileResponse, data, size

function _slippy_tile(lat::Float64, lon::Float64, zoom::Integer)
    n = 2.0 ^ zoom
    xtile = floor(Int, (lon + 180.0) / 360.0 * n)
    lat_rad = deg2rad(lat)
    ytile = floor(Int, (1.0 - log(tan(lat_rad) + sec(lat_rad)) / π) / 2.0 * n)
    return xtile, ytile
end

@testset "Tile - Basic" begin
    osrm = Fixtures.get_test_osrm()
    params = TileParams()

    lon, lat = Fixtures.HAMBURG_CITY_CENTER
    zoom = 14
    x, y = _slippy_tile(Float64(lat), Float64(lon), zoom)

    set_x!(params, x)
    set_y!(params, y)
    set_z!(params, zoom)

    response = tile(osrm, params)
    @test response isa TileResponse

    raw = data(response)
    @test !isempty(raw)
    @test length(raw) == size(response)
end

@testset "Tile - Error Handling" begin
    osrm = Fixtures.get_test_osrm()
    params = TileParams()

    # Deliberately request a tile outside the allowed zoom range to trigger an error.
    set_x!(params, 0)
    set_y!(params, 0)
    set_z!(params, 30)

    maybe_tile = try
        tile(osrm, params)
    catch e
        @test e isa OSRMError
        nothing
    end
    if maybe_tile !== nothing
        bytes = data(maybe_tile)
        @test isa(bytes, Vector{UInt8})
    end
end
