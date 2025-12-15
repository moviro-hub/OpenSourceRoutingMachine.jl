"""
    Generator

Module for generating Julia code from FlatBuffers schema files.

This module provides functionality to download FlatBuffers schema files from the OSRM
GitHub repository, parse `.fbs` files to extract enums, structs, and tables, map
FlatBuffers types to Julia equivalents, and generate Julia code with proper dependency
resolution.

The main entry points are:
- [`download_flatbuffers`](@ref): Download schema files from a GitHub repository
- [`generate_julia_code`](@ref): Generate Julia type definitions from FlatBuffers schemas
"""
module Generator

using Downloads

# Include all module files in dependency order
include("types.jl")
include("download.jl")
include("parsing.jl")
include("dependencies.jl")
include("generation.jl")

# Exports
export download_flatbuffers, generate_julia_code

end # module Generator
