using BenchmarkTools
using Dates

struct BenchmarkConfig
    python_file::String
    iterations::Int
    warmup_runs::Int
    timeout_seconds::Float64
    memory_tracking::Bool
    python_args::Vector{String}
    
    function BenchmarkConfig(python_file; iterations=10, warmup_runs=3, 
                           timeout_seconds=300.0, memory_tracking=true, 
                           python_args=String[])
        new(python_file, iterations, warmup_runs, timeout_seconds, 
            memory_tracking, python_args)
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

function run_isolated_python(config::BenchmarkConfig)
    """Execute Python script in isolated process and capture metrics"""
    
    # Build command
    cmd_args = ["python", config.python_file]
    append!(cmd_args, config.python_args)
    
    # Measure execution time and memory
    start_time = time()
    
    try
        if config.memory_tracking
            # Use time command on Unix-like systems for memory tracking
            if Sys.iswindows()
                # Windows: use basic process execution
                result = read(Cmd(cmd_args), String)
                exec_time = time() - start_time
                return (success=true, time=exec_time, memory=0, output=result, error="")
            else
                # Unix: use /usr/bin/time for memory tracking
                time_cmd = ["/usr/bin/time", "-f", "%e %M", "--"]
                full_cmd = vcat(time_cmd, cmd_args)
                
                # Capture both stdout and stderr
                proc = run(pipeline(Cmd(full_cmd), stdout=IOBuffer(), stderr=IOBuffer()))
                
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
            result = read(Cmd(cmd_args), String)
            exec_time = time() - start_time
            return (success=true, time=exec_time, memory=0, output=result, error="")
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
            println("✗ Failed")
        end
    end
    
    if success_count == 0
        error("All benchmark runs failed!")
    end
    
    # Calculate statistics
    mean_time = mean(execution_times)
    median_time = median(execution_times)
    std_time = std(execution_times)
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