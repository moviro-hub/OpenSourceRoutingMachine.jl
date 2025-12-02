using Pkg
Pkg.activate(@__DIR__)

using Documenter
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Graphs
using OpenSourceRoutingMachine.Nearests
using OpenSourceRoutingMachine.Routes
using OpenSourceRoutingMachine.Matches
using OpenSourceRoutingMachine.Tables
using OpenSourceRoutingMachine.Trips
using OpenSourceRoutingMachine.Tiles

DocMeta.setdocmeta!(
    OpenSourceRoutingMachine,
    :DocTestSetup,
    :(using OpenSourceRoutingMachine);
    recursive = true,
)

makedocs(;
    sitename = "OpenSourceRoutingMachine.jl",
    modules = [
        OpenSourceRoutingMachine,
        OpenSourceRoutingMachine.Graphs,
        OpenSourceRoutingMachine.Nearests,
        OpenSourceRoutingMachine.Routes,
        OpenSourceRoutingMachine.Matches,
        OpenSourceRoutingMachine.Tables,
        OpenSourceRoutingMachine.Trips,
        OpenSourceRoutingMachine.Tiles,
    ],
    format = Documenter.HTML(),
    checkdocs = :none,  # Disable strict docstring checking for minimal docs
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
        "API Reference" => [
            "api/core.md",
            "api/graphs.md",
            "api/nearest.md",
            "api/route.md",
            "api/match.md",
            "api/table.md",
            "api/trip.md",
            "api/tile.md",
        ],
    ],
)

deploydocs(;
    repo = "github.com/moviro-hub/OpenSourceRoutingMachine.jl.git",
    devbranch = "main",
)
