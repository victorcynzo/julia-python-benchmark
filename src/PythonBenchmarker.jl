module PythonBenchmarker

using ArgParse
using BenchmarkTools
using CSV
using DataFrames
using JSON3
using Plots
using Statistics
using StatsBase
using Dates

# Try to load Blink for GUI functionality
const GUI_AVAILABLE = try
    using Blink
    true
catch
    println("Note: Blink.jl not available. GUI functionality disabled.")
    false
end

include("benchmark_runner.jl")
include("results_analyzer.jl")
include("reporter.jl")
include("cli.jl")

if GUI_AVAILABLE
    include("gui.jl")
    export launch_gui
end

export run_benchmark, BenchmarkConfig, BenchmarkResult

end # module