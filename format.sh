#!/bin/bash
# Simple script to format Julia files using Runic.jl
# Usage: ./format.sh [path_to_julia_project]

PROJECT_PATH=${1:-"$(pwd)"}
echo "Formatting Julia files in: $PROJECT_PATH"

# Change to the formatter directory
FORMATTER_DIR=$(mktemp -d)
cd "$FORMATTER_DIR"

# Run Runic on all Julia files in the specified project
julia --project=. -e "
# set up the temporary environment
using Pkg
Pkg.add(\"Runic\")
Pkg.instantiate()

# Run the formatter
using Runic: Runic

# Find all Julia files in the project directory and subdirectories
jl_files = String[]
for (root, dirs, files) in walkdir(\"$PROJECT_PATH\")
    for file in files
        if endswith(file, \".jl\")
            file_path = joinpath(root, file)
            push!(jl_files, file_path)
        end
    end
end
for file in jl_files
    println(\"Formatting: \$file\")
    try
        Runic.format_file(file; inplace=true)
        println(\"✓ Formatted: \$file\")
    catch e
        println(\"✗ Error formatting \$file: \$e\")
    end
end
"

# Clean up the temporary directory
rm -rf "$FORMATTER_DIR"

echo "Formatting complete!"
