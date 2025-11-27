function contract_cmd(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[],
    )
    args = String["$(osrm_base).osrm"]
    append!(args, extra_args)
    return command_with_args(OSRM_jll.osrm_contract(), args)
end

"""
    contract(osrm_base; extra_args=String[])

Wraps `osrm-contract` so CH pipelines can be triggered from Julia without
invoking shell scripts manually.
"""
function contract(
        osrm_base::AbstractString;
        extra_args::Vector{String} = String[],
    )
    cmd = contract_cmd(osrm_base; extra_args = extra_args)
    run_or_throw(cmd)
end
