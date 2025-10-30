using CSV
using DataFrames
using JSON3
using Plots

# Try to load StatsPlots for boxplot functionality
const STATSPLOTS_AVAILABLE = try
    using StatsPlots
    true
catch
    false
end

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
end

function create_performance_plots(result::BenchmarkResult, output_dir::String="plots")
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
    
    # Box plot for quartiles (if StatsPlots is available)
    if STATSPLOTS_AVAILABLE
        p3 = boxplot([result.execution_times], 
                     title="Execution Time Box Plot",
                     ylabel="Time (seconds)",
                     legend=false)
        
        savefig(p3, joinpath(output_dir, "box_plot.png"))
    else
        # Alternative: quartile visualization using scatter plot
        q1, q2, q3 = percentile(result.execution_times, [25, 50, 75])
        p3 = scatter([1], [q2], title="Execution Time Quartiles",
                     ylabel="Time (seconds)", 
                     yerror=([q2-q1], [q3-q2]),
                     markersize=8, legend=false,
                     xlims=(0.5, 1.5), xticks=([1], ["Quartiles"]))
        
        savefig(p3, joinpath(output_dir, "quartiles.png"))
    end
    
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

function print_batch_summary(batch_result::BatchBenchmarkResult)
    """Print batch benchmark results summary"""
    
    println("\n" * "="^80)
    println("BATCH BENCHMARK RESULTS SUMMARY")
    println("="^80)
    println("Scripts benchmarked: $(length(batch_result.results))")
    println("Timestamp: $(batch_result.timestamp)")
    println("Combined output directory: $(batch_result.combined_output_dir)")
    println()
    
    # Summary table
    println("PERFORMANCE SUMMARY:")
    println("-" ^ 80)
    println("Script Name                    | Mean Time (s) | Success Rate | Stability")
    println("-" ^ 80)
    
    for (i, result) in enumerate(batch_result.results)
        script_name = batch_result.script_names[i]
        success_rate = result.success_count / result.config.iterations * 100
        stability = calculate_stability_metrics(result)
        
        # Truncate long script names
        display_name = length(script_name) > 25 ? script_name[1:22] * "..." : script_name
        
        println("$(rpad(display_name, 30)) | $(rpad(round(result.mean_time, digits=3), 13)) | $(rpad(round(success_rate, digits=1), 12))% | $(stability.stability_rating)")
    end
    println("-" ^ 80)
    
    # Find best and worst performers
    successful_results = filter(r -> r.success_count > 0, batch_result.results)
    if !isempty(successful_results)
        fastest_idx = argmin([r.mean_time for r in successful_results])
        slowest_idx = argmax([r.mean_time for r in successful_results])
        
        fastest_name = batch_result.script_names[findfirst(r -> r === successful_results[fastest_idx], batch_result.results)]
        slowest_name = batch_result.script_names[findfirst(r -> r === successful_results[slowest_idx], batch_result.results)]
        
        println("\nPERFORMANCE HIGHLIGHTS:")
        println("🏆 Fastest: $fastest_name ($(round(successful_results[fastest_idx].mean_time, digits=3))s)")
        println("🐌 Slowest: $slowest_name ($(round(successful_results[slowest_idx].mean_time, digits=3))s)")
        
        if length(successful_results) > 1
            speedup = successful_results[slowest_idx].mean_time / successful_results[fastest_idx].mean_time
            println("⚡ Speedup: $(round(speedup, digits=2))x faster")
        end
    end
    
    println("="^80)
end

function export_batch_to_csv(batch_result::BatchBenchmarkResult, filename::String)
    """Export combined batch results to CSV"""
    
    # Create combined DataFrame
    combined_data = []
    
    for (i, result) in enumerate(batch_result.results)
        script_name = batch_result.script_names[i]
        
        for (run_idx, exec_time) in enumerate(result.execution_times)
            memory_usage = length(result.memory_usage) >= run_idx ? result.memory_usage[run_idx] : 0
            
            push!(combined_data, (
                script = script_name,
                run_number = run_idx,
                execution_time = exec_time,
                memory_usage = memory_usage
            ))
        end
    end
    
    df = DataFrame(combined_data)
    CSV.write(filename, df)
    println("Combined batch results exported to: $filename")
    
    # Also create summary statistics CSV
    summary_filename = replace(filename, ".csv" => "_summary.csv")
    summary_data = []
    
    for (i, result) in enumerate(batch_result.results)
        script_name = batch_result.script_names[i]
        stability = calculate_stability_metrics(result)
        
        push!(summary_data, (
            script = script_name,
            iterations = result.config.iterations,
            success_count = result.success_count,
            success_rate = result.success_count / result.config.iterations * 100,
            mean_time = result.mean_time,
            median_time = result.median_time,
            std_time = result.std_time,
            min_time = result.min_time,
            max_time = result.max_time,
            percentile_25 = get(result.percentiles, 25, 0.0),
            percentile_50 = get(result.percentiles, 50, 0.0),
            percentile_75 = get(result.percentiles, 75, 0.0),
            percentile_90 = get(result.percentiles, 90, 0.0),
            percentile_95 = get(result.percentiles, 95, 0.0),
            percentile_99 = get(result.percentiles, 99, 0.0),
            mean_memory_mb = result.mean_memory / (1024 * 1024),
            peak_memory_mb = result.peak_memory / (1024 * 1024),
            coefficient_of_variation = stability.coefficient_of_variation,
            outlier_count = stability.outlier_count,
            stability_rating = stability.stability_rating
        ))
    end
    
    summary_df = DataFrame(summary_data)
    CSV.write(summary_filename, summary_df)
    println("Batch summary statistics exported to: $summary_filename")
