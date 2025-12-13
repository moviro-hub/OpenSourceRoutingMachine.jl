#!/usr/bin/env julia

include("src/Generator.jl")
using .Generator: download_flatbuffers, generate_julia_code

# Configuration constants
const OSRM_VERSION = "v6.0.0"

const BASE_URL = "https://raw.githubusercontent.com/Project-OSRM/osrm-backend"
const FBS_SUBDIR = "include/engine/api/flatbuffers"
const DOWNLOAD_FILES = [
    "fbresult.fbs",
    "position.fbs",
    "route.fbs",
    "table.fbs",
    "waypoint.fbs",
]

# Path constants relative to script location
const SCRIPT_DIR = @__DIR__
const FLATBUFFERS_DIR = joinpath(SCRIPT_DIR, "flatbuffers")
const SRC_DIR = joinpath(SCRIPT_DIR, "..", "src")


const INPUT_FILE = joinpath(FLATBUFFERS_DIR, "fbresult.fbs")
const OUTPUT_FILE = joinpath(SRC_DIR, "types.jl")

# Step 1: Download flatbuffer files
println("Step 1: Downloading FlatBuffer schema files...")
println("-"^60)
success = download_flatbuffers(OSRM_VERSION; base_url = BASE_URL, subdir = FBS_SUBDIR, files = DOWNLOAD_FILES, output_dir = FLATBUFFERS_DIR)
if !success
    println()
    println("Error: Failed to download some FlatBuffer files")
end

# Step 2: Generate Julia code
println("Step 2: Generating Julia code...")
println("-"^60)
success = generate_julia_code(INPUT_FILE, OUTPUT_FILE)
if !success
    println()
    println("Error: Failed to generate Julia code")
end

println("="^60)
println("Successfully completed all steps!")
println("="^60)
