#!/usr/bin/env julia

"""
Portable CLI launcher for Python Benchmarker
This script can be copied to any folder and run independently
"""

# Get the directory where this script is located
const SCRIPT_DIR = dirname(abspath(PROGRAM_FILE))

# Add the source directory to the load path
push!(LOAD_PATH, joinpath(SCRIPT_DIR, "src"))

# Try to activate the project environment if available
try
    using Pkg
    if isfile(joinpath(SCRIPT_DIR, "Project.toml"))
        Pkg.activate(SCRIPT_DIR)
    end
catch
    println("Warning: Could not activate project environment")
end

# Load the main module and run CLI
try
    include(joinpath(SCRIPT_DIR, "src", "PythonBenchmarker.jl"))
    using .PythonBenchmarker
    
    # Run the CLI with command line arguments
    main()
    
catch e
    println("Error loading Python Benchmarker: $e")
    println("\nMake sure you have all dependencies installed:")
    println("julia -e \"using Pkg; Pkg.add([\\\"PlotlyJS\\\", \\\"DataFrames\\\", \\\"Statistics\\\", \\\"JSON3\\\", \\\"CSV\\\", \\\"ArgParse\\\"])\"")
    exit(1)
end