end

function export_batch_to_json(batch_result::BatchBenchmarkResult, filename::String)
    """Export complete batch results to JSON"""
    
    batch_dict = Dict(
        "batch_info" => Dict(
            "timestamp" => string(batch_result.timestamp),
            "script_count" => length(batch_result.results),
            "script_names" => batch_result.script_names,
            "combined_output_dir" => batch_result.combined_output_dir
        ),
        "results" => []
    )
    
    for (i, result) in enumerate(batch_result.results)
        result_dict = Dict(
            "script_name" => batch_result.script_names[i],
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
        
        push!(batch_dict["results"], result_dict)
    end
    
    JSON3.write(filename, batch_dict)
    println("Complete batch results exported to: $filename")
end

function create_batch_performance_plots(batch_result::BatchBenchmarkResult, output_dir::String="batch_plots")
    """Generate combined performance visualization plots for batch results"""
    
    if !isdir(output_dir)
        mkdir(output_dir)
    end
    
    successful_results = filter(r -> r.success_count > 0, batch_result.results)
    if isempty(successful_results)
        println("No successful results to plot")
        return
    end
    
    # Get corresponding script names for successful results
    successful_names = String[]
    for result in successful_results
        idx = findfirst(r -> r === result, batch_result.results)
        push!(successful_names, batch_result.script_names[idx])
    end
    
    # 1. Combined execution time comparison (bar chart)
    mean_times = [r.mean_time for r in successful_results]
    std_times = [r.std_time for r in successful_results]
    
    p1 = bar(successful_names, mean_times, 
             yerror=std_times,
             title="Mean Execution Time Comparison",
             xlabel="Scripts",
             ylabel="Time (seconds)",
             xrotation=45,
             legend=false,
             color=:viridis)
    
    savefig(p1, joinpath(output_dir, "execution_time_comparison.png"))
    
    # 2. Combined time series plot (multiple lines)
    p2 = plot(title="Execution Time Series - All Scripts",
              xlabel="Run Number",
              ylabel="Time (seconds)",
              legend=:topright)
    
    colors = [:blue, :red, :green, :orange, :purple, :brown, :pink, :gray, :olive, :cyan]
    
    for (i, result) in enumerate(successful_results)
        color = colors[((i-1) % length(colors)) + 1]
        plot!(p2, 1:length(result.execution_times), result.execution_times,
              label=successful_names[i],
              marker=:circle,
              linewidth=2,
              color=color)
    end
    
    savefig(p2, joinpath(output_dir, "combined_time_series.png"))
    
    # 3. Combined distribution plot (overlapping histograms)
    p3 = plot(title="Execution Time Distributions",
              xlabel="Time (seconds)",
              ylabel="Density",
              legend=:topright)
    
    for (i, result) in enumerate(successful_results)
        color = colors[((i-1) % length(colors)) + 1]
        histogram!(p3, result.execution_times,
                  alpha=0.6,
                  bins=15,
                  normalize=:pdf,
                  label=successful_names[i],
                  color=color)
    end
    
    savefig(p3, joinpath(output_dir, "combined_distributions.png"))
    
    # 4. Performance comparison matrix (box plots if available)
    if STATSPLOTS_AVAILABLE && length(successful_results) > 1
        all_times = []
        all_labels = []
        
        for (i, result) in enumerate(successful_results)
            append!(all_times, result.execution_times)
            append!(all_labels, fill(successful_names[i], length(result.execution_times)))
        end
        
        p4 = boxplot(all_labels, all_times,
                     title="Execution Time Box Plot Comparison",
                     xlabel="Scripts",
                     ylabel="Time (seconds)",
                     xrotation=45,
                     legend=false)
        
        savefig(p4, joinpath(output_dir, "combined_boxplot.png"))
    else
        # Alternative: quartile comparison
        p4 = plot(title="Quartile Comparison",
                  xlabel="Scripts",
                  ylabel="Time (seconds)",
                  xrotation=45,
                  legend=false)
        
        for (i, result) in enumerate(successful_results)
            q1 = get(result.percentiles, 25, result.mean_time)
            q2 = get(result.percentiles, 50, result.mean_time)
            q3 = get(result.percentiles, 75, result.mean_time)
            
            scatter!(p4, [i], [q2],
                    yerror=([q2-q1], [q3-q2]),
                    markersize=8,
                    color=colors[((i-1) % length(colors)) + 1])
        end
        
        plot!(p4, xticks=(1:length(successful_names), successful_names))
        savefig(p4, joinpath(output_dir, "combined_quartiles.png"))
    end
    
    # 5. Memory usage comparison (if available)
    memory_results = filter(r -> r.peak_memory > 0, successful_results)
    if !isempty(memory_results)
        memory_names = String[]
        for result in memory_results
            idx = findfirst(r -> r === result, batch_result.results)
            push!(memory_names, batch_result.script_names[idx])
        end
        
        peak_memories = [r.peak_memory / (1024 * 1024) for r in memory_results]  # Convert to MB
        
        p5 = bar(memory_names, peak_memories,
                 title="Peak Memory Usage Comparison",
                 xlabel="Scripts",
                 ylabel="Memory (MB)",
                 xrotation=45,
                 legend=false,
                 color=:plasma)
        
        savefig(p5, joinpath(output_dir, "memory_comparison.png"))
    end
    
    println("Batch performance plots saved to: $output_dir/")
end