#!/usr/bin/env julia

# Main executable script for the Python Benchmarker
using Pkg
Pkg.activate(".")

include("src/PythonBenchmarker.jl")
using .PythonBenchmarker

# Run the CLI
PythonBenchmarker.main()