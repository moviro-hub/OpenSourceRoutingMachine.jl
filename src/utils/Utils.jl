module Utils

using ..OpenSourceRoutingMachine: libosrmc

export
    OSRMError,
    check_error,
    take_error!,
    with_error,
    error_pointer,
    as_string,
    finalize,
    as_cstring,
    as_cstring_or_null,
    as_cint,
    normalize_enum,
    to_cint

include("error.jl")
include("helpers.jl")
include("enums.jl")

end # module Utils
