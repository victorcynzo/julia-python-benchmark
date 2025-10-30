using BenchmarkTools
using Dates

struct BenchmarkConfig
    python_file::String
    iterations::Int
    warmup_runs::Int
    timeout_seconds::Float64
    memory_tracking::Bool
    python_args::Vector{String}
    working_dir::Union{String, Nothing}
    
    function BenchmarkConfig(python_file; iterations=10, warmup_runs=3, 
                           timeout_seconds=300.0, memory_tracking=true, 
                           python_args=String[], working_dir=nothing)
        new(python_file, iterations, warmup_runs, timeout_seconds, 
            memory_tracking, python_args, working_dir)
    end
end

struct BenchmarkResult
    config::BenchmarkConfig
    execution_times::Vector{Float64}  # in seconds
    memory_usage::Vector{Int64}       # in bytes
    success_count::Int
    failed_runs::Vector{String}       # error messages
    timestamp::DateTime
    
    # Statistical summaries
    mean_time::Float64
    median_time::Float64
    std_time::Float64
    min_time::Float64
    max_time::Float64
    percentiles::Dict{Int, Float64}
    
    mean_memory::Float64
    peak_memory::Int64
end

struct BatchBenchmarkResult
    results::Vector{BenchmarkResult}
    script_names::Vector{String}
    timestamp::DateTime
    combined_output_dir::String
end

function run_isolated_python(config::BenchmarkConfig)
    """Execute Python script in isolated process and capture metrics"""
    
    # Build command - handle working directory properly
    python_file = config.python_file
    
    # If working_dir is specified, we need to handle the path correctly
    if config.working_dir !== nothing
        if isabspath(python_file)
            # If python_file is absolute, use it as-is
            cmd_args = ["python", python_file]
        else
            # If python_file is relative and working_dir is specified,
            # the python_file should be relative to the working_dir
            cmd_args = ["python", python_file]
        end
    else
        # No working directory specified, use python_file as-is
        cmd_args = ["python", python_file]
    end
    
    append!(cmd_args, config.python_args)
    
    # Create command with working directory if specified
    cmd = Cmd(cmd_args)
    
    # Set environment variables for better Unicode support on Windows
    env_vars = Dict{String,String}()
    if config.working_dir !== nothing
        env_vars["PWD"] = config.working_dir
    end
    
    # Set UTF-8 encoding for Python to handle Unicode characters in output
    if Sys.iswindows()
        env_vars["PYTHONIOENCODING"] = "utf-8"
        env_vars["PYTHONLEGACYWINDOWSSTDIO"] = "utf-8"
    end
    
    if !isempty(env_vars)
        if config.working_dir !== nothing
            cmd = setenv(cmd, env_vars, dir=config.working_dir)
        else
            cmd = setenv(cmd, env_vars)
        end
    elseif config.working_dir !== nothing
        cmd = setenv(cmd, dir=config.working_dir)
    end
    
    # Measure execution time and memory
    start_time = time()
    
    try
        if config.memory_tracking
            # Use time command on Unix-like systems for memory tracking
            if Sys.iswindows()
                # Windows: use basic process execution with error capture
                try
                    result = read(cmd, String)
                    exec_time = time() - start_time
                    return (success=true, time=exec_time, memory=0, output=result, error="")
                catch e
                    # Capture stderr for better error reporting
                    try
                        stdout_buf = IOBuffer()
                        stderr_buf = IOBuffer()
                        proc = run(pipeline(cmd, stdout=stdout_buf, stderr=stderr_buf), wait=false)
                        wait(proc)
                        stdout_output = String(take!(stdout_buf))
                        stderr_output = String(take!(stderr_buf))
                        exec_time = time() - start_time
                        
                        if proc.exitcode == 0
                            return (success=true, time=exec_time, memory=0, output=stdout_output, error="")
                        else
                            error_msg = "Exit code $(proc.exitcode)"
                            if !isempty(stderr_output)
                                error_msg *= ": " * stderr_output
                            end
                            return (success=false, time=exec_time, memory=0, output=stdout_output, error=error_msg)
                        end
                    catch inner_e
                        exec_time = time() - start_time
                        return (success=false, time=exec_time, memory=0, output="", error=string(inner_e))
                    end
                end
            else
                # Unix: use /usr/bin/time for memory tracking
                time_cmd = ["/usr/bin/time", "-f", "%e %M", "--"]
                full_cmd = vcat(time_cmd, cmd_args)
                
                # Create time command with working directory
                time_cmd_obj = Cmd(full_cmd)
                if config.working_dir !== nothing
                    time_cmd_obj = setenv(time_cmd_obj, dir=config.working_dir)
                end
                
                # Capture both stdout and stderr
                proc = run(pipeline(time_cmd_obj, stdout=IOBuffer(), stderr=IOBuffer()))
                
                if proc.exitcode == 0
                    stderr_output = String(take!(proc.stderr))
                    # Parse time output (last line should be "time memory")
                    lines = split(strip(stderr_output), '\n')
                    time_line = lines[end]
                    parts = split(time_line)
                    exec_time = parse(Float64, parts[1])
                    memory_kb = parse(Int64, parts[2])
                    
                    stdout_output = String(take!(proc.stdout))
                    return (success=true, time=exec_time, memory=memory_kb*1024, 
                           output=stdout_output, error="")
                else
                    error_msg = String(take!(proc.stderr))
                    return (success=false, time=0.0, memory=0, output="", error=error_msg)
                end
            end
        else
            # Simple execution without memory tracking
            try
                result = read(cmd, String)
                exec_time = time() - start_time
                return (success=true, time=exec_time, memory=0, output=result, error="")
            catch e
                # Capture stderr for better error reporting
                try
                    stdout_buf = IOBuffer()
                    stderr_buf = IOBuffer()
                    proc = run(pipeline(cmd, stdout=stdout_buf, stderr=stderr_buf), wait=false)
                    wait(proc)
                    stdout_output = String(take!(stdout_buf))
                    stderr_output = String(take!(stderr_buf))
                    exec_time = time() - start_time
                    
                    if proc.exitcode == 0
                        return (success=true, time=exec_time, memory=0, output=stdout_output, error="")
                    else
                        error_msg = "Exit code $(proc.exitcode)"
                        if !isempty(stderr_output)
                            error_msg *= ": " * stderr_output
                        end
                        return (success=false, time=exec_time, memory=0, output=stdout_output, error=error_msg)
                    end
                catch inner_e
                    exec_time = time() - start_time
                    return (success=false, time=exec_time, memory=0, output="", error=string(inner_e))
                end
            end
        end
    catch e
        exec_time = time() - start_time
        return (success=false, time=exec_time, memory=0, output="", 
               error=string(e))
    end
