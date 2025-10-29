#!/usr/bin/env julia

# Simple precompilation test script
using Pkg
Pkg.activate(".")

include("src/PythonBenchmarker.jl")
using .PythonBenchmarker

# Just load the modules without running anything
println("Precompilation test completed successfully")