"""
    deserialize(buffer::Vector{UInt8}) -> FBResult

Converts FlatBuffers binary data to a FBResult Julia object using FlatBuffers.deserialize.

# Arguments
- `buffer::Vector{UInt8}`: The FlatBuffers binary data

# Returns
- `FBResult`: The deserialized FBResult object

# Examples
```julia
using OpenSourceRoutingMachine.Routes

# Get FlatBuffers binary data from a route response
response = route_response(osrm, params)
if get_format(response) == OutputFormat(1)  # flatbuffers
    buffer = get_flatbuffer(response)
    fb_result = deserialize(buffer)
end
```
"""
function deserialize(buffer::Vector{UInt8})::FBResult
    if isempty(buffer)
        error("Empty buffer provided")
    end

    # Use FlatBuffers.deserialize to parse the buffer
    io = IOBuffer(buffer)
    result = FlatBuffers.deserialize(io, FBResult)

    # Check for errors
    if result.error
        if result.code !== nothing && result.code.message !== nothing
            error("OSRM Error: $(result.code.message)")
        else
            error("OSRM Error: Unknown error (error flag set but no error message)")
        end
    end

    # Return the full FBResult object (caller can access waypoints, routes, or table as needed)
    return result
end
