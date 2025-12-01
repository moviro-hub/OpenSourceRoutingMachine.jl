# Core API

Core types, configuration, and utilities.

## Types

```@autodocs
Modules = [OpenSourceRoutingMachine]
Pages = ["types.jl", "main.jl", "OpenSourceRoutingMachine.jl"]
Order = [:type, :constant]
```

## Configuration Functions

```@autodocs
Modules = [OpenSourceRoutingMachine]
Pages = ["main.jl"]
Filter = t -> startswith(string(t), "set_") || startswith(string(t), "disable_") || startswith(string(t), "clear_")
Order = [:function]
```

## Version and Compatibility

```@autodocs
Modules = [OpenSourceRoutingMachine]
Pages = ["OpenSourceRoutingMachine.jl"]
Filter = t -> t === get_version || t === is_abi_compatible
```
