#!/usr/bin/env julia

"""
Build script for creating standalone executables of Python Benchmarker
CLI version only
"""

using Pkg

println("🔧 Python Benchmarker Build Script")
println(repeat("=", 50))

# Activate project environment
println("📦 Activating project environment...")
Pkg.activate(".")

# Install PackageCompiler if not available
println("📦 Checking PackageCompiler.jl...")
try
    using PackageCompiler
    println("✅ PackageCompiler.jl is available")
catch
    println("📥 Installing PackageCompiler.jl...")
    Pkg.add("PackageCompiler")
    using PackageCompiler
end

# Install all dependencies
println("📦 Installing project dependencies...")
Pkg.instantiate()

# Build options
build_cli = true

println("\n🏗️  Build Configuration:")
println("   CLI Version: ✅")
println("   GUI Version: ❌ (Removed)")

# Create build directory
build_dir = "build"
if !isdir(build_dir)
    mkdir(build_dir)
    println("📁 Created build directory: $build_dir")
else
    println("📁 Using existing build directory: $build_dir")
end

# Build CLI version
if build_cli
    println("\n🔨 Building CLI executable...")
    try
        cli_app_dir = joinpath(build_dir, "PythonBenchmarker-CLI")
        
        create_app(
            ".",
            cli_app_dir,
            executables = ["benchmark" => "benchmark.jl"],
            force = true,
            include_lazy_artifacts = true
        )
        
        println("✅ CLI executable built successfully!")
        println("   Location: $cli_app_dir")
        
        # Create wrapper scripts for different platforms
        if Sys.iswindows()
            exe_path = joinpath(cli_app_dir, "bin", "benchmark.exe")
            wrapper_path = joinpath(build_dir, "PythonBenchmarker-CLI.exe")
            if isfile(exe_path)
                cp(exe_path, wrapper_path, force=true)
                println("   Windows executable: $wrapper_path")
            end
        else
            exe_path = joinpath(cli_app_dir, "bin", "benchmark")
            wrapper_path = joinpath(build_dir, "PythonBenchmarker-CLI")
            if isfile(exe_path)
                cp(exe_path, wrapper_path, force=true)
                run(`chmod +x $wrapper_path`)
                println("   Unix executable: $wrapper_path")
            end
        end
        
    catch e
        println("❌ CLI build failed: $e")
    end
end

# GUI version removed as requested

# Create distribution package
println("\n📦 Creating distribution package...")
try
    dist_dir = joinpath(build_dir, "PythonBenchmarker-Distribution")
    if isdir(dist_dir)
        rm(dist_dir, recursive=true)
    end
    mkdir(dist_dir)
    
    # Copy executables
    for file in readdir(build_dir)
        if endswith(file, ".exe") || (isfile(joinpath(build_dir, file)) && !isdir(joinpath(build_dir, file)) && file != "PythonBenchmarker-Distribution")
            src = joinpath(build_dir, file)
            dst = joinpath(dist_dir, file)
            cp(src, dst, force=true)
        end
    end
    
    # Copy example files
    cp("example_python_script.py", joinpath(dist_dir, "example_python_script.py"))
    cp("README.md", joinpath(dist_dir, "README.md"))
    
    # Create usage instructions
    usage_file = joinpath(dist_dir, "USAGE.txt")
    open(usage_file, "w") do f
        write(f, """
Python Benchmarker - Usage Instructions
======================================

This package contains standalone executables for the Python Benchmarker tool.

FILES:
------
""")
        
        if build_cli
            if Sys.iswindows()
                write(f, "- PythonBenchmarker-CLI.exe    : Command-line version\n")
            else
                write(f, "- PythonBenchmarker-CLI        : Command-line version\n")
            end
        end
        
        write(f, """
- example_python_script.py     : Example Python script for testing
- README.md                    : Complete documentation

USAGE:
------
""")
        
        if build_cli
            write(f, """
Command Line Interface:
""")
            if Sys.iswindows()
                write(f, """
  PythonBenchmarker-CLI.exe script.py
  PythonBenchmarker-CLI.exe script.py --iterations 20 --plots
""")
            else
                write(f, """
  ./PythonBenchmarker-CLI script.py
  ./PythonBenchmarker-CLI script.py --iterations 20 --plots
""")
            end
        end
        

        
        write(f, """

FEATURES:
---------
- Process isolation for clean benchmarking
- Statistical analysis with percentiles
- Memory usage tracking
- Performance visualization plots
- CSV and JSON export options
- Regression detection against baselines
- Cross-platform support

For detailed documentation, see README.md
""")
    end
    
    println("✅ Distribution package created: $dist_dir")
    
catch e
    println("❌ Distribution package creation failed: $e")
end

# Print final summary
println("\n🎉 Build Summary:")
println(repeat("=", 50))

if build_cli
    cli_exe = Sys.iswindows() ? "PythonBenchmarker-CLI.exe" : "PythonBenchmarker-CLI"
    cli_path = joinpath(build_dir, cli_exe)
    if isfile(cli_path)
        println("✅ CLI Executable: $cli_path")
        println("   Usage: $cli_exe script.py [options]")
    end
end



dist_path = joinpath(build_dir, "PythonBenchmarker-Distribution")
if isdir(dist_path)
    println("✅ Distribution Package: $dist_path")
    println("   Contains all executables and documentation")
end

println("\n📋 Next Steps:")
println("1. Test the executables with the provided example script")
println("2. Distribute the contents of the Distribution folder")
println("3. Users can run the executables without Julia installed")

println("\n🚀 Build completed successfully!")