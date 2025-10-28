#!/usr/bin/env julia

# GUI launcher script for the Python Benchmarker
using Pkg
Pkg.activate(".")

include("src/PythonBenchmarker.jl")
using .PythonBenchmarker

# Check if GUI is available
if !PythonBenchmarker.GUI_AVAILABLE
    println("Error: GUI functionality requires Blink.jl")
    println("Please install it with: julia -e \"using Pkg; Pkg.add(\\\"Blink\\\")\"")
    exit(1)
end

# Launch the GUI
launch_gui()