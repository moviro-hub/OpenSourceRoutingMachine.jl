# FlatBuffers Type Generator

Generates Julia type definitions from OSRM's [FlatBuffers](https://flatbuffers.dev/) schema files. The OSRM backend uses FlatBuffers to serialize API responses; this generator parses the `.fbs` schemas and produces equivalent Julia types for use with `FlatBuffers.jl`.

## Usage

```bash
cd gen
julia generate.jl
```

This downloads schema files to `flatbuffers/`, parses them, and generates `../src/types.jl`.

## Structure

| File | Responsibility |
|------|---------------|
| `generate.jl` | Entry script — configuration and orchestration |
| `src/Generator.jl` | Module wrapper |
| `src/types.jl` | Type maps (FBS -> Julia) and IR structs |
| `src/download.jl` | Download `.fbs` files from GitHub |
| `src/parsing.jl` | Parse `.fbs` files into IR |
| `src/dependencies.jl` | Topological sorting of type definitions |
| `src/generation.jl` | Emit Julia source code from IR |

## Updating for a new OSRM version

1. Edit `OSRM_VERSION` in `generate.jl` (currently `v26.4.0`)
2. Run `julia generate.jl`
3. Review `src/types.jl` for breaking changes
