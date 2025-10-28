using CSV
using DataFrames
using JSON3
using Plots

function print_summary(result::BenchmarkResult)
    """Print benchmark results summary to console"""
    
    println("\n" * "="^60)
    println("BENCHMARK RESULTS SUMMARY")
    println("="^60)
    println("File: $(result.config.python_file)")
    println("Timestamp: $(result.timestamp)")
    println("Successful runs: $(result.success_count)/$(result.config.iterations)")
    
    if result.success_count > 0
        println("\nTIMING RESULTS:")
        println("  Mean:     $(round(result.mean_time, digits=4))s")
        println("  Median:   $(round(result.median_time, digits=4))s")
        println("  Std Dev:  $(round(result.std_time, digits=4))s")
        println("  Min:      $(round(result.min_time, digits=4))s")
        println("  Max:      $(round(result.max_time, digits=4))s")
        
        println("\nPERCENTILES:")
        for (p, val) in sort(collect(result.percentiles))
            println("  $(p)th:     $(round(val, digits=4))s")
        end
        
        if result.peak_memory > 0
            println("\nMEMORY USAGE:")
            println("  Mean:     $(round(result.mean_memory/1024/1024, digits=2)) MB")
            println("  Peak:     $(round(result.peak_memory/1024/1024, digits=2)) MB")
        end
        
        # Stability analysis
        stability = calculate_stability_metrics(result)
        println("\nSTABILITY ANALYSIS:")
        println("  Coefficient of Variation: $(round(stability.coefficient_of_variation*100, digits=2))%")
        println("  Outliers: $(stability.outlier_count) ($(round(stability.outlier_percentage, digits=1))%)")
        println("  Stability Rating: $(stability.stability_rating)")
    end
    
    if !isempty(result.failed_runs)
        println("\nFAILED RUNS:")
        for failure in result.failed_runs
            println("  $failure")
        end
    end
    
    println("="^60)
end

function export_to_csv(result::BenchmarkResult, filename::String)
    """Export detailed results to CSV"""
    
    # Create DataFrame with all run data
    df = DataFrame(
        run_number = 1:length(result.execution_times),
        execution_time = result.execution_times,
        memory_usage = length(result.memory_usage) == length(result.execution_times) ? 
                      result.memory_usage : fill(0, length(result.execution_times))
    )
    
    CSV.write(filename, df)
    println("Detailed results exported to: $filename")
end

function export_to_json(result::BenchmarkResult, filename::String)
    """Export complete results to JSON"""
    
    # Convert result to dictionary for JSON serialization
    result_dict = Dict(
        "config" => Dict(
            "python_file" => result.config.python_file,
            "iterations" => result.config.iterations,
            "warmup_runs" => result.config.warmup_runs,
            "timeout_seconds" => result.config.timeout_seconds,
            "memory_tracking" => result.config.memory_tracking,
            "python_args" => result.config.python_args
        ),
        "results" => Dict(
            "timestamp" => string(result.timestamp),
            "success_count" => result.success_count,
            "execution_times" => result.execution_times,
            "memory_usage" => result.memory_usage,
            "failed_runs" => result.failed_runs,
            "statistics" => Dict(
                "mean_time" => result.mean_time,
                "median_time" => result.median_time,
                "std_time" => result.std_time,
                "min_time" => result.min_time,
                "max_time" => result.max_time,
                "percentiles" => result.percentiles,
                "mean_memory" => result.mean_memory,
                "peak_memory" => result.peak_memory
            )
        )
    )
    
    JSON3.write(filename, result_dict)
    println("Complete results exported to: $filename")
endfun
ction create_performance_plots(result::BenchmarkResult, output_dir::String="plots")
    """Generate performance visualization plots"""
    
    if !isdir(output_dir)
        mkdir(output_dir)
    end
    
    # Execution time distribution
    p1 = histogram(result.execution_times, 
                   title="Execution Time Distribution",
                   xlabel="Time (seconds)",
                   ylabel="Frequency",
                   bins=min(20, length(result.execution_times)÷2))
    
    savefig(p1, joinpath(output_dir, "time_distribution.png"))
    
    # Time series plot
    p2 = plot(1:length(result.execution_times), result.execution_times,
              title="Execution Time Series",
              xlabel="Run Number",
              ylabel="Time (seconds)",
              marker=:circle,
              linewidth=2)
    
    # Add mean line
    hline!([result.mean_time], label="Mean", linestyle=:dash, linewidth=2)
    
    savefig(p2, joinpath(output_dir, "time_series.png"))
    
    # Box plot for quartiles
    p3 = boxplot([result.execution_times], 
                 title="Execution Time Box Plot",
                 ylabel="Time (seconds)",
                 legend=false)
    
    savefig(p3, joinpath(output_dir, "box_plot.png"))
    
    # Memory usage if available
    if length(result.memory_usage) > 0 && any(x -> x > 0, result.memory_usage)
        memory_mb = result.memory_usage ./ (1024 * 1024)
        
        p4 = plot(1:length(memory_mb), memory_mb,
                  title="Memory Usage Over Time",
                  xlabel="Run Number",
                  ylabel="Memory (MB)",
                  marker=:circle,
                  linewidth=2)
        
        savefig(p4, joinpath(output_dir, "memory_usage.png"))
    end
    
    println("Performance plots saved to: $output_dir/")
end

function compare_results(current::BenchmarkResult, baseline::BenchmarkResult, 
                        output_file::String="comparison.png")
    """Create comparison visualization between current and baseline results"""
    
    # Side-by-side comparison
    p = plot(layout=(2,2), size=(800, 600))
    
    # Execution times comparison
    plot!(p[1], [1, 2], [baseline.mean_time, current.mean_time],
          title="Mean Execution Time",
          ylabel="Time (seconds)",
          xticks=([1, 2], ["Baseline", "Current"]),
          marker=:circle,
          markersize=8,
          linewidth=3)
    
    # Memory comparison (if available)
    if baseline.peak_memory > 0 && current.peak_memory > 0
        plot!(p[2], [1, 2], [baseline.peak_memory/(1024*1024), current.peak_memory/(1024*1024)],
              title="Peak Memory Usage",
              ylabel="Memory (MB)",
              xticks=([1, 2], ["Baseline", "Current"]),
              marker=:circle,
              markersize=8,
              linewidth=3)
    end
    
    # Distribution comparison
    histogram!(p[3], baseline.execution_times, alpha=0.5, label="Baseline", bins=15)
    histogram!(p[3], current.execution_times, alpha=0.5, label="Current", bins=15)
    plot!(p[3], title="Time Distribution Comparison", xlabel="Time (seconds)")
    
    # Performance change summary
    analysis = analyze_performance_regression(current, baseline)
    change_text = "Time: $(round(analysis.time_change_percent, digits=1))%\n"
    change_text *= "Memory: $(round(analysis.memory_change_percent, digits=1))%\n"
    change_text *= analysis.is_regression ? "⚠️ Regression" : 
                   analysis.is_improvement ? "✅ Improvement" : "➡️ No Change"
    
    plot!(p[4], [0], [0], title="Performance Change", 
          annotations=[(0.5, 0.5, change_text)],
          xlims=(-1, 1), ylims=(-1, 1),
          showaxis=false, grid=false)
    
    savefig(p, output_file)
    println("Comparison plot saved to: $output_file")
end