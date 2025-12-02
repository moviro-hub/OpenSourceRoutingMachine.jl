# OpenSourceRoutingMachine.jl

A Julia wrapper for OSRM (Open Source Routing Machine), providing high-performance routing, matching, and geospatial analysis capabilities directly in Julia.
Being a thin wrapper around OSRM, it might not provide the most ergonomic API, which might be established in a separate package at one point.

## Features

- **Graph Building**: Build and customize OSRM graphs (MLD and CH algorithms)
- **Nearest Service**: Find the nearest road segment to a point
- **Route Service**: Calculate routes between multiple waypoints
- **Match Service**: Map GPS traces to road networks
- **Table Service**: Compute distance/duration matrices
- **Trip Service**: Solve traveling salesman problems
- **Tile Service**: Generate vector tiles for visualization

## Installation

```julia
using Pkg
Pkg.add("OpenSourceRoutingMachine", url="https://github.com/moviro-hub/OpenSourceRoutingMachine.jl")
```

See the `Examples` section for end-to-end usage patterns.

## API Reference

```@contents
Pages = [
    "api/core.md",
    "api/graphs.md",
    "api/nearest.md",
    "api/route.md",
    "api/match.md",
    "api/table.md",
    "api/trip.md",
    "api/tile.md",
]
```
