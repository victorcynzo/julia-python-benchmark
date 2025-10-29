#!/usr/bin/env julia

"""
Portable GUI launcher for Python Benchmarker
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

# Load the main module
try
    include(joinpath(SCRIPT_DIR, "src", "PythonBenchmarker.jl"))
    using .PythonBenchmarker
    
    # Check if GUI is available
    if !PythonBenchmarker.GUI_AVAILABLE
        println("Error: GUI functionality requires Blink.jl")
        println("Please install it with: julia -e \"using Pkg; Pkg.add(\\\"Blink\\\")\"")
        exit(1)
    end
    
    println("🚀 Starting Python Benchmarker GUI...")
    launch_gui()
    
catch e
    println("Error loading Python Benchmarker: $e")
    println("\nMake sure you have all dependencies installed:")
    println("julia -e \"using Pkg; Pkg.add([\\\"Blink\\\", \\\"PlotlyJS\\\", \\\"DataFrames\\\", \\\"Statistics\\\", \\\"JSON3\\\", \\\"CSV\\\", \\\"ArgParse\\\"])\"")
    exit(1)
end