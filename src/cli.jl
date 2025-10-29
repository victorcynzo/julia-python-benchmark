using ArgParse
using Dates

function parse_commandline()
    s = ArgParseSettings(description="Python Benchmarking Tool")

    @add_arg_table! s begin
        "python_file"
            help = "Python file to benchmark"
            required = true
            
        "--iterations", "-i"
            help = "Number of benchmark iterations"
            arg_type = Int
            default = 10
            
        "--warmup", "-w"
            help = "Number of warmup runs"
            arg_type = Int
            default = 3
            
        "--timeout", "-t"
            help = "Timeout in seconds for each run"
            arg_type = Float64
            default = 300.0
            
        "--no-memory"
            help = "Disable memory tracking"
            action = :store_true
            
        "--output-csv"
            help = "Export results to CSV file"
            arg_type = String
            
        "--output-json"
            help = "Export results to JSON file"
            arg_type = String
            
        "--plots"
            help = "Generate performance plots"
            action = :store_true
            
        "--plot-dir"
            help = "Directory for plot output"
            arg_type = String
            default = "plots"
            
        "--baseline"
            help = "Baseline JSON file for comparison"
            arg_type = String
            
        "--python-args"
            help = "Arguments to pass to Python script"
            nargs = '*'
            
        "--quiet", "-q"
            help = "Suppress detailed output"
            action = :store_true
    end

    return parse_args(s)
end

function create_output_directory(python_file::String)
    """Create organized output directory based on Python file name"""
    # Extract filename without extension
    base_name = splitext(basename(python_file))[1]
    
    # Create directory name with timestamp for uniqueness
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    output_dir = "test-results-$(base_name)-$(timestamp)"
    
    # Create directory if it doesn't exist
    if !isdir(output_dir)
        mkdir(output_dir)
        println("Created output directory: $output_dir")
    end
    
    return output_dir
end

function main()
    args = parse_commandline()
    
    # Create organized output directory
    output_dir = create_output_directory(args["python_file"])
    
    # Create benchmark configuration
    config = BenchmarkConfig(
        args["python_file"];
        iterations = args["iterations"],
        warmup_runs = args["warmup"],
        timeout_seconds = args["timeout"],
        memory_tracking = !args["no-memory"],
        python_args = args["python-args"] !== nothing ? args["python-args"] : String[]
    )
    
    # Run benchmark
    try
        result = run_benchmark(config)
        
        # Print summary unless quiet
        if !args["quiet"]
            print_summary(result)
        end
        
        # Export results to organized directory
        if args["output-csv"] !== nothing
            csv_path = joinpath(output_dir, args["output-csv"])
            export_to_csv(result, csv_path)
        else
            # Always create a default CSV export
            default_csv = joinpath(output_dir, "benchmark_results.csv")
            export_to_csv(result, default_csv)
        end
        
        if args["output-json"] !== nothing
            json_path = joinpath(output_dir, args["output-json"])
            export_to_json(result, json_path)
        else
            # Always create a default JSON export
            default_json = joinpath(output_dir, "benchmark_results.json")
            export_to_json(result, default_json)
        end
        
        # Generate plots in organized directory
        if args["plots"]
            plot_dir = joinpath(output_dir, args["plot-dir"])
            create_performance_plots(result, plot_dir)
        end
        
        # Baseline comparison
        if args["baseline"] !== nothing
            if isfile(args["baseline"])
                baseline_data = JSON3.read(args["baseline"])
                # Reconstruct baseline result (simplified)
                baseline_times = baseline_data["results"]["execution_times"]
                baseline_config = BenchmarkConfig(baseline_data["config"]["python_file"])
                
                # Create minimal baseline result for comparison
                baseline_result = BenchmarkResult(
                    baseline_config, baseline_times, Int64[], 
                    length(baseline_times), String[], now(),
                    mean(baseline_times), median(baseline_times), std(baseline_times),
                    minimum(baseline_times), maximum(baseline_times),
                    Dict{Int,Float64}(), 0.0, 0
                )
                
                analysis = analyze_performance_regression(result, baseline_result)
                
                println("\nBASELINE COMPARISON:")
                println("Time change: $(round(analysis.time_change_percent, digits=2))%")
                if analysis.is_regression
                    println("⚠️  Performance regression detected!")
                elseif analysis.is_improvement
                    println("✅ Performance improvement detected!")
                else
                    println("➡️  No significant change")
                end
                
                # Generate comparison plot in output directory
                comparison_path = joinpath(output_dir, "comparison.png")
                compare_results(result, baseline_result, comparison_path)
            else
                println("Warning: Baseline file not found: $(args["baseline"])")
            end
        end
        
    catch e
        println("Error running benchmark: $e")
        exit(1)
    end
end