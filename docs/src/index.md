# OpenSourceRoutingMachine.jl

A thin Julia wrapper for [OSRM](https://project-osrm.org/) (Open Source Routing Machine), a high-performance routing engine for road networks.
Use it to build routing graphs from OpenStreetMap data and query them for routes, duration/distance matrices, map matching, and more — all from within Julia.

## Compatibility

- **Julia**: ≥ 1.11
- **OSRM**: v26.4.0 (bundled via [OSRM_jll](https://github.com/JuliaBinaryWrappers/OSRM_jll.jl) and [libosrmc_jll](https://github.com/JuliaBinaryWrappers/libosrmc_jll.jl))
- **Platforms**: Linux (x86_64), macOS (x86_64, aarch64). Windows support is planned.

## Modules

The package structure consists of a core module and several submodules.

The core module `OpenSourceRoutingMachine` provides the constructor `OSRM` for creating an OSRM instance and setter and getter functions for basic configuration.

The rest of the functionality is organized in submodules with the following features:

- **Graph**: Builds OSRM graphs from OpenStreetMap data
- **Nearest**: Find the nearest waypoint in a road network for a given position
- **Route**: Find a route between waypoints containing detailed information
- **Table**: Find distance/duration matrices between multiple source and destination waypoints
- **Match**: Find a route by map matching noisy GPS traces to a road network
- **Trip**: Find a route by solving the traveling salesman problem
- **Tile**: Retrieve road network geometry as vector tiles

All modules expose the full configuration and parameter handling API of OSRM through setter and getter functions, providing fine-grained control over query behavior.

All query modules (Nearest, Route, Table, Match, Trip) return by default an object whose types are auto-generated (see `gen/generate.jl`) from OSRM's FlatBuffers schema files. Alternatively, one can receive the binary FlatBuffers response directly.

The Tile module is the exception — it returns road network geometry in MVT format (Mapbox Vector Tiles).

## Installation

```julia
using Pkg
Pkg.add("OpenSourceRoutingMachine")
```

See the [Examples](@ref) section for end-to-end usage patterns.

## API Reference

```@contents
Pages = [
    "api/core.md",
    "api/graph.md",
    "api/nearest.md",
    "api/route.md",
    "api/match.md",
    "api/table.md",
    "api/trip.md",
    "api/tile.md",
]
```
