@enumx OutputFormat::Int begin
    json = 0
    # flatbuffers = 1 # not supported
end

@enumx Snapping::Int begin
    default = 0
    any = 1
end

@enumx Approach::Int begin
    curb = 0
    unrestricted = 1
    opposite = 2
end
