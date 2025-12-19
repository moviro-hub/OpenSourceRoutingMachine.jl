using Pkg
Pkg.activate(@__DIR__)

using Documenter
using OpenSourceRoutingMachine
using OpenSourceRoutingMachine.Graph
using OpenSourceRoutingMachine.Nearest
using OpenSourceRoutingMachine.Route
using OpenSourceRoutingMachine.Match
using OpenSourceRoutingMachine.Table
using OpenSourceRoutingMachine.Trip
using OpenSourceRoutingMachine.Tile

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
        OpenSourceRoutingMachine.Graph,
        OpenSourceRoutingMachine.Nearest,
        OpenSourceRoutingMachine.Route,
        OpenSourceRoutingMachine.Match,
        OpenSourceRoutingMachine.Table,
        OpenSourceRoutingMachine.Trip,
        OpenSourceRoutingMachine.Tile,
    ],
    format = Documenter.HTML(),
    checkdocs = :none,  # Disable strict docstring checking for minimal docs
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md",
        "API Reference" => [
            "api/core.md",
            "api/graph.md",
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
