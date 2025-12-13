# FlatBuffers Type Generator

Tools for automatically generating Julia type definitions from OSRM's [FlatBuffers](https://flatbuffers.dev/) schema files. The OSRM backend uses FlatBuffers to serialize API responses, and this generator parses the `.fbs` schema files to produce equivalent Julia type definitions.

## Components

- **`Generator.jl`**: Main module that downloads schema files from the OSRM GitHub repository, parses `.fbs` files to extract enums/structs/tables, maps FlatBuffers types to Julia equivalents, and generates Julia code with proper dependency resolution.

- **`generate.jl`**: Convenience script that downloads schemas and generates `../src/types.jl`. Configured for OSRM `v6.0.0` by default; update `OSRM_VERSION` in the script for other versions.

## Usage

Run from this directory:

```bash
julia generate.jl
```

This downloads schema files (`fbresult.fbs`, `route.fbs`, `table.fbs`, `position.fbs`, `waypoint.fbs`) to `flatbuffers/`, parses them and their includes, and generates `../src/types.jl`.

## How It Works

1. **Download**: Fetches `.fbs` files from the OSRM repository at the specified version tag.
2. **Parse**: Extracts enums, structs, and tables, tracking include relationships.
3. **Generate**: Resolves dependencies, topologically sorts types, and generates Julia code with `@cenum` definitions, immutable structs, and mutable table structs.
4. **Output**: Writes generated code to `src/types.jl`.

## Updating for New Versions

1. Edit `OSRM_VERSION` in `generate.jl` (e.g., `"v6.1.0"`)
2. Run `julia generate.jl`
3. Review `src/types.jl` for breaking changes

The generator handles includes automatically and ensures types are properly referenced across files.
