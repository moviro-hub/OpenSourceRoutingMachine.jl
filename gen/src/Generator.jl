"""
    Generator

Module for generating Julia type definitions from FlatBuffers schema files.

Provides two entry points:
- [`download_flatbuffers`](@ref): Download `.fbs` schema files from the OSRM GitHub repository
- [`generate_julia_code`](@ref): Parse schemas and generate Julia code with dependency resolution
"""
module Generator

using Downloads

include("types.jl")
include("download.jl")
include("parsing.jl")
include("dependencies.jl")
include("generation.jl")

export download_flatbuffers, generate_julia_code

end # module Generator
