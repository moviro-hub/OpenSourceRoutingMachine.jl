# Agent Guidelines for Julia Development

Guidelines for AI agents and humans working on this codebase.

## At a Glance

- Ask rather than guess; clarify before coding.
- One focused change at a time (< 100 lines).
- Minimal code; comments explain why, not what.
- Public APIs: typed, stable, documented.
- Type stability and low allocations in hot paths.
- Run Runic and tests; keep CI green.
- Tests cover all lines and branches of public APIs.
- Prefer composition and parametric types; avoid abstract fields.
- Use explicit imports and qualified calls.
- Stream large data; avoid shared mutable state across threads.

## Critical Principles

- Ask Rather Than Guess:
  - Clarify requirements, edge cases, success criteria before coding.
  - Propose options and trade-offs; confirm ambiguities first.
- Minimal Code:
  - Keep code self-explanatory; comments only for rationale, edge cases, or workarounds.
- One Change at a Time:
  - Single concern per edit; keep diffs small and reviewable.
- Human Changes Precedence:
  - Respect human edits unless they contradict tests/specs. If reverting, justify briefly.

## Daily Workflow

- Run Runic locally; fix formatting:
  - Use the `format.sh` script in the root of the project to format the code.
- Run tests; ensure changed public APIs have complete line/branch coverage.
- Keep CI green (tests, coverage, docs; optional JET).
- Prefer commands in the project environment:
  - `julia --project=. -e 'using Pkg; Pkg.test()'`

## API Design

- Public APIs: simple, stable, documented; consistent return types.
- Internal implementations may change; document breaking changes; prefer deprecations.
- Maintain backward compatibility where possible; provide migration paths.

## Julia Style

- Function length target: ~25 lines; refactor when growing beyond ~35–50.
- Naming:
  - Functions: `snake_case`; mutating `!`; predicates `is...`.
  - Types/Modules: `PascalCase`; Constants: `SCREAMING_SNAKE_CASE`; Type params: single uppercase.
- Formatting:
  - 4 spaces indentation; keep lines under ~92 chars where reasonable.
  - Spaces around binary ops; trailing commas in multi-line lists.
- Documentation:
  - Keep simple and clean. Docstring only for exported or non-obvious functions.
  - Minimal runnable examples; avoid heavy formatting.

## Type System

- Public APIs: annotate argument and return types.
- Prefer parametric types over abstract-typed fields.
- Use small `Union`s for optional values (e.g., `Union{T,Nothing}`).
- Default to immutable types; use `mutable struct` only when state must change.
- Constructors:
  - Light validation in inner constructors; use outer constructors to reduce duplication.

## Function Design

- Signature order: required → optional → keyword.
- Use keyword args for 3+ optional parameters.
- Prefer pure functions; document side effects explicitly.
- Keep return types consistent within a public API.

## Performance

- Choose array types appropriately:
  - `StaticArrays` for small fixed-size data; regular `Vector/Array` otherwise.
- Allocation awareness:
  - Preallocate; use views; avoid globals in hot paths (use `Ref` or pass state).
- Type stability:
  - Avoid `Any`; prefer inference-friendly patterns; use `@code_warntype` when needed.
- Broadcasting:
  - Use dot syntax for element-wise ops; loops are fine when clearer.
- Internal algorithm optimization:
  - Profile first; consider `@inline` only for proven tiny hot functions.
  - Favor SIMD-friendly loops; access memory sequentially; minimize indirection.

## Concurrency and IO

- Document thread-safety assumptions.
- Avoid shared mutable state; if needed, synchronize minimally.
- Use `Threads.@threads` for independent CPU work; async IO for external waits.
- Stream large files; preallocate buffers; close resources via `do`-blocks.
- Use `Channel{T}(capacity)` for backpressure in pipelines.

## Error Handling

- Use specific exceptions (`ArgumentError`, `DomainError`, `BoundsError`, etc.).
- Validate inputs in public APIs; fail fast with actionable messages.
- Use `@assert` for internal invariants that should never fail.

## Design Patterns

- Prefer composition over inheritance.
- Use multiple dispatch instead of string-based factories.
- Extract reusable logic to avoid repetition (DRY).

## Engineering Practices

- Testing:
  - Execute every line; cover all branches (normal, error, early return).
  - Exported APIs must have comprehensive tests.
- CI and Automation:
  - Test on supported Julia versions (e.g., 1.10/LTS), collect coverage, run doctests, build docs.
- Formatter and Static Analysis:
  - Always run Runic. Optionally run JET in CI for hot paths.

## Imports and Dependencies

- Always run in the project environment (`--project=`.).
- Minimize dependencies; pin versions; declare Julia compat bounds.
- Use explicit `using` imports; prefer qualified calls.
- Use `import` only to extend external methods.

## Documentation Policy

- Use Documenter.jl for public API docs; require doctests for exported APIs.
- Build docs in CI to catch link/format issues.

## Logging

- Use `@info`, `@warn`, `@error` with context via keyword args.
- `@debug` gated by a `debugging()` function that defaults to `false`.

## Code Organization

- Group related functionality; keep public API separated and explicitly exported.
- Export only stable public API; keep internal functions unexported or namespaced.
- Suggested module structure:
  - Internal types/helpers/algorithms → include internally.
  - Public API in a separate file with exports.

## Service Patterns (if applicable)

- Externalize and validate config; separate init/runtime.
- Ensure cleanup; handle errors without crashing; implement graceful shutdown.

## Code Review Checklist (short)

- Intent clarified; minimal code; single concern; small diff.
- Public API separated, typed, documented, and backward compatible (or deprecated).
- Reasonable function length; consistent returns; side effects documented.
- Naming/formatting follow conventions.
- No abstract-typed fields; type stability in hot paths.
- Appropriate exceptions and validations with clear messages.
- Tests cover all lines and branches of changed public APIs.
- Explicit imports; clear organization; CI covers tests, coverage, docs.

## Summary

- Ask first. Keep code minimal. Make small, focused edits.
- Document and test public APIs thoroughly.
- Favor composition, parametric types, type stability, and streaming IO.
- Keep the repo formatted, tested, and green.
