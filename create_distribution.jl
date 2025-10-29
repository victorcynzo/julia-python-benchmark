#!/usr/bin/env julia

"""
Create a portable distribution of Python Benchmarker
"""

using Pkg

println("📦 Creating Python Benchmarker Distribution")
println(repeat("=", 50))

# Create distribution directory
dist_dir = "PythonBenchmarker-Portable"
if isdir(dist_dir)
    println("🗑️  Removing existing distribution directory...")
    rm(dist_dir, recursive=true)
end

println("📁 Creating distribution directory: $dist_dir")
mkdir(dist_dir)

# Copy source files
println("📋 Copying source files...")
cp("src", joinpath(dist_dir, "src"), force=true)

# Copy project files
println("📋 Copying project configuration...")
cp("Project.toml", joinpath(dist_dir, "Project.toml"), force=true)
cp("Manifest.toml", joinpath(dist_dir, "Manifest.toml"), force=true)

# Copy portable launchers
println("📋 Copying portable launchers...")
cp("portable_gui.jl", joinpath(dist_dir, "PythonBenchmarker-GUI.jl"), force=true)
cp("portable_cli.jl", joinpath(dist_dir, "PythonBenchmarker-CLI.jl"), force=true)

# Copy example and documentation
println("📋 Copying examples and documentation...")
cp("example_python_script.py", joinpath(dist_dir, "example_python_script.py"), force=true)
cp("README.md", joinpath(dist_dir, "README.md"), force=true)

# Create batch files for Windows
println("📋 Creating Windows batch files...")
open(joinpath(dist_dir, "PythonBenchmarker-GUI.bat"), "w") do f
    write(f, """@echo off
julia PythonBenchmarker-GUI.jl
pause
""")
end

open(joinpath(dist_dir, "PythonBenchmarker-CLI.bat"), "w") do f
    write(f, """@echo off
julia PythonBenchmarker-CLI.jl %*
""")
end

# Create shell scripts for Unix
println("📋 Creating Unix shell scripts...")
open(joinpath(dist_dir, "PythonBenchmarker-GUI.sh"), "w") do f
    write(f, """#!/bin/bash
julia PythonBenchmarker-GUI.jl
""")
end

open(joinpath(dist_dir, "PythonBenchmarker-CLI.sh"), "w") do f
    write(f, """#!/bin/bash
julia PythonBenchmarker-CLI.jl "\$@"
""")
end

# Make shell scripts executable on Unix systems
if !Sys.iswindows()
    try
        run(`chmod +x $(joinpath(dist_dir, "PythonBenchmarker-GUI.sh"))`)
        run(`chmod +x $(joinpath(dist_dir, "PythonBenchmarker-CLI.sh"))`)
    catch
        println("⚠️  Could not make shell scripts executable")
    end
end

# Create installation script
println("📋 Creating installation script...")
open(joinpath(dist_dir, "install_dependencies.jl"), "w") do f
    write(f, """#!/usr/bin/env julia

println("📦 Installing Python Benchmarker Dependencies")
println("=" * 50)

using Pkg

# Activate the local environment
Pkg.activate(".")

# Install dependencies
println("📥 Installing required packages...")
try
    Pkg.instantiate()
    println("✅ Dependencies installed successfully!")
    
    # Test GUI availability
    println("🔍 Testing GUI availability...")
    try
        using Blink
        println("✅ GUI functionality available")
    catch
        println("⚠️  GUI functionality not available")
        println("   Installing Blink.jl...")
        Pkg.add("Blink")
        println("✅ Blink.jl installed")
    end
    
    println("\\n🎉 Installation completed successfully!")
    println("\\nYou can now run:")
    if Sys.iswindows()
        println("  - PythonBenchmarker-GUI.bat (for GUI)")
        println("  - PythonBenchmarker-CLI.bat script.py (for CLI)")
    else
        println("  - ./PythonBenchmarker-GUI.sh (for GUI)")
        println("  - ./PythonBenchmarker-CLI.sh script.py (for CLI)")
    end
    
catch e
    println("❌ Installation failed: \$e")
    println("\\nPlease ensure you have Julia installed and try again.")
end
""")
end

# Create usage instructions
println("📋 Creating usage instructions...")
open(joinpath(dist_dir, "USAGE.txt"), "w") do f
    write(f, """Python Benchmarker - Portable Distribution
=========================================

INSTALLATION:
------------
1. Ensure Julia is installed on your system
2. Run the installation script:
   julia install_dependencies.jl

USAGE:
------
""")
    
    if Sys.iswindows()
        write(f, """
Windows:
  GUI Version:  Double-click PythonBenchmarker-GUI.bat
  CLI Version:  PythonBenchmarker-CLI.bat script.py [options]

Alternative (command line):
  GUI Version:  julia PythonBenchmarker-GUI.jl
  CLI Version:  julia PythonBenchmarker-CLI.jl script.py [options]
""")
    else
        write(f, """
Unix/Linux/macOS:
  GUI Version:  ./PythonBenchmarker-GUI.sh
  CLI Version:  ./PythonBenchmarker-CLI.sh script.py [options]

Alternative:
  GUI Version:  julia PythonBenchmarker-GUI.jl
  CLI Version:  julia PythonBenchmarker-CLI.jl script.py [options]
""")
    end
    
    write(f, """

EXAMPLES:
---------
# Test with the included example
julia PythonBenchmarker-CLI.jl example_python_script.py

# Run with custom options
julia PythonBenchmarker-CLI.jl script.py --iterations 20 --plots

# Launch GUI
julia PythonBenchmarker-GUI.jl

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

println("✅ Distribution created successfully!")
println("📁 Location: $dist_dir")
println("\n📋 Next Steps:")
println("1. Copy the '$dist_dir' folder to your target location")
println("2. Run 'julia install_dependencies.jl' in the copied folder")
println("3. Use the provided scripts to run the benchmarker")

println("\n🎉 Distribution creation completed!")