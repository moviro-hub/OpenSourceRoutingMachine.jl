#!/usr/bin/env julia

include("src/Generator.jl")
using .Generator: download_flatbuffers, generate_julia_code

# --- Configuration ---
const OSRM_VERSION = "v26.4.0"
const BASE_URL = "https://raw.githubusercontent.com/Project-OSRM/osrm-backend"
const FBS_SUBDIR = "include/engine/api/flatbuffers"
const DOWNLOAD_FILES = [
    "fbresult.fbs",
    "position.fbs",
    "route.fbs",
    "table.fbs",
    "waypoint.fbs",
]

# --- Paths (relative to this script) ---
const SCRIPT_DIR = @__DIR__
const FLATBUFFERS_DIR = joinpath(SCRIPT_DIR, "flatbuffers")
const SRC_DIR = joinpath(SCRIPT_DIR, "..", "src")
const INPUT_FILE = joinpath(FLATBUFFERS_DIR, "fbresult.fbs")
const OUTPUT_FILE = joinpath(SRC_DIR, "types.jl")

# --- Step 1: Download ---
println("Step 1: Downloading FlatBuffer schema files...")
println("-"^60)
if !download_flatbuffers(OSRM_VERSION; base_url = BASE_URL, subdir = FBS_SUBDIR, files = DOWNLOAD_FILES, output_dir = FLATBUFFERS_DIR)
    println("\nError: Failed to download some FlatBuffer files")
    exit(1)
end

# --- Step 2: Generate ---
println("Step 2: Generating Julia code...")
println("-"^60)
if !generate_julia_code(INPUT_FILE, OUTPUT_FILE)
    println("\nError: Failed to generate Julia code")
    exit(1)
end

println("="^60)
println("Done.")
println("="^60)
