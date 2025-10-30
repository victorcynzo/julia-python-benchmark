# Python Benchmarker

A comprehensive Julia-based benchmarking tool for Python scripts featuring process isolation, statistical analysis, memory profiling, and performance visualization.

## Version

**Current Version: v1.0.4 Alpha**

### Major Changes (v1.0.4)

**Remote Directory Support (v1.0.4)**: This version introduces the `--path` option that allows users to benchmark Python scripts in any directory without copying them to the benchmark folder:

- **Working Directory Specification**: Use `--path` to specify the directory where Python scripts should run
- **Cross-Platform Path Support**: Works with both Windows (`C:\path\to\scripts`) and Unix (`/path/to/scripts`) paths
- **Resource Access**: Python scripts can access files and resources in their original directory
- **No File Copying Required**: Benchmark scripts in their native environment without moving files
- **Automatic UTF-8 Encoding**: Enhanced Unicode support for Python scripts with progress bars on Windows
- **Enhanced Error Reporting**: Improved error messages showing actual Python script output

**Usage:**
```bash
# Benchmark a script in a different directory
julia benchmark.jl my_script.py --path "C:\Users\username\Documents\project"

# With Python script arguments
julia benchmark.jl script.py \
    --path "/home/user/projects/ml" \
    --python-args input.csv output.csv \
    --iterations 20
```

**Advanced Batch Processing System (v1.0.4)**: This version also introduces comprehensive batch processing capabilities that allow users to benchmark multiple Python scripts simultaneously with unified analysis and visualization:

- **Multi-Script Benchmarking**: Benchmark multiple scripts in a single command using `--batch-scripts`
- **Unified Output Analysis**: Combined CSV exports with all script results in one file
- **Comparative Visualizations**: Multi-line time series plots with color-coded legends for each script
- **Performance Comparison Charts**: Bar charts, overlapping histograms, and quartile comparisons
- **Statistical Summary Tables**: Side-by-side performance metrics with automatic fastest/slowest identification
- **Organized Batch Output**: All results consolidated in timestamped `batch-results-{timestamp}/` directories
- **Flexible Processing Modes**: Run individual benchmarks or create combined unified outputs

**Key Features:**
- **Combined CSV Export**: Single file containing all scripts' execution data with separate summary statistics
- **Multi-Color Plots**: Time series, distributions, and comparison charts with legends
- **Performance Highlights**: Automatic identification of fastest/slowest scripts with speedup calculations
- **Comprehensive Statistics**: Mean, median, percentiles, stability ratings for all scripts
- **Memory Comparison**: Peak memory usage comparison across scripts (when available)

**Usage:**
```bash
# Batch processing with combined analysis
julia benchmark.jl main_script.py \
    --batch-scripts "script2.py,script3.py,script4.py" \
    --batch-combine \
    --iterations 20 \
    --plots

# Simple batch without combined outputs
julia benchmark.jl script1.py \
    --batch-scripts "script2.py,script3.py" \
    --iterations 10
```

This feature transforms the benchmarker from a single-script tool into a comprehensive multi-script performance analysis platform, enabling direct comparison and analysis of multiple algorithms or implementations in a single unified workflow.

### Major Changes (v1.0.3)

**Auto-Update System (v1.0.3)**: This version introduces a comprehensive built-in update system that allows users to easily update their PythonBenchmarker installation:

- **Simple Update Command**: Use `--update` flag to check for and install updates automatically
- **Automatic Backup System**: Creates timestamped backups before updating to ensure safe rollback
- **Interactive Confirmation**: Prompts user before proceeding with potentially disruptive updates
- **Dependency Management**: Automatically resolves and updates all project dependencies
- **Safe Update Process**: Comprehensive error handling with detailed rollback instructions
- **Cross-Platform Support**: Works seamlessly on Windows, macOS, and Linux systems

**Usage:**
```bash
# Update to latest version
julia benchmark.jl --update

# Or using portable CLI
julia portable_cli.jl --update
```

The update system handles self-updating gracefully by creating comprehensive backups before making any changes, ensuring users can always rollback if needed. This feature significantly improves the user experience by eliminating the need for manual updates while maintaining safety through automatic backup creation.

### Major Changes (v1.0.2)

**GUI Removal**: This version removes all GUI functionality to focus exclusively on command-line interface usage. The tool now provides:

- **Streamlined CLI-only experience** with no GUI dependencies
- **Reduced installation complexity** - no Blink.jl or web browser requirements
- **Faster startup times** without GUI initialization overhead
- **Better server/headless compatibility** for automated benchmarking workflows

**Windows Executable Note**: If you encounter "This app can't run on your PC" error with .exe files, use these alternatives:

- **Recommended**: Double-click `.bat` files (PythonBenchmarker-CLI.bat)
- **Alternative**: Double-click `.lnk` shortcut files for a more executable-like experience  
- **PowerShell**: Right-click `.ps1` files and select "Run with PowerShell"

All methods provide identical functionality.

This is an alpha release of Python Benchmarker, representing the first stable implementation of our comprehensive benchmarking framework. While feature-complete and thoroughly tested, this alpha designation indicates ongoing refinement of the user experience and API stability. The core benchmarking engine, statistical analysis capabilities, and cross-platform compatibility have been validated across multiple environments. Users can expect reliable performance measurements and accurate statistical insights, with continued improvements in upcoming releases based on community feedback and real-world usage patterns.

### Recent Fixes and Improvements (v1.0.0)

**CLI Functionality Enhancements:**
- Fixed function name mismatch in `portable_cli.jl` (main_cli → main)
- Added comprehensive exports for all CLI functions in main module
- Resolved StatsPlots dependency issue with graceful fallback for boxplot functionality
- Enhanced cross-platform compatibility for plot generation

**Robustness Improvements:**
- All CLI features thoroughly tested and validated
- Improved error handling for missing optional dependencies
- Enhanced Windows PowerShell compatibility for installation commands
- Added fallback visualization options when advanced plotting libraries unavailable

## Table of Contents
- [How It Works](#how-it-works)
- [Features](#features)
- [Installation](#installation)
- [Usage Guide](#usage-guide)
- [Output Files & Examples](#output-files--examples)
- [Creating Standalone Executables](#creating-standalone-executables)
- [Architecture](#architecture)
- [Troubleshooting](#troubleshooting)

## How It Works

The Python Benchmarker operates through a sophisticated multi-stage process:

### 1. Process Isolation
Each Python script execution runs in a completely isolated process using Julia's `Cmd` system. This ensures:
- No memory contamination between runs
- Clean environment for each execution
- Accurate memory measurements
- Protection against script crashes affecting the benchmarker

### 2. Execution Pipeline
```
Warmup Runs → Benchmark Iterations → Statistical Analysis → Report Generation
```

**Warmup Phase**: Runs the script multiple times to:
- Stabilize system caches
- Allow JIT compilation to complete
- Establish baseline system state

**Benchmark Phase**: Executes the script for the specified number of iterations, capturing:
- Wall-clock execution time (nanosecond precision)
- Memory usage (peak and average)
- Success/failure status
- Standard output and error streams

**Analysis Phase**: Processes collected data to compute:
- Descriptive statistics (mean, median, standard deviation)
- Percentile distributions (25th, 50th, 75th, 90th, 95th, 99th)
- Outlier detection using IQR and Z-score methods
- Stability metrics and coefficient of variation

### 3. Memory Tracking
- **Windows**: Basic process execution timing
- **Unix/Linux**: Uses `/usr/bin/time` command for detailed memory statistics
- Captures peak memory usage in kilobytes, converted to bytes for analysis

### 4. Statistical Analysis Engine
- **Regression Detection**: Compares current results against baseline using statistical significance testing
- **Outlier Identification**: Multiple methods (IQR, Z-score) to identify anomalous runs
- **Stability Assessment**: Coefficient of variation analysis with qualitative ratings

## Features

### Core Benchmarking Capabilities
- ✅ **Process Isolation**: Complete isolation between benchmark runs
- ✅ **High-Precision Timing**: Nanosecond-level execution time measurement
- ✅ **Memory Profiling**: Peak and average memory usage tracking
- ✅ **Statistical Analysis**: Comprehensive statistical metrics and distributions
- ✅ **Regression Detection**: Automated performance regression identification
- ✅ **Outlier Detection**: Multiple algorithms for anomaly identification
- ✅ **Stability Metrics**: Coefficient of variation and consistency analysis

### Visualization & Export
- ✅ **Performance Plots**: Histograms, time series, quartile plots, comparison charts
- ✅ **Data Export**: CSV (raw data) and JSON (complete results) formats
- ✅ **Baseline Comparison**: Visual and statistical comparison against previous runs
- ✅ **Command-Line Interface**: Comprehensive CLI with extensive options (GUI removed in v1.0.2)

### Advanced Features
- ✅ **Configurable Parameters**: Iterations, warmup runs, timeouts
- ✅ **Python Arguments**: Pass custom arguments to benchmarked scripts
- ✅ **Remote Directory Support**: Benchmark scripts in any directory using `--path` option
- ✅ **Cross-Platform**: Windows, macOS, and Linux support
- ✅ **Standalone Executables**: No Julia runtime required for end users (CLI only)

### Batch Processing Features (New in v1.0.4)
- ✅ **Multi-Script Benchmarking**: Benchmark multiple scripts simultaneously
- ✅ **Unified Analysis**: Combined CSV/JSON exports with all script results
- ✅ **Comparative Visualizations**: Multi-line plots with color-coded legends
- ✅ **Performance Comparison**: Bar charts, distributions, quartile analysis
- ✅ **Statistical Summaries**: Side-by-side performance metrics and rankings
- ✅ **Batch Output Organization**: Consolidated results in organized directories

## Installation

### Prerequisites
- **Julia**: Version 1.6 or higher ([Download Julia](https://julialang.org/downloads/))
- **Python**: Version 3.6 or higher (for scripts being benchmarked)
- **Git**: For cloning the repository

### Step-by-Step Installation

#### Method 1: Direct Download and Setup

1. **Install Julia**
   
   **Windows:**
   - Download from [julialang.org](https://julialang.org/downloads/)
   - Run the installer and follow the setup wizard
   - Add Julia to PATH when prompted
   
   **macOS:**
   ```bash
   # Using Homebrew (recommended)
   brew install julia
   
   # Or download from julialang.org
   ```
   
   **Linux (Ubuntu/Debian):**
   ```bash
   sudo apt update
   sudo apt install julia
   
   # Or for latest version:
   wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.0-linux-x86_64.tar.gz
   tar -xzf julia-1.10.0-linux-x86_64.tar.gz
   sudo mv julia-1.10.0 /opt/
   sudo ln -s /opt/julia-1.10.0/bin/julia /usr/local/bin/julia
   ```

2. **Verify Julia Installation**
   ```bash
   julia --version
   # Should output: julia version 1.x.x
   ```

3. **Clone the Repository**
   ```bash
   git clone https://github.com/victorcynzo/julia-python-benchmark
   cd julia-python-benchmark
   ```

4. **Install Dependencies**
   ```bash
   # Automatic installation (recommended)
   julia --project=. -e "using Pkg; Pkg.instantiate()"
   
   # Manual installation if automatic fails
   julia --project=. -e "using Pkg; Pkg.add([\"ArgParse\", \"BenchmarkTools\", \"CSV\", \"DataFrames\", \"JSON3\", \"Plots\", \"Statistics\", \"StatsBase\", \"Dates\", \"PlotlyJS\"])"
   ```

5. **Verify Installation**
   ```bash
   julia benchmark.jl --help
   # Should display help information
   ```

6. **Test with Example Script**
   ```bash
   julia benchmark.jl example_python_script.py --iterations 5
   # Should run successfully and create output directory
   ```

#### Method 2: Portable Installation

If you need to run the benchmarker without modifying system Julia packages:

1. **Download and Extract**
   ```bash
   git clone https://github.com/victorcynzo/julia-python-benchmark
   cd julia-python-benchmark
   ```

2. **Use Portable CLI**
   ```bash
   julia portable_cli.jl example_python_script.py --help
   # Automatically handles project activation
   ```

#### Method 3: Standalone Executable (Advanced)

For creating executables that don't require Julia installation on target machines, see the [Creating Standalone Executables](#creating-standalone-executables) section below.

### Alternative: Manual Dependency Installation
If automatic installation fails:
```julia
julia --project=.
using Pkg
Pkg.add(["ArgParse", "BenchmarkTools", "CSV", "DataFrames", "JSON3", "Plots", "Statistics", "StatsBase", "Dates", "PlotlyJS"])
```

### Installation Troubleshooting

**Common Issues and Solutions:**

1. **Precompilation Errors with Broken Function Declarations**
   - **Error**: `syntax: unsupported 'const' declaration on local variable` or `ParseError: Expected 'end'`
   - **Solution**: These syntax errors have been fixed in the current version. Ensure you have the latest code.

2. **Dependency Resolution Issues**
   - **Error**: Package conflicts or missing dependencies
   - **Solution**: Use `julia --project=. -e "using Pkg; Pkg.resolve(); Pkg.instantiate()"`

3. **Missing Dependencies**
   ```bash
   julia --project=. -e "using Pkg; Pkg.resolve(); Pkg.instantiate()"
   ```

4. **Windows PowerShell Command Line Issues**
   - **Error**: `invalid escape sequence` when running Julia commands with quotes
   - **Solutions**:
   
   **Method 1: Create a temporary Julia script file**
   ```powershell
   # Instead of: julia -e "using Pkg; Pkg.add(\"PlotlyJS\")"
   # Create a temporary script file (this creates the file for you):
   echo 'using Pkg; Pkg.add("PlotlyJS")' > temp_install.jl
   # Run the script:
   julia --project=. temp_install.jl
   # Clean up the temporary file:
   del temp_install.jl
   ```
   
   **Note:** The `temp_install.jl` file doesn't need to exist beforehand - the `echo` command creates it for you with the Julia code inside.
   
   **Method 2: Use the Julia REPL directly**
   ```powershell
   # Start Julia REPL
   julia --project=.
   # Then in the Julia REPL, type:
   # using Pkg
   # Pkg.add("PlotlyJS")
   # exit()
   ```
   
   **Method 3: Use single quotes instead of double quotes**
   ```powershell
   julia --project=. -e 'using Pkg; Pkg.add("PlotlyJS")'
   ```

   **Method 4: For complex Julia commands with project activation**
   ```powershell
   # Instead of problematic inline commands, use the portable CLI:
   julia portable_cli.jl script.py --iterations 5 --plots
   
   # Or create a temporary script for complex operations:
   echo 'using Pkg; Pkg.activate("."); using PythonBenchmarker; main()' > temp_run.jl
   julia temp_run.jl script.py --iterations 5 --plots
   del temp_run.jl
   ```

5. **Missing Plot Dependencies**
   - The tool works without plotting libraries but won't generate visualizations
   - Install PlotlyJS.jl for full plotting functionality

6. **Module Loading Issues**
   ```bash
   # Test if module loads correctly
   julia --project=. -e "using PythonBenchmarker"
   ```

## Usage Guide

### Command Line Interface

Python Benchmarker provides a comprehensive CLI with extensive options for professional performance analysis.

#### Quick Start

**1. Simple Benchmark (Default Settings)**
```bash
julia benchmark.jl example_python_script.py
```
This runs 10 iterations with 3 warmup runs and creates organized output in `test-results-{script}-{timestamp}/`

**2. Basic Customization**
```bash
julia benchmark.jl example_python_script.py --iterations 20 --warmup 5
```

**3. With Visualization**
```bash
julia benchmark.jl example_python_script.py --plots
```
Generates performance plots in the output directory

#### Detailed CLI Usage

**Complete Syntax:**
```bash
julia benchmark.jl <python_file> [OPTIONS]
```

**Essential Options:**
- `--iterations, -i`: Number of benchmark runs (default: 10)
- `--warmup, -w`: Number of warmup runs (default: 3)
- `--timeout, -t`: Timeout per run in seconds (default: 300.0)
- `--plots`: Generate performance visualization plots
- `--quiet, -q`: Suppress detailed output
- `--path, -p`: Working directory path for Python script execution

**Advanced Options:**
- `--no-memory`: Disable memory tracking (useful for Windows)
- `--output-csv FILE`: Export raw data to custom CSV file
- `--output-json FILE`: Export complete results to custom JSON file
- `--plot-dir DIR`: Custom directory for plots (default: "plots")
- `--baseline FILE`: Compare against previous results from JSON file
- `--python-args ARG1 ARG2...`: Pass arguments to the Python script
- `--path DIR`: Specify working directory for Python script execution (allows benchmarking scripts in different folders without copying them)

**Batch Processing Options:**
- `--batch-scripts LIST`: Comma-separated list of additional scripts to benchmark
- `--batch-combine`: Create unified outputs combining all script results (CSV, JSON, plots)

#### Portable CLI Usage

For environments where you can't modify the project directory:
```bash
julia portable_cli.jl example_python_script.py [OPTIONS]
```
This script automatically handles project activation and dependencies.

### Organized Output Directories

**Automatic Organization (New in v1.0.0)**

All output files are automatically organized into timestamped directories:
```
test-results-{script_name}-{timestamp}/
├── benchmark_results.csv      # Always created
├── benchmark_results.json     # Always created
├── plots/                     # If --plots specified
│   ├── time_distribution.png
│   ├── time_series.png
│   └── quartiles.png
└── comparison.png             # If --baseline specified
```

**Example Output Structure**
```bash
julia portable_cli.jl my_algorithm.py --plots
# Creates: test-results-my_algorithm-2025-10-29_10-30-15/
```

**Benefits:**
- ✅ **No file conflicts** - Each run gets its own directory
- ✅ **Easy organization** - Results grouped by script and timestamp
- ✅ **Automatic exports** - CSV and JSON always generated
- ✅ **Clean workspace** - No clutter in main directory

### Comprehensive Usage Examples

#### 1. Quick Performance Check
```bash
# Basic benchmark with default settings
julia benchmark.jl my_algorithm.py

# With visualization
julia benchmark.jl my_algorithm.py --plots
```

#### 2. Detailed Performance Analysis
```bash
# Comprehensive analysis with custom settings
julia benchmark.jl my_script.py \
    --iterations 50 \
    --warmup 10 \
    --plots \
    --plot-dir detailed_analysis \
    --output-json results_$(date +%Y%m%d).json
```

#### 3. Regression Testing Workflow
```bash
# Step 1: Establish baseline
julia benchmark.jl script.py \
    --iterations 30 \
    --output-json baseline_v1.json \
    --plots

# Step 2: Test after changes
julia benchmark.jl script.py \
    --iterations 30 \
    --baseline baseline_v1.json \
    --output-json current_v2.json \
    --plots
```

#### 4. Memory-Intensive Script Analysis
```bash
# For scripts with high memory usage
julia benchmark.jl memory_heavy_script.py \
    --iterations 20 \
    --timeout 600 \
    --plots \
    --plot-dir memory_analysis
```

#### 5. Script with Arguments
```bash
# Benchmark a Python script that takes arguments
julia benchmark.jl data_processor.py \
    --python-args input.csv --output results.csv --threads 4 \
    --iterations 15 \
    --plots
```

#### 6. Batch Processing Multiple Scripts (New in v1.0.4)

**Individual Processing (Original Method):**
```bash
# Benchmark multiple scripts in sequence (separate outputs)
for script in algorithm1.py algorithm2.py algorithm3.py; do
    julia benchmark.jl $script --iterations 25 --plots --quiet
done
```

**Combined Batch Processing (New Feature):**
```bash
# Benchmark multiple scripts with combined analysis
julia benchmark.jl main_script.py \
    --batch-scripts "script2.py,script3.py,script4.py" \
    --batch-combine \
    --iterations 20 \
    --plots

# Simple batch without combined analysis
julia benchmark.jl script1.py \
    --batch-scripts "script2.py,script3.py" \
    --iterations 10
```

**Batch Processing Features:**
- ✅ **Combined CSV Export**: Single file with all script results
- ✅ **Summary Statistics**: Comparative analysis across scripts
- ✅ **Multi-line Plots**: Time series with different colors per script
- ✅ **Performance Comparison**: Bar charts, distributions, quartiles
- ✅ **Unified Output Directory**: All results in one organized location
- ✅ **Performance Highlights**: Fastest/slowest script identification

#### 7. Production Performance Monitoring
```bash
# Automated performance monitoring
julia benchmark.jl production_script.py \
    --iterations 100 \
    --baseline production_baseline.json \
    --output-json "monitoring_$(date +%Y%m%d_%H%M%S).json" \
    --quiet
```

#### 8. Remote Directory Testing
```bash
# Benchmark a Python script in a different directory
julia benchmark.jl my_script.py \
    --path "C:\Users\username\Documents\path" \
    --iterations 20 \
    --plots

# With Python script arguments (common case)
julia benchmark.jl my_script.py \
    --path "C:\Users\username\Documents\path" \
    --python-args my_video.mp4 output/ \
    --iterations 5

# Unix/Linux/macOS equivalent
julia benchmark.jl my_script.py \
    --path "/home/user/projects/machine-learning" \
    --python-args input.csv --output results.csv \
    --iterations 20 \
    --plots
```

#### 9. Cross-Platform Testing
```bash
# Windows (PowerShell)
julia benchmark.jl script.py --iterations 20 --plots

# Unix/Linux/macOS
julia benchmark.jl script.py --iterations 20 --plots
```

### Command Line Options Reference

| Option | Short | Type | Default | Description |
|--------|-------|------|---------|-------------|
| `python_file` | - | String | Required | Python script to benchmark |
| `--iterations` | `-i` | Integer | 10 | Number of benchmark runs |
| `--warmup` | `-w` | Integer | 3 | Number of warmup runs |
| `--timeout` | `-t` | Float | 300.0 | Timeout per run (seconds) |
| `--no-memory` | - | Flag | false | Disable memory tracking |
| `--output-csv` | - | String | - | CSV export filename |
| `--output-json` | - | String | - | JSON export filename |
| `--plots` | - | Flag | false | Generate visualization plots |
| `--plot-dir` | - | String | "plots" | Plot output directory |
| `--baseline` | - | String | - | Baseline JSON for comparison |
| `--python-args` | - | Array | [] | Arguments for Python script |
| `--quiet` | `-q` | Flag | false | Suppress detailed output |
| `--path` | `-p` | String | - | Working directory path for Python script execution |
| `--batch-scripts` | - | String | - | Additional Python scripts for batch processing (comma-separated) |
| `--batch-combine` | - | Flag | false | Combine batch results into unified outputs |

## Output Files & Examples

### Organized Output Structure (v1.0.0+)

All benchmark results are automatically organized into timestamped directories:

**Single Script Mode:**
```
test-results-{python_file_name}-{timestamp}/
├── benchmark_results.csv          # Detailed run data (always created)
├── benchmark_results.json         # Complete results (always created)
├── plots/                          # Performance visualizations (if --plots)
│   ├── time_distribution.png       # Execution time histogram
│   ├── time_series.png            # Time series plot
│   └── quartiles.png               # Statistical quartiles
├── custom_output.csv               # Custom CSV (if --output-csv specified)
├── custom_output.json              # Custom JSON (if --output-json specified)
└── comparison.png                  # Baseline comparison (if --baseline used)
```

**Batch Processing Mode (with --batch-combine):**
```
batch-results-{timestamp}/
├── combined_results.csv            # All scripts' raw data in one file
├── combined_results_summary.csv    # Statistical summary for all scripts
├── combined_results.json           # Complete batch results
└── plots/                          # Combined visualizations (if --plots)
    ├── execution_time_comparison.png    # Bar chart comparing mean times
    ├── combined_time_series.png         # Multi-line time series (colored by script)
    ├── combined_distributions.png       # Overlapping histograms
    ├── combined_quartiles.png           # Quartile comparison
    └── memory_comparison.png            # Memory usage comparison (if available)
```

**Example Directory Names:**
- `test-results-my_script-2025-10-29_10-30-15/` (single script)
- `test-results-algorithm_test-2025-10-29_14-22-08/` (single script)
- `batch-results-2025-10-29_16-45-33/` (batch processing)

### 1. Console Output

**Standard Benchmark Output:**
```
Created output directory: test-results-example_python_script-2025-10-29_10-30-15
Starting benchmark of example_python_script.py
Iterations: 10, Warmup: 3
Running warmup...
Running benchmark iterations...
Run 1/10... ✓ 0.2341s
Run 2/10... ✓ 0.1987s
Run 3/10... ✓ 0.2156s
Run 4/10... ✓ 0.2089s
Run 5/10... ✓ 0.2234s
Run 6/10... ✓ 0.1876s
Run 7/10... ✓ 0.2456s
Run 8/10... ✓ 0.2134s
Run 9/10... ✓ 0.2567s
Run 10/10... ✓ 0.2298s

============================================================
BENCHMARK RESULTS SUMMARY
============================================================
File: example_python_script.py
Timestamp: 2025-10-28T14:30:45.123
Successful runs: 10/10

TIMING RESULTS:
  Mean:     0.2214s
  Median:   0.2195s
  Std Dev:  0.0201s
  Min:      0.1876s
  Max:      0.2567s

PERCENTILES:
  25th:     0.2067s
  50th:     0.2195s
  75th:     0.2346s
  90th:     0.2512s
  95th:     0.2540s
  99th:     0.2567s

MEMORY USAGE:
  Mean:     12.34 MB
  Peak:     15.67 MB

STABILITY ANALYSIS:
  Coefficient of Variation: 9.08%
  Outliers: 0 (0.0%)
  Stability Rating: Excellent
============================================================
Detailed results exported to: test-results-example_python_script-2025-10-29_10-30-15\benchmark_results.csv
Complete results exported to: test-results-example_python_script-2025-10-29_10-30-15\benchmark_results.json
```

**Regression Detection Output:**
```
BASELINE COMPARISON:
Time change: +12.34%
⚠️  Performance regression detected!

Comparison plot saved to: comparison.png
```

### 2. JSON Export (`--output-json results.json`)

**Complete Results Structure:**
```json
{
  "config": {
    "python_file": "example_python_script.py",
    "iterations": 10,
    "warmup_runs": 3,
    "timeout_seconds": 300.0,
    "memory_tracking": true,
    "python_args": ["25"]
  },
  "results": {
    "timestamp": "2025-10-28T14:30:45.123",
    "success_count": 10,
    "execution_times": [
      0.2341, 0.1987, 0.2156, 0.2089, 0.2234,
      0.1876, 0.2456, 0.2134, 0.2567, 0.2298
    ],
    "memory_usage": [
      12582912, 13107200, 12845056, 13369344, 12320768,
      14680064, 13631488, 12058624, 16777216, 13893632
    ],
    "failed_runs": [],
    "statistics": {
      "mean_time": 0.2214,
      "median_time": 0.2195,
      "std_time": 0.0201,
      "min_time": 0.1876,
      "max_time": 0.2567,
      "percentiles": {
        "25": 0.2067,
        "50": 0.2195,
        "75": 0.2346,
        "90": 0.2512,
        "95": 0.2540,
        "99": 0.2567
      },
      "mean_memory": 12934041.6,
      "peak_memory": 16777216
    }
  }
}
```

### 3. CSV Export (`--output-csv data.csv`)

**Raw Data Format:**
```csv
run_number,execution_time,memory_usage
1,0.2341,12582912
2,0.1987,13107200
3,0.2156,12845056
4,0.2089,13369344
5,0.2234,12320768
6,0.1876,14680064
7,0.2456,13631488
8,0.2134,12058624
9,0.2567,16777216
10,0.2298,13893632
```

### 4. Visualization Plots (`--plots`)

**Generated Plot Files:**
- `plots/time_distribution.png` - Histogram of execution times
- `plots/time_series.png` - Time series plot with mean line
- `plots/quartiles.png` - Quartile visualization (or `box_plot.png` if StatsPlots available)
- `plots/memory_usage.png` - Memory usage over time (if available)
- `comparison.png` - Baseline comparison (if `--baseline` used)

**Plot Descriptions:**

**Time Distribution Histogram:**
- X-axis: Execution time (seconds)
- Y-axis: Frequency
- Shows distribution shape and identifies clustering

**Time Series Plot:**
- X-axis: Run number
- Y-axis: Execution time (seconds)
- Includes mean line for reference
- Reveals trends and stability over runs

**Quartile Plot:**
- Shows median, quartiles, and outliers
- Identifies statistical distribution characteristics
- Highlights performance consistency
- Uses box plot if StatsPlots available, otherwise scatter plot with error bars

**Memory Usage Plot:**
- X-axis: Run number
- Y-axis: Memory usage (MB)
- Shows memory consumption patterns
- Identifies memory leaks or spikes

### 5. Comparison Analysis

**When using `--baseline previous.json`:**
```
BASELINE COMPARISON:
Time change: -5.67%
Memory change: +2.34%
✅ Performance improvement detected!

Statistical significance: Yes (t-statistic: 3.45)
```

## Creating Standalone Executables

### Automated Build Process (Recommended)

The project includes two build scripts for creating executables:

**Important:** Both build processes require Julia to be installed on the BUILD machine where you run these commands.

**Option 1: True Standalone Executables (Recommended)**
```bash
julia build_executable.jl
```
- **Build requirement:** Julia must be installed on the machine where you run this command
- **Runtime requirement:** The resulting executables do NOT require Julia on target machines
- Creates true standalone executables using PackageCompiler.jl

**Option 2: Wrapper Scripts**
```bash
julia create_executables.jl
```
- **Build requirement:** Julia must be installed on the machine where you run this command  
- **Runtime requirement:** The resulting scripts DO require Julia on target machines
- Creates wrapper scripts (.bat files on Windows, shell scripts on Unix)

**build_executable.jl will:**
1. **Install all dependencies** including PackageCompiler.jl
2. **Build CLI executable** for command-line usage
3. **Create distribution package** with all files and documentation
4. **Generate platform-specific** executables (.exe on Windows)

### Build Output Structure

After running the build script, you'll find:

```
build/
├── PythonBenchmarker-CLI.exe          # CLI executable (Windows)
├── PythonBenchmarker-CLI              # CLI executable (Unix/Linux)
└── PythonBenchmarker-Distribution/    # Complete distribution package
    ├── PythonBenchmarker-CLI.exe
    ├── example_python_script.py
    ├── README.md
    └── USAGE.txt
```

### Summary of Build Methods

| Aspect | Executable CLI (`build_executable.jl`) | Wrapper Scripts (`create_executables.jl`) |
|--------|----------------------------------------|-------------------------------------------|
| **Julia Required** | ❌ No | ✅ Yes |
| **File Size** | Large (~100MB+) | Small (~1KB) |
| **Startup Speed** | Fast | Slower (Julia startup) |
| **Distribution** | Self-contained | Requires Julia ecosystem |
| **Modification** | Requires rebuild | Direct source editing |
| **Best For** | End-user distribution | Development/Julia environments |

**Recommendation:** Use `build_executable.jl` for distributing to end users who don't have Julia installed. Use `create_executables.jl` for environments where Julia is already available and you want lightweight, easily modifiable scripts.

### Manual Build Process

If you prefer manual control:

**1. Install PackageCompiler:**
```julia
using Pkg
Pkg.add("PackageCompiler")
```

**2. Build CLI Version:**
```julia
using PackageCompiler

create_app(".", "PythonBenchmarker-CLI", 
           executables=["benchmark" => "benchmark.jl"],
           force=true)
```

**Note:** GUI version has been removed in v1.0.2. Only CLI executable is available.

### Distribution

**For True Standalone Executables (from build_executable.jl):**
The executables in the `PythonBenchmarker-Distribution` folder are completely standalone:
- **No Julia installation required** on target machines
- **No dependency management** needed
- **Cross-platform compatible** (build on target OS)
- **Self-contained** with all required libraries

**For Wrapper Scripts (from create_executables.jl):**
The scripts in the distribution folder require:
- **Julia must be installed** on target machines
- **Project dependencies** must be available
- **Suitable for environments** where Julia is already installed

### Usage of Compiled Executables

**True Standalone Executables (from build_executable.jl):**
```bash
# Windows
PythonBenchmarker-CLI.exe script.py --iterations 20

# Unix/Linux/macOS
./PythonBenchmarker-CLI script.py --iterations 20
```

**Wrapper Scripts (from create_executables.jl):**
```bash
# Windows
PythonBenchmarker-CLI.bat script.py --iterations 20

# Unix/Linux/macOS
./PythonBenchmarker-CLI script.py --iterations 20
```

**Key Difference:** 
- **True standalone executables** (.exe files from build_executable.jl) don't require Julia on target machines
- **Wrapper scripts** (.bat/.sh files from create_executables.jl) require Julia to be installed on target machines

## Architecture

### Core Components

**1. `src/benchmark_runner.jl`**
- Process isolation and execution management
- Timing and memory measurement
- Error handling and timeout management
- Cross-platform compatibility layer

**2. `src/results_analyzer.jl`**
- Statistical analysis algorithms
- Regression detection using t-tests
- Outlier identification (IQR, Z-score methods)
- Stability metrics calculation

**3. `src/reporter.jl`**
- Console output formatting
- CSV and JSON export functionality
- Plot generation using Plots.jl
- Comparison visualization

**4. `src/cli.jl`**
- Command-line argument parsing
- Configuration management
- Main execution flow coordination
- Primary user interface (GUI removed in v1.0.2)

### Data Flow Architecture

```
Python Script → Process Isolation → Timing/Memory Capture → 
Statistical Analysis → Report Generation → Export/Visualization
```

### Key Design Decisions

**Process Isolation**: Chosen over in-process execution to ensure clean measurements and prevent memory contamination.

**Statistical Focus**: Emphasis on robust statistical analysis rather than simple timing, providing confidence intervals and significance testing.

**Modular Design**: Separate concerns for easy maintenance and feature addition.

**Cross-Platform**: Handles Windows/Unix differences in memory tracking and process management.

## Troubleshooting

### Common Issues

**1. Julia Package Installation Fails**
```bash
# Clear package cache and retry
julia -e "using Pkg; Pkg.gc(); Pkg.resolve()"
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

**2. Python Script Not Found**
```bash
# Use absolute path
julia benchmark.jl /full/path/to/script.py

# Or ensure script is in current directory
ls -la *.py
```

**3. Memory Tracking Not Working (Windows)**
- Memory tracking is limited on Windows
- Use `--no-memory` flag to disable if causing issues
- Consider running on Unix/Linux for full memory analysis

**4. Plots Not Generating**
```julia
# Install plotting backend
julia -e "using Pkg; Pkg.add(\"GR\")"
```

**5. Permission Errors**
```bash
# Ensure Python script is executable
chmod +x script.py

# Check Julia permissions
julia --version
```

**6. CLI Function Errors (Fixed in v1.0.0)**
If you encounter `main_cli` not found errors:
```bash
# This has been fixed - portable_cli.jl now correctly calls main()
julia portable_cli.jl script.py --help
```

**7. Missing Export Errors (Fixed in v1.0.0)**
If you get "function not exported" errors:
```julia
# All CLI functions are now properly exported from PythonBenchmarker module
using PythonBenchmarker
# All functions now available: main, print_summary, export_to_csv, etc.
```

**8. StatsPlots/Boxplot Errors (Fixed in v1.0.0)**
If plot generation fails with boxplot errors:
```bash
# The tool now gracefully falls back to quartile plots when StatsPlots unavailable
julia portable_cli.jl script.py --plots
# Will generate: time_distribution.png, time_series.png, quartiles.png
```

**9. Python Script Requires Arguments**
If your Python script shows usage messages or fails with "missing arguments":
```bash
# Wrong: script expects arguments but none provided
julia benchmark.jl my_script.py --path /path/to/script

# Correct: provide required arguments using --python-args
julia benchmark.jl my_script.py --path /path/to/script --python-args input.txt output.txt

# Example with multiple arguments
julia benchmark.jl claude-gaze-detection.py \
    --path "C:\path\to\gaze-detection" \
    --python-args video.mp4 output/ --visualize
```

**10. Batch Processing Issues (New in v1.0.4)**
Common batch processing troubleshooting:
```bash
# Issue: Scripts not found in batch list
# Solution: Use full paths or ensure scripts are in working directory
julia benchmark.jl script1.py --batch-scripts "path/to/script2.py,./script3.py"

# Issue: Mixed success/failure in batch
# The tool continues with successful scripts and reports failures
# Check individual script outputs in the batch summary

# Issue: Memory issues with large batches
# Solution: Reduce iterations or process scripts individually
julia benchmark.jl script1.py --batch-scripts "script2.py" --iterations 5

# Issue: Plot generation fails with many scripts
# Solution: Ensure sufficient memory and consider fewer scripts per batch
julia benchmark.jl script1.py --batch-scripts "script2.py,script3.py" --batch-combine --plots
```

**11. Julia Command Syntax Issues on Windows**
If you encounter parsing errors with Julia -e commands:
```bash
# Issue: ParseError with julia -e commands containing quotes and dots
# Wrong: julia -e 'using Pkg; Pkg.activate("."); using PythonBenchmarker; main()'
# Solution: Use the portable CLI instead (recommended)
julia portable_cli.jl script.py --iterations 5 --plots

# Alternative: Create temporary script file
echo 'using Pkg; Pkg.activate("."); using PythonBenchmarker; main()' > temp.jl
julia temp.jl script.py --iterations 5 --plots
del temp.jl
```

### Performance Tips

**1. Optimal Iteration Count**
- Use 10-30 iterations for quick analysis
- Use 50-100 iterations for statistical significance
- Use 100+ iterations for publication-quality results

**2. Warmup Considerations**
- Increase warmup runs for JIT-compiled languages
- Use 3-5 warmup runs for typical Python scripts
- Use 10+ warmup runs for complex initialization

**3. Memory Analysis**
- Run on Unix/Linux systems for detailed memory tracking
- Use longer timeouts for memory-intensive scripts
- Monitor system resources during benchmarking

**4. Batch Processing Optimization (New in v1.0.4)**
- Start with fewer iterations (5-10) when testing multiple scripts
- Use `--batch-combine` for comprehensive analysis and comparison
- Limit batch size to 5-10 scripts for optimal performance
- Consider script execution time when planning batch runs
- Use meaningful script names for better visualization legends

This comprehensive benchmarking tool provides professional-grade performance analysis capabilities with detailed statistical insights and visualization options.
#
# License

This project is released under the MIT License. You are free to use, modify, and distribute this software for both personal and commercial purposes. The software is provided "as is" without warranty of any kind.

For the full license text, see the LICENSE file in the project repository.

---

**Python Benchmarker** - Professional performance analysis for Python scripts with statistical insights and cross-platform compatibility.