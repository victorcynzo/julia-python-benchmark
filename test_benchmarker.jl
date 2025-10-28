#!/usr/bin/env julia

# Test script to demonstrate the benchmarker functionality
using Pkg
Pkg.activate(".")

include("src/PythonBenchmarker.jl")
using .PythonBenchmarker

println("Testing Python Benchmarker...")

# Test with the example Python script
config = BenchmarkConfig(
    "example_python_script.py";
    iterations = 5,
    warmup_runs = 2,
    memory_tracking = true,
    python_args = ["25"]  # Fibonacci argument
)

try
    result = run_benchmark(config)
    
    # Print summary
    print_summary(result)
    
    # Export results
    export_to_json(result, "test_results.json")
    export_to_csv(result, "test_results.csv")
    
    # Generate plots
    create_performance_plots(result, "test_plots")
    
    println("\n✅ Test completed successfully!")
    println("Check test_results.json, test_results.csv, and test_plots/ for outputs")
    
catch e
    println("❌ Test failed: $e")
end