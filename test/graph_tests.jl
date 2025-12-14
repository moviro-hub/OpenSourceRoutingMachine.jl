using Test
using OpenSourceRoutingMachine.OSRM_jll: osrm_extract_path
using OpenSourceRoutingMachine.Graphs: Profile, PROFILE_CAR, profile_lua_path, extract_cmd

@testset "Graph Helpers" begin
    lua_path = profile_lua_path(PROFILE_CAR)
    @test isfile(lua_path)
    @test endswith(lua_path, "car.lua")
    cmd = extract_cmd("/tmp/example.osm", PROFILE_CAR)
    @test cmd.exec[1] == osrm_extract_path
    @test cmd.exec[2] == "-p"
    @test cmd.exec[3] == lua_path
    @test cmd.exec[4] == "/tmp/example.osm"
end
