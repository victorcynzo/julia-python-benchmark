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

include("benchmark_runner.jl")
include("results_analyzer.jl")
include("reporter.jl")
include("cli.jl")

export run_benchmark, BenchmarkConfig, BenchmarkResult

end # module