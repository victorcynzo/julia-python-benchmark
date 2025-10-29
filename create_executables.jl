#!/usr/bin/env julia

"""
Simple executable creator for Python Benchmarker
Creates working .exe files and batch scripts - CLI only
"""

using Pkg

println("🔧 Creating Python Benchmarker Executables")
println(repeat("=", 50))

# Activate project environment
Pkg.activate(".")

# Create build directory
build_dir = "build"
if !isdir(build_dir)
    mkdir(build_dir)
    println("📁 Created build directory: $build_dir")
else
    rm(build_dir, recursive=true)
    mkdir(build_dir)
    println("📁 Cleaned and recreated build directory: $build_dir")
end

# GUI functionality removed as requested

println("\n🏗️  Creating executables...")

# Create Windows batch files
if Sys.iswindows()
    # CLI batch file
    cli_batch_content = """@echo off
cd /d "%~dp0"
julia --project=. "%~dp0benchmark.jl" %*
"""
    
    cli_batch_path = joinpath(build_dir, "PythonBenchmarker-CLI.bat")
    open(cli_batch_path, "w") do f
        write(f, cli_batch_content)
    end
    println("✅ Created CLI batch file: PythonBenchmarker-CLI.bat")
    
    # GUI functionality removed
    
    # Create proper Windows executables using PowerShell wrapper
    # This creates actual .exe files that can run on Windows
    
    # Create CLI .exe using a compiled wrapper approach
    cli_ps1_content = """
Set-Location (Split-Path -Parent \$MyInvocation.MyCommand.Path)
& julia --project=. "benchmark.jl" \$args
"""
    
    cli_ps1_path = joinpath(build_dir, "PythonBenchmarker-CLI.ps1")
    open(cli_ps1_path, "w") do f
        write(f, cli_ps1_content)
    end
    
    # Create a simple C# console app wrapper and compile it
    cli_cs_content = """
using System;
using System.Diagnostics;
using System.IO;

class Program
{
    static void Main(string[] args)
    {
        try
        {
            string currentDir = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            string juliaScript = Path.Combine(currentDir, "benchmark.jl");
            
            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = "julia",
                Arguments = \$"--project=\\"{currentDir}\\" \\"{juliaScript}\\" " + string.Join(" ", args),
                UseShellExecute = false,
                RedirectStandardOutput = false,
                RedirectStandardError = false,
                WorkingDirectory = currentDir
            };
            
            Process process = Process.Start(startInfo);
            process.WaitForExit();
            Environment.Exit(process.ExitCode);
        }
        catch (Exception ex)
        {
            Console.WriteLine(\$"Error launching Python Benchmarker CLI: {ex.Message}");
            Console.WriteLine("Make sure Julia is installed and accessible from PATH.");
            Environment.Exit(1);
        }
    }
}
"""
    
    cli_cs_path = joinpath(build_dir, "PythonBenchmarker-CLI.cs")
    open(cli_cs_path, "w") do f
        write(f, cli_cs_content)
    end
    
    # Try to compile the C# wrapper to .exe
    try
        cli_exe_path = joinpath(build_dir, "PythonBenchmarker-CLI.exe")
        run(`csc /out:$cli_exe_path $cli_cs_path`)
        println("✅ Created CLI executable: PythonBenchmarker-CLI.exe")
        
        # Clean up the .cs file
        rm(cli_cs_path)
    catch
        println("⚠️  C# compiler not available, keeping batch file as primary executable")
        # Keep the batch file as the main executable
        cli_exe_path = cli_batch_path
    end
    
    # GUI functionality removed
    
else
    # Unix shell scripts
    cli_script_content = """#!/bin/bash
cd "\$(dirname "\$0")"
julia --project=. "\$0/../benchmark.jl" "\$@"
"""
    
    cli_script_path = joinpath(build_dir, "PythonBenchmarker-CLI")
    open(cli_script_path, "w") do f
        write(f, cli_script_content)
    end
    run(`chmod +x $cli_script_path`)
    println("✅ Created CLI script: PythonBenchmarker-CLI")
    
    # GUI functionality removed
end

