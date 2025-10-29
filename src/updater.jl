using Pkg
using Downloads
using JSON3
using Dates

"""
    update_package()

Update the PythonBenchmarker package to the latest version from the repository.
This function downloads the latest version and updates all files.
"""
function update_package()
    println("🔄 Starting PythonBenchmarker update...")
    
    try
        # Get current directory
        current_dir = pwd()
        backup_dir = joinpath(current_dir, "backup_$(Dates.format(now(), "yyyy-mm-dd_HH-MM-SS"))")
        
        println("📦 Creating backup at: $backup_dir")
        
        # Create backup directory
        mkdir(backup_dir)
        
        # Backup current files
        backup_files = ["src", "Project.toml", "Manifest.toml", "README.md", "benchmark.jl", "portable_cli.jl"]
        for file in backup_files
            if isfile(file) || isdir(file)
                if isdir(file)
                    cp(file, joinpath(backup_dir, file), force=true)
                else
                    cp(file, joinpath(backup_dir, basename(file)), force=true)
                end
                println("✅ Backed up: $file")
            end
        end
        
        # Download latest version
        repo_url = "https://api.github.com/repos/victorcynzo/julia-python-benchmark/contents"
        temp_dir = mktempdir()
        
        println("🌐 Downloading latest version...")
        
        # Download main files
        main_files = [
            "benchmark.jl",
            "portable_cli.jl", 
            "build_executable.jl",
            "create_executables.jl",
            "create_distribution.jl",
            "Project.toml",
            "README.md",
            "example_python_script.py"
        ]
        
        for file in main_files
            try
                file_url = "https://raw.githubusercontent.com/victorcynzo/julia-python-benchmark/main/$file"
                Downloads.download(file_url, joinpath(temp_dir, file))
                println("✅ Downloaded: $file")
            catch e
                println("⚠️  Warning: Could not download $file - $e")
            end
        end
        
        # Download src directory files
        src_files = [
            "PythonBenchmarker.jl",
            "benchmark_runner.jl",
            "results_analyzer.jl", 
            "reporter.jl",
            "cli.jl",
            "updater.jl"
        ]
        
        src_temp_dir = joinpath(temp_dir, "src")
        mkdir(src_temp_dir)
        
        for file in src_files
            try
                file_url = "https://raw.githubusercontent.com/victorcynzo/julia-python-benchmark/main/src/$file"
                Downloads.download(file_url, joinpath(src_temp_dir, file))
                println("✅ Downloaded: src/$file")
            catch e
                println("⚠️  Warning: Could not download src/$file - $e")
            end
        end
        
        # Update files
        println("📝 Updating files...")
        
        for file in main_files
            temp_file = joinpath(temp_dir, file)
            if isfile(temp_file)
                cp(temp_file, file, force=true)
                println("✅ Updated: $file")
            end
        end
        
        # Update src directory
        if isdir(src_temp_dir)
            for file in src_files
                temp_file = joinpath(src_temp_dir, file)
                target_file = joinpath("src", file)
                if isfile(temp_file)
                    cp(temp_file, target_file, force=true)
                    println("✅ Updated: src/$file")
                end
            end
        end
        
        # Update dependencies
        println("📦 Updating dependencies...")
        Pkg.activate(".")
        Pkg.resolve()
        Pkg.instantiate()
        
        println("🎉 Update completed successfully!")
        println("📁 Backup created at: $backup_dir")
        println("🔧 To restore from backup if needed, copy files from backup directory")
        
        # Clean up temp directory
        rm(temp_dir, recursive=true, force=true)
        
        return true
        
    catch e
        println("❌ Update failed: $e")
        println("💡 You can manually download the latest version from:")
        println("   https://github.com/victorcynzo/julia-python-benchmark")
        return false
    end
end

"""
    check_for_updates()

Check if updates are available for PythonBenchmarker.
"""
function check_for_updates()
    println("🔍 Checking for updates...")
    
    try
        # Get current version from Project.toml
        project_file = "Project.toml"
        if !isfile(project_file)
            println("❌ Project.toml not found")
            return false
        end
        
        current_version = "unknown"
        open(project_file, "r") do f
            for line in eachline(f)
                if startswith(line, "version")
                    current_version = strip(split(line, "=")[2], ['"', ' '])
                    break
                end
            end
        end
        
        println("📦 Current version: $current_version")
        
        # Check remote version (simplified - in real implementation would check GitHub releases)
        println("🌐 Checking remote repository...")
        println("💡 To check for the latest version, visit:")
        println("   https://github.com/victorcynzo/julia-python-benchmark/releases")
        
        return true
        
    catch e
        println("❌ Failed to check for updates: $e")
        return false
    end
end