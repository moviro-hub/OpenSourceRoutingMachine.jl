using Test
using OSRM_jll
using OpenSourceRoutingMachine

const Graph = OpenSourceRoutingMachine.Graph

@testset "Graph Helpers" begin
    lua_path = profile_lua_path(Profile.car)
    @test isfile(lua_path)
    @test endswith(lua_path, "car.lua")
    cmd = Graph.extract_cmd("/tmp/example.osm"; profile=Profile.car)
    @test cmd.exec[1] == OSRM_jll.osrm_extract_path
    @test cmd.exec[2] == "-p"
    @test cmd.exec[3] == lua_path
    @test cmd.exec[4] == "/tmp/example.osm"
end