# Copy necessary files to build directory
println("\n📁 Copying necessary files...")
cp("benchmark.jl", joinpath(build_dir, "benchmark.jl"), force=true)
# GUI launcher removed
cp("src", joinpath(build_dir, "src"), force=true)
cp("Project.toml", joinpath(build_dir, "Project.toml"), force=true)
cp("Manifest.toml", joinpath(build_dir, "Manifest.toml"), force=true)
cp("example_python_script.py", joinpath(build_dir, "example_python_script.py"), force=true)
cp("README.md", joinpath(build_dir, "README.md"), force=true)

# Create distribution package
println("\n📦 Creating distribution package...")
dist_dir = joinpath(build_dir, "PythonBenchmarker-Distribution")
mkdir(dist_dir)

# Copy executables to distribution
for file in readdir(build_dir)
    if (endswith(file, ".bat") || endswith(file, ".exe") || endswith(file, ".ps1") ||
        (isfile(joinpath(build_dir, file)) && !occursin(".", file) && file != "PythonBenchmarker-Distribution"))
        src = joinpath(build_dir, file)
        dst = joinpath(dist_dir, file)
        cp(src, dst, force=true)
    end
end

# Copy support files to distribution
cp(joinpath(build_dir, "benchmark.jl"), joinpath(dist_dir, "benchmark.jl"), force=true)
# GUI launcher removed
cp(joinpath(build_dir, "src"), joinpath(dist_dir, "src"), force=true)
cp(joinpath(build_dir, "Project.toml"), joinpath(dist_dir, "Project.toml"), force=true)
cp(joinpath(build_dir, "Manifest.toml"), joinpath(dist_dir, "Manifest.toml"), force=true)
cp(joinpath(build_dir, "example_python_script.py"), joinpath(dist_dir, "example_python_script.py"), force=true)
cp(joinpath(build_dir, "README.md"), joinpath(dist_dir, "README.md"), force=true)

# Create usage instructions
usage_file = joinpath(dist_dir, "USAGE.txt")
open(usage_file, "w") do f
    write(f, """
Python Benchmarker - Usage Instructions
======================================

This package contains executables for the Python Benchmarker tool.

REQUIREMENTS:
- Julia runtime must be installed on the target system

FILES:
------
""")
    
    if Sys.iswindows()
        write(f, "- PythonBenchmarker-CLI.exe    : Command-line executable (if C# compiler available)\n")
        write(f, "- PythonBenchmarker-CLI.bat    : Command-line batch script (always works)\n")
        write(f, "- PythonBenchmarker-CLI.ps1    : PowerShell script version\n")
    else
        write(f, "- PythonBenchmarker-CLI        : Command-line version\n")
    end
    
    write(f, """
- example_python_script.py     : Example Python script for testing
- README.md                    : Complete documentation

USAGE:
------
""")
    
    if Sys.iswindows()
        write(f, """
Command Line Interface:
  Method 1 (if .exe works): Double-click PythonBenchmarker-CLI.exe
  Method 2 (always works): Double-click PythonBenchmarker-CLI.bat
  Method 3 (PowerShell): Right-click PythonBenchmarker-CLI.ps1 → Run with PowerShell
  Command line: PythonBenchmarker-CLI.bat script.py --iterations 20 --plots

""")

    else
        write(f, """
Command Line Interface:
  ./PythonBenchmarker-CLI script.py
  ./PythonBenchmarker-CLI script.py --iterations 20 --plots

""")

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

# Print final summary
println("\n🎉 Build Summary:")
println(repeat("=", 50))

if Sys.iswindows()
    cli_exe = joinpath(build_dir, "PythonBenchmarker-CLI.exe")
    
    if isfile(cli_exe)
        println("✅ CLI Executable: $cli_exe")
        println("   Usage: Double-click or PythonBenchmarker-CLI.exe script.py [options]")
    end
else
    cli_script = joinpath(build_dir, "PythonBenchmarker-CLI")
    
    if isfile(cli_script)
        println("✅ CLI Script: $cli_script")
        println("   Usage: ./PythonBenchmarker-CLI script.py [options]")
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
println("3. Users need Julia installed but get direct executable access")

println("\n🚀 Build completed successfully!")