"""
    download_flatbuffers(version::String; base_url::String, subdir::String, files::Vector{String}, output_dir::String) -> Bool

Download FlatBuffer schema files (.fbs) from the OSRM backend GitHub repository
for a specific version. Returns true if all downloads succeeded, false otherwise.

Arguments:
- version: OSRM version tag (e.g., "v6.0.0")
- base_url: Base URL for the GitHub repository (keyword argument)
- subdir: Subdirectory path in the repository (keyword argument)
- files: List of .fbs filenames to download (keyword argument)
- output_dir: Output directory for the downloaded files (keyword argument)
"""
function download_flatbuffers(version::String; base_url::String, subdir::String, files::Vector{String}, output_dir::String)::Bool
    # Create output directory if it doesn't exist
    mkpath(output_dir)

    # Download each file
    failed_files = String[]
    for file in files
        url = "$base_url/$version/$subdir/$file"
        output_path = joinpath(output_dir, file)

        try
            println("Downloading $file...")
            Downloads.download(url, output_path)
            println("  ✓ Successfully downloaded $file")
        catch e
            println("  ✗ Failed to download $file: $e")
            push!(failed_files, file)
        end
    end

    println()
    if isempty(failed_files)
        println("Successfully downloaded all $(length(files)) FlatBuffer files")
        return true
    else
        println("Warning: Failed to download $(length(failed_files)) file(s):")
        for file in failed_files
            println("  - $file")
        end
        return false
    end
end