end

function run_benchmark(config::BenchmarkConfig)
    """Main benchmarking function with process isolation"""
    
    println("Starting benchmark of $(config.python_file)")
    if config.working_dir !== nothing
        println("Working directory: $(config.working_dir)")
    end
    println("Iterations: $(config.iterations), Warmup: $(config.warmup_runs)")
    
    execution_times = Float64[]
    memory_usage = Int64[]
    failed_runs = String[]
    success_count = 0
    
    # Warmup runs
    println("Running warmup...")
    for i in 1:config.warmup_runs
        result = run_isolated_python(config)
        if !result.success
            println("Warmup run $i failed: $(result.error)")
            # Show stdout if available for debugging
            if !isempty(result.output)
                println("  Output: $(result.output)")
            end
        end
    end
    
    # Actual benchmark runs
    println("Running benchmark iterations...")
    for i in 1:config.iterations
        print("Run $i/$(config.iterations)... ")
        
        result = run_isolated_python(config)
        
        if result.success
            push!(execution_times, result.time)
            push!(memory_usage, result.memory)
            success_count += 1
            println("✓ $(round(result.time, digits=4))s")
        else
            push!(failed_runs, "Run $i: $(result.error)")
            println("✗ Failed: $(result.error)")
            # Show stdout if available for debugging
            if !isempty(result.output)
                println("  Output: $(result.output)")
            end
        end
    end
    
    if success_count == 0
        error("All benchmark runs failed!")
    end
    
    # Calculate statistics
    mean_time = mean(execution_times)
    median_time = median(execution_times)
    std_time = length(execution_times) > 1 ? std(execution_times) : 0.0
    min_time = minimum(execution_times)
    max_time = maximum(execution_times)
    
    percentiles = Dict(
        25 => percentile(execution_times, 25),
        50 => percentile(execution_times, 50),
        75 => percentile(execution_times, 75),
        90 => percentile(execution_times, 90),
        95 => percentile(execution_times, 95),
        99 => percentile(execution_times, 99)
    )
    
    mean_memory = length(memory_usage) > 0 ? mean(memory_usage) : 0.0
    peak_memory = length(memory_usage) > 0 ? maximum(memory_usage) : 0
    
    return BenchmarkResult(
        config, execution_times, memory_usage, success_count, failed_runs,
        now(), mean_time, median_time, std_time, min_time, max_time,
        percentiles, mean_memory, peak_memory
    )
end

function run_batch_benchmark(scripts::Vector{String}, base_config::BenchmarkConfig)
    """Run benchmarks on multiple scripts and return batch results"""
    
    println("=== BATCH BENCHMARK MODE ===")
    println("Scripts to benchmark: $(length(scripts))")
    for (i, script) in enumerate(scripts)
        println("  $i. $script")
    end
    println()
    
    results = BenchmarkResult[]
    script_names = String[]
    
    for (i, script) in enumerate(scripts)
        println("[$i/$(length(scripts))] Benchmarking: $script")
        println("=" ^ 60)
        
        # Create config for this script
        script_config = BenchmarkConfig(
            script;
            iterations = base_config.iterations,
            warmup_runs = base_config.warmup_runs,
            timeout_seconds = base_config.timeout_seconds,
            memory_tracking = base_config.memory_tracking,
            python_args = base_config.python_args,
            working_dir = base_config.working_dir
        )
        
        try
            result = run_benchmark(script_config)
            push!(results, result)
            push!(script_names, splitext(basename(script))[1])  # Remove extension for cleaner names
            println("✅ Completed: $script")
        catch e
            println("❌ Failed: $script - $e")
            # Create a dummy failed result
            failed_result = BenchmarkResult(
                script_config, Float64[], Int64[], 0, ["All runs failed: $e"],
                now(), 0.0, 0.0, 0.0, 0.0, 0.0, Dict{Int,Float64}(), 0.0, 0
            )
            push!(results, failed_result)
            push!(script_names, splitext(basename(script))[1])
        end
        
        println()
    end
    
    # Create combined output directory
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    combined_dir = "batch-results-$(timestamp)"
    if !isdir(combined_dir)
        mkdir(combined_dir)
        println("Created batch output directory: $combined_dir")
    end
    
    return BatchBenchmarkResult(results, script_names, now(), combined_dir)
end