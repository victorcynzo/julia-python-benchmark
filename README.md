# Python Benchmarker

A comprehensive Julia-based benchmarking tool for Python scripts featuring process isolation, statistical analysis, memory profiling, and performance visualization.

## Version

**Current Version: v1.0.2 Alpha**

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
- [Creating Executables](#creating-executables)
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
- ✅ **Performance Plots**: Histograms, time series, box plots, comparison charts
- ✅ **Data Export**: CSV (raw data) and JSON (complete results) formats
- ✅ **Baseline Comparison**: Visual and statistical comparison against previous runs
- ✅ **Command-Line Interface**: Comprehensive CLI with extensive options (GUI removed in v1.0.2)

### Advanced Features
- ✅ **Configurable Parameters**: Iterations, warmup runs, timeouts
- ✅ **Python Arguments**: Pass custom arguments to benchmarked scripts
- ✅ **Batch Processing**: Support for multiple benchmark configurations
- ✅ **Cross-Platform**: Windows, macOS, and Linux support
- ✅ **Standalone Executables**: No Julia runtime required for end users (CLI only)

## Installation

### Prerequisites
- **Julia**: Version 1.6 or higher ([Download Julia](https://julialang.org/downloads/))
- **Python**: Version 3.6 or higher (for scripts being benchmarked)
- **Git**: For cloning the repository

### Step-by-Step Installation

1. **Install Julia**
   ```bash
   # On Ubuntu/Debian
   sudo apt install julia
   
   # On macOS with Homebrew
   brew install julia
   
   # On Windows: Download from julialang.org
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/victorcynzo/julia-python-benchmark
   cd julia-python-benchmark
   ```

3. **Install Julia Dependencies**
   ```bash
   julia --project=. -e "using Pkg; Pkg.instantiate()"
   ```

4. **Verify Installation**
   ```bash
   julia benchmark.jl --help
   ```

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

2. **JavaScript Template Literal Errors**
   - **Error**: `identifier or parenthesized expression expected after $ in string`
   - **Solution**: Fixed by properly escaping JavaScript template literals in GUI code.

3. **Missing Dependencies**
   ```bash
   julia --project=. -e "using Pkg; Pkg.resolve(); Pkg.instantiate()"
   ```

4. **Windows PowerShell Command Line Issues**
   - **Error**: `invalid escape sequence` when running Julia commands with quotes
   - **Solution**: Use Julia script files instead of inline commands, or use the Julia REPL directly

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

**Simple Benchmark**
```bash
julia benchmark.jl example_python_script.py
```

**With Custom Iterations**
```bash
julia benchmark.jl script.py --iterations 20 --warmup 5
```

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

### Advanced Usage Examples

**Complete Performance Analysis**
```bash
julia benchmark.jl my_script.py \
    --iterations 50 \
    --warmup 10 \
    --output-json results_$(date +%Y%m%d).json \
    --output-csv raw_data.csv \
    --plots \
    --plot-dir performance_charts \
    --python-args input.txt --verbose
```

**Regression Testing**
```bash
# First run (establish baseline)
julia benchmark.jl script.py --output-json baseline.json

# Later run (compare against baseline)
julia benchmark.jl script.py \
    --baseline baseline.json \
    --output-json current.json \
    --plots
```

**Memory-Intensive Analysis**
```bash
julia benchmark.jl memory_heavy_script.py \
    --iterations 30 \
    --timeout 600 \
    --plots \
    --plot-dir memory_analysis
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

## Output Files & Examples

### Organized Output Structure (v1.0.0+)

All benchmark results are automatically organized into timestamped directories:

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

**Example Directory Names:**
- `test-results-my_script-2025-10-29_10-30-15/`
- `test-results-algorithm_test-2025-10-29_14-22-08/`
- `test-results-performance_check-2025-10-29_16-45-33/`

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
- `plots/box_plot.png` - Box plot showing quartiles and outliers
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

**Box Plot:**
- Shows median, quartiles, and outliers
- Identifies statistical distribution characteristics
- Highlights performance consistency

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

The project includes a comprehensive build script that creates standalone executables for both CLI and GUI versions:

```bash
julia build_executable.jl
```

This script will:
1. **Install all dependencies** including PackageCompiler.jl
2. **Build CLI executable** for command-line usage
3. **Build GUI executable** for desktop application
4. **Create distribution package** with all files and documentation
5. **Generate platform-specific** executables (.exe on Windows)

### Build Output Structure

After running the build script, you'll find:

```
build/
├── PythonBenchmarker-CLI.exe          # CLI executable (Windows)
├── PythonBenchmarker-GUI.exe          # GUI executable (Windows)
├── PythonBenchmarker-CLI              # CLI executable (Unix/Linux)
├── PythonBenchmarker-GUI              # GUI executable (Unix/Linux)
└── PythonBenchmarker-Distribution/    # Complete distribution package
    ├── PythonBenchmarker-CLI.exe
    ├── PythonBenchmarker-GUI.exe
    ├── example_python_script.py
    ├── README.md
    └── USAGE.txt
```

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

**3. Build GUI Version:**
```julia
create_app(".", "PythonBenchmarker-GUI", 
           executables=["benchmark-gui" => "gui_launcher.jl"],
           force=true)
```

### Distribution

The executables in the `PythonBenchmarker-Distribution` folder are completely standalone:
- **No Julia installation required** on target machines
- **No dependency management** needed
- **Cross-platform compatible** (build on target OS)
- **Self-contained** with all required libraries

### Usage of Compiled Executables

**CLI Version:**
```bash
# Windows
PythonBenchmarker-CLI.exe script.py --iterations 20

# Unix/Linux/macOS
./PythonBenchmarker-CLI script.py --iterations 20
```

**GUI Version:**
```bash
# Windows: Double-click PythonBenchmarker-GUI.exe
# Or from command line:
PythonBenchmarker-GUI.exe

# Unix/Linux/macOS
./PythonBenchmarker-GUI
```

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

This comprehensive benchmarking tool provides professional-grade performance analysis capabilities with detailed statistical insights and visualization options.