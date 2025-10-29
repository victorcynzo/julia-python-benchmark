using Blink
using JSON3
using Dates

# Global variables for GUI state
current_config = nothing
current_result = nothing
gui_window = nothing

struct GUIConfig
    python_file::String
    iterations::Int
    warmup_runs::Int
    timeout_seconds::Float64
    memory_tracking::Bool
    python_args::Vector{String}
    output_csv::String
    output_json::String
    generate_plots::Bool
    plot_dir::String
    baseline_file::String
    quiet_mode::Bool
end

function create_gui()
    """Create and launch the GUI application"""
    
    global gui_window
    
    # Create Blink window
    gui_window = Window(Dict(
        "title" => "Python Benchmarker",
        "width" => 1200,
        "height" => 800,
        "resizable" => true,
        "show" => false
    ))
    
    # Load HTML content
    html_content = create_html_interface()
    body!(gui_window, html_content)
    
    # Set up JavaScript handlers
    setup_js_handlers(gui_window)
    
    # Show window
    opentools(gui_window)
    
    return gui_window
end

function create_html_interface()
    """Create the HTML interface for the GUI"""
    
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Python Benchmarker</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 20px;
            }
            
            .container {
                max-width: 1400px;
                margin: 0 auto;
                background: white;
                border-radius: 15px;
                box-shadow: 0 20px 40px rgba(0,0,0,0.1);
                overflow: hidden;
            }
            
            .header {
                background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
                color: white;
                padding: 30px;
                text-align: center;
            }
            
            .header h1 {
                font-size: 2.5em;
                margin-bottom: 10px;
                font-weight: 300;
            }
            
            .header p {
                font-size: 1.1em;
                opacity: 0.9;
            }
            
            .main-content {
                display: flex;
                min-height: 600px;
            }
            
            .sidebar {
                width: 400px;
                background: #f8f9fa;
                padding: 30px;
                border-right: 1px solid #e9ecef;
                overflow-y: auto;
            }
            
            .content-area {
                flex: 1;
                padding: 30px;
                overflow-y: auto;
            }
            
            .section {
                margin-bottom: 30px;
                background: white;
                border-radius: 10px;
                padding: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }
            
            .section h3 {
                color: #2c3e50;
                margin-bottom: 15px;
                font-size: 1.3em;
                border-bottom: 2px solid #3498db;
                padding-bottom: 5px;
            }
            
            .file-drop-zone {
                border: 3px dashed #3498db;
                border-radius: 10px;
                padding: 40px;
                text-align: center;
                background: #f8f9ff;
                cursor: pointer;
                transition: all 0.3s ease;
                margin-bottom: 20px;
            }
            
            .file-drop-zone:hover {
                border-color: #2980b9;
                background: #e8f4fd;
            }
            
            .file-drop-zone.dragover {
                border-color: #27ae60;
                background: #e8f8f5;
            }
            
            .file-info {
                background: #e8f5e8;
                border: 1px solid #27ae60;
                border-radius: 5px;
                padding: 10px;
                margin-top: 10px;
                display: none;
            }
            
            .form-group {
                margin-bottom: 20px;
            }
            
            .form-group label {
                display: block;
                margin-bottom: 5px;
                font-weight: 600;
                color: #2c3e50;
            }
            
            .form-group input, .form-group select, .form-group textarea {
                width: 100%;
                padding: 12px;
                border: 2px solid #e9ecef;
                border-radius: 5px;
                font-size: 14px;
                transition: border-color 0.3s ease;
            }
            
            .form-group input:focus, .form-group select:focus, .form-group textarea:focus {
                outline: none;
                border-color: #3498db;
            }
            
            .checkbox-group {
                display: flex;
                align-items: center;
                margin-bottom: 15px;
            }
            
            .checkbox-group input[type="checkbox"] {
                width: auto;
                margin-right: 10px;
                transform: scale(1.2);
            }
            
            .button-group {
                display: flex;
                gap: 15px;
                margin-top: 30px;
            }
            
            .btn {
                padding: 15px 30px;
                border: none;
                border-radius: 5px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s ease;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            
            .btn-primary {
                background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
                color: white;
            }
            
            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(52, 152, 219, 0.4);
            }
            
            .btn-secondary {
                background: #95a5a6;
                color: white;
            }
            
            .btn-secondary:hover {
                background: #7f8c8d;
            }
            
            .btn:disabled {
                opacity: 0.6;
                cursor: not-allowed;
                transform: none !important;
            }
            
            .progress-container {
                margin-top: 20px;
                display: none;
            }
            
            .progress-bar {
                width: 100%;
                height: 20px;
                background: #e9ecef;
                border-radius: 10px;
                overflow: hidden;
            }
            
            .progress-fill {
                height: 100%;
                background: linear-gradient(90deg, #3498db, #2980b9);
                width: 0%;
                transition: width 0.3s ease;
            }
            
            .progress-text {
                text-align: center;
                margin-top: 10px;
                font-weight: 600;
                color: #2c3e50;
            }
            
            .results-container {
                display: none;
                margin-top: 30px;
            }
            
            .results-tabs {
                display: flex;
                border-bottom: 2px solid #e9ecef;
                margin-bottom: 20px;
            }
            
            .tab {
                padding: 15px 25px;
                background: #f8f9fa;
                border: none;
                cursor: pointer;
                font-weight: 600;
                color: #6c757d;
                transition: all 0.3s ease;
            }
            
            .tab.active {
                background: #3498db;
                color: white;
            }
            
            .tab-content {
                display: none;
                padding: 20px;
                background: #f8f9fa;
                border-radius: 5px;
            }
            
            .tab-content.active {
                display: block;
            }
            
            .stats-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 20px;
                margin-bottom: 30px;
            }
            
            .stat-card {
                background: white;
                padding: 20px;
                border-radius: 10px;
                text-align: center;
                box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            }
            
            .stat-value {
                font-size: 2em;
                font-weight: bold;
                color: #3498db;
                margin-bottom: 5px;
            }
            
            .stat-label {
                color: #6c757d;
                font-size: 0.9em;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            
            .log-container {
                background: #2c3e50;
                color: #ecf0f1;
                padding: 20px;
                border-radius: 5px;
                font-family: 'Courier New', monospace;
                font-size: 14px;
                max-height: 400px;
                overflow-y: auto;
                white-space: pre-wrap;
            }
            
            .plot-container {
                text-align: center;
                margin: 20px 0;
            }
            
            .plot-container img {
                max-width: 100%;
                border-radius: 10px;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }
            
            .export-buttons {
                display: flex;
                gap: 10px;
                margin-top: 20px;
            }
            
            .btn-export {
                background: #27ae60;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-weight: 600;
            }
            
            .btn-export:hover {
                background: #229954;
            }
            
            .error-message {
                background: #e74c3c;
                color: white;
                padding: 15px;
                border-radius: 5px;
                margin: 10px 0;
                display: none;
            }
            
            .success-message {
                background: #27ae60;
                color: white;
                padding: 15px;
                border-radius: 5px;
                margin: 10px 0;
                display: none;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🐍 Python Benchmarker</h1>
                <p>Professional Performance Analysis Tool</p>
            </div>
            
            <div class="main-content">
                <div class="sidebar">
                    <div class="section">
                        <h3>📁 Python File</h3>
                        <div class="file-drop-zone" id="fileDropZone">
                            <div style="font-size: 3em; margin-bottom: 15px;">📄</div>
                            <p><strong>Drop Python file here</strong></p>
                            <p>or click to browse</p>
                            <input type="file" id="fileInput" accept=".py" style="display: none;">
                        </div>
                        <div class="file-info" id="fileInfo">
                            <strong>Selected:</strong> <span id="fileName"></span>
                        </div>
                    </div>
                    
                    <div class="section">
                        <h3>⚙️ Benchmark Settings</h3>
                        
                        <div class="form-group">
                            <label for="iterations">Iterations:</label>
                            <input type="number" id="iterations" value="10" min="1" max="1000">
                        </div>
                        
                        <div class="form-group">
                            <label for="warmup">Warmup Runs:</label>
                            <input type="number" id="warmup" value="3" min="0" max="100">
                        </div>
                        
                        <div class="form-group">
                            <label for="timeout">Timeout (seconds):</label>
                            <input type="number" id="timeout" value="300" min="1" max="3600" step="0.1">
                        </div>
                        
                        <div class="checkbox-group">
                            <input type="checkbox" id="memoryTracking" checked>
                            <label for="memoryTracking">Enable Memory Tracking</label>
                        </div>
                        
                        <div class="form-group">
                            <label for="pythonArgs">Python Arguments:</label>
                            <textarea id="pythonArgs" rows="3" placeholder="Enter arguments separated by spaces"></textarea>
                        </div>
                    </div>
                    
                    <div class="section">
                        <h3>📊 Output Options</h3>
                        
                        <div class="checkbox-group">
                            <input type="checkbox" id="generatePlots" checked>
                            <label for="generatePlots">Generate Performance Plots</label>
                        </div>
                        
                        <div class="form-group">
                            <label for="plotDir">Plot Directory:</label>
                            <input type="text" id="plotDir" value="plots" placeholder="plots">
                        </div>
                        
                        <div class="form-group">
                            <label for="outputCsv">CSV Export File:</label>
                            <input type="text" id="outputCsv" placeholder="results.csv (optional)">
                        </div>
                        
                        <div class="form-group">
                            <label for="outputJson">JSON Export File:</label>
                            <input type="text" id="outputJson" placeholder="results.json (optional)">
                        </div>
                        
                        <div class="form-group">
                            <label for="baselineFile">Baseline File:</label>
                            <input type="text" id="baselineFile" placeholder="baseline.json (optional)">
                        </div>
                        
                        <div class="checkbox-group">
                            <input type="checkbox" id="quietMode">
                            <label for="quietMode">Quiet Mode</label>
                        </div>
                    </div>
                    
                    <div class="button-group">
                        <button class="btn btn-primary" id="runBenchmark" disabled>
                            🚀 Run Benchmark
                        </button>
                        <button class="btn btn-secondary" id="resetForm">
                            🔄 Reset
                        </button>
                    </div>
                    
                    <div class="progress-container" id="progressContainer">
                        <div class="progress-bar">
                            <div class="progress-fill" id="progressFill"></div>
                        </div>
                        <div class="progress-text" id="progressText">Initializing...</div>
                    </div>
                    
                    <div class="error-message" id="errorMessage"></div>
                    <div class="success-message" id="successMessage"></div>
                </div>
                
                <div class="content-area">
                    <div class="results-container" id="resultsContainer">
                        <div class="results-tabs">
                            <button class="tab active" data-tab="summary">📈 Summary</button>
                            <button class="tab" data-tab="statistics">📊 Statistics</button>
                            <button class="tab" data-tab="plots">📉 Plots</button>
                            <button class="tab" data-tab="logs">📝 Logs</button>
                            <button class="tab" data-tab="export">💾 Export</button>
                        </div>
                        
                        <div class="tab-content active" id="summary">
                            <div class="stats-grid" id="statsGrid">
                                <!-- Stats cards will be populated here -->
                            </div>
                            <div id="summaryText"></div>
                        </div>
                        
                        <div class="tab-content" id="statistics">
                            <div id="statisticsContent">
                                <!-- Detailed statistics will be populated here -->
                            </div>
                        </div>
                        
                        <div class="tab-content" id="plots">
                            <div id="plotsContent">
                                <!-- Plots will be displayed here -->
                            </div>
                        </div>
                        
                        <div class="tab-content" id="logs">
                            <div class="log-container" id="logContainer">
                                Welcome to Python Benchmarker!
                                Select a Python file and configure your benchmark settings to get started.
                            </div>
                        </div>
                        
                        <div class="tab-content" id="export">
                            <div id="exportContent">
                                <h4>Export Options</h4>
                                <p>After running a benchmark, you can export the results in various formats:</p>
                                <div class="export-buttons" id="exportButtons">
                                    <!-- Export buttons will be populated after benchmark -->
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div id="welcomeMessage" style="text-align: center; padding: 100px 50px; color: #6c757d;">
                        <div style="font-size: 4em; margin-bottom: 20px;">🎯</div>
                        <h2>Welcome to Python Benchmarker</h2>
                        <p style="font-size: 1.2em; margin-top: 15px;">
                            Drop a Python file in the sidebar to get started with professional performance analysis.
                        </p>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            // JavaScript code will be added here
            let selectedFile = null;
            let benchmarkRunning = false;
            
            // File drop zone functionality
            const fileDropZone = document.getElementById('fileDropZone');
            const fileInput = document.getElementById('fileInput');
            const fileInfo = document.getElementById('fileInfo');
            const fileName = document.getElementById('fileName');
            const runButton = document.getElementById('runBenchmark');
            
            fileDropZone.addEventListener('click', () => fileInput.click());
            fileDropZone.addEventListener('dragover', handleDragOver);
            fileDropZone.addEventListener('drop', handleDrop);
            fileInput.addEventListener('change', handleFileSelect);
            
            function handleDragOver(e) {
                e.preventDefault();
                fileDropZone.classList.add('dragover');
            }
            
            function handleDrop(e) {
                e.preventDefault();
                fileDropZone.classList.remove('dragover');
                const files = e.dataTransfer.files;
                if (files.length > 0 && files[0].name.endsWith('.py')) {
                    handleFileSelection(files[0]);
                }
            }
            
            function handleFileSelect(e) {
                if (e.target.files.length > 0) {
                    handleFileSelection(e.target.files[0]);
                }
            }
            
            function handleFileSelection(file) {
                selectedFile = file;
                fileName.textContent = file.name;
                fileInfo.style.display = 'block';
                runButton.disabled = false;
                
                // Send file path to Julia
                Blink.msg("file_selected", {
                    name: file.name,
                    path: file.path || file.name
                });
            }
            
            // Tab functionality
            document.querySelectorAll('.tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                    
                    tab.classList.add('active');
                    document.getElementById(tab.dataset.tab).classList.add('active');
                });
            });
            
            // Run benchmark button
            document.getElementById('runBenchmark').addEventListener('click', runBenchmark);
            
            // Reset form button
            document.getElementById('resetForm').addEventListener('click', resetForm);
            
            function runBenchmark() {
                if (!selectedFile || benchmarkRunning) return;
                
                benchmarkRunning = true;
                runButton.disabled = true;
                
                // Collect form data
                const config = {
                    python_file: selectedFile.path || selectedFile.name,
                    iterations: parseInt(document.getElementById('iterations').value),
                    warmup_runs: parseInt(document.getElementById('warmup').value),
                    timeout_seconds: parseFloat(document.getElementById('timeout').value),
                    memory_tracking: document.getElementById('memoryTracking').checked,
                    python_args: document.getElementById('pythonArgs').value.trim().split(/\\s+/).filter(arg => arg.length > 0),
                    output_csv: document.getElementById('outputCsv').value.trim(),
                    output_json: document.getElementById('outputJson').value.trim(),
                    generate_plots: document.getElementById('generatePlots').checked,
                    plot_dir: document.getElementById('plotDir').value.trim() || 'plots',
                    baseline_file: document.getElementById('baselineFile').value.trim(),
                    quiet_mode: document.getElementById('quietMode').checked
                };
                
                // Show progress
                document.getElementById('progressContainer').style.display = 'block';
                document.getElementById('welcomeMessage').style.display = 'none';
                document.getElementById('resultsContainer').style.display = 'block';
                
                // Switch to logs tab
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                document.querySelector('[data-tab="logs"]').classList.add('active');
                document.getElementById('logs').classList.add('active');
                
                // Send to Julia
                Blink.msg("run_benchmark", config);
            }
            
            function resetForm() {
                selectedFile = null;
                fileInfo.style.display = 'none';
                runButton.disabled = true;
                benchmarkRunning = false;
                
                // Reset form values
                document.getElementById('iterations').value = '10';
                document.getElementById('warmup').value = '3';
                document.getElementById('timeout').value = '300';
                document.getElementById('memoryTracking').checked = true;
                document.getElementById('pythonArgs').value = '';
                document.getElementById('generatePlots').checked = true;
                document.getElementById('plotDir').value = 'plots';
                document.getElementById('outputCsv').value = '';
                document.getElementById('outputJson').value = '';
                document.getElementById('baselineFile').value = '';
                document.getElementById('quietMode').checked = false;
                
                // Hide results
                document.getElementById('resultsContainer').style.display = 'none';
                document.getElementById('progressContainer').style.display = 'none';
                document.getElementById('welcomeMessage').style.display = 'block';
                
                // Clear messages
                document.getElementById('errorMessage').style.display = 'none';
                document.getElementById('successMessage').style.display = 'none';
            }
            
            // Functions to be called from Julia
            window.updateProgress = function(percent, text) {
                document.getElementById('progressFill').style.width = percent + '%';
                document.getElementById('progressText').textContent = text;
            };
            
            window.appendLog = function(message) {
                const logContainer = document.getElementById('logContainer');
                logContainer.textContent += message + '\\n';
                logContainer.scrollTop = logContainer.scrollHeight;
            };
            
            window.showError = function(message) {
                const errorDiv = document.getElementById('errorMessage');
                errorDiv.textContent = message;
                errorDiv.style.display = 'block';
                benchmarkRunning = false;
                runButton.disabled = false;
            };
            
            window.showSuccess = function(message) {
                const successDiv = document.getElementById('successMessage');
                successDiv.textContent = message;
                successDiv.style.display = 'block';
            };
            
            window.displayResults = function(results) {
                benchmarkRunning = false;
                runButton.disabled = false;
                document.getElementById('progressContainer').style.display = 'none';
                
                // Populate results
                populateStatistics(results);
                populatePlots(results);
                populateExportOptions(results);
                
                // Switch to summary tab
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                document.querySelector('[data-tab="summary"]').classList.add('active');
                document.getElementById('summary').classList.add('active');
            };
            
            function populateStatistics(results) {
                // Create stats cards
                const statsGrid = document.getElementById('statsGrid');
                statsGrid.innerHTML = '';
                
                const stats = [
                    { label: 'Mean Time', value: results.mean_time.toFixed(4) + 's' },
                    { label: 'Median Time', value: results.median_time.toFixed(4) + 's' },
                    { label: 'Std Deviation', value: results.std_time.toFixed(4) + 's' },
                    { label: 'Min Time', value: results.min_time.toFixed(4) + 's' },
                    { label: 'Max Time', value: results.max_time.toFixed(4) + 's' },
                    { label: 'Success Rate', value: Math.round((results.success_count / results.total_runs) * 100) + '%' }
                ];
                
                if (results.peak_memory > 0) {
                    stats.push({ label: 'Peak Memory', value: (results.peak_memory / 1024 / 1024).toFixed(2) + ' MB' });
                }
                
                stats.forEach(stat => {
                    const card = document.createElement('div');
                    card.className = 'stat-card';
                    card.innerHTML = `
                        <div class="stat-value">\${stat.value}</div>
                        <div class="stat-label">\${stat.label}</div>
                    `;
                    statsGrid.appendChild(card);
                });
                
                // Detailed statistics
                const statisticsContent = document.getElementById('statisticsContent');
                statisticsContent.innerHTML = `
                    <h4>Detailed Statistics</h4>
                    <table style="width: 100%; border-collapse: collapse; margin-top: 20px;">
                        <tr style="background: #f8f9fa;">
                            <th style="padding: 10px; text-align: left; border: 1px solid #dee2e6;">Metric</th>
                            <th style="padding: 10px; text-align: left; border: 1px solid #dee2e6;">Value</th>
                        </tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">Total Runs</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.total_runs}</td></tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">Successful Runs</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.success_count}</td></tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">Failed Runs</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.total_runs - results.success_count}</td></tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">25th Percentile</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.percentiles['25'].toFixed(4)}s</td></tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">75th Percentile</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.percentiles['75'].toFixed(4)}s</td></tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">95th Percentile</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.percentiles['95'].toFixed(4)}s</td></tr>
                        <tr><td style="padding: 10px; border: 1px solid #dee2e6;">99th Percentile</td><td style="padding: 10px; border: 1px solid #dee2e6;">\${results.percentiles['99'].toFixed(4)}s</td></tr>
                    </table>
                `;
            }
            
            function populatePlots(results) {
                const plotsContent = document.getElementById('plotsContent');
                if (results.plots && results.plots.length > 0) {
                    plotsContent.innerHTML = '<h4>Performance Visualizations</h4>';
                    results.plots.forEach(plot => {
                        const plotDiv = document.createElement('div');
                        plotDiv.className = 'plot-container';
                        plotDiv.innerHTML = `
                            <h5>\${plot.title}</h5>
                            <img src="\${plot.path}" alt="\${plot.title}">
                        `;
                        plotsContent.appendChild(plotDiv);
                    });
                } else {
                    plotsContent.innerHTML = '<p>No plots generated. Enable plot generation in settings to see visualizations.</p>';
                }
            }
            
            function populateExportOptions(results) {
                const exportButtons = document.getElementById('exportButtons');
                exportButtons.innerHTML = '';
                
                if (results.csv_file) {
                    const csvBtn = document.createElement('button');
                    csvBtn.className = 'btn-export';
                    csvBtn.textContent = '📊 Download CSV';
                    csvBtn.onclick = () => Blink.msg('download_file', { path: results.csv_file });
                    exportButtons.appendChild(csvBtn);
                }
                
                if (results.json_file) {
                    const jsonBtn = document.createElement('button');
                    jsonBtn.className = 'btn-export';
                    jsonBtn.textContent = '📄 Download JSON';
                    jsonBtn.onclick = () => Blink.msg('download_file', { path: results.json_file });
                    exportButtons.appendChild(jsonBtn);
                }
            }
        </script>
    </body>
    </html>
    """
end

function setup_js_handlers(window)
    """Set up JavaScript message handlers"""
    
    # Handle file selection
    handle(window, "file_selected") do args
        global current_config
        println("File selected: $(args["name"])")
        @js window appendLog("File selected: $(args["name"])")
    end
    
    # Handle benchmark execution
    handle(window, "run_benchmark") do args
        global current_config, current_result
        
        try
            # Convert GUI config to BenchmarkConfig
            current_config = BenchmarkConfig(
                args["python_file"];
                iterations = args["iterations"],
                warmup_runs = args["warmup_runs"],
                timeout_seconds = args["timeout_seconds"],
                memory_tracking = args["memory_tracking"],
                python_args = args["python_args"]
            )
            
            @js window appendLog("Starting benchmark...")
            @js window updateProgress(10, "Initializing benchmark...")
            
            # Create organized output directory
            output_dir = create_output_directory_gui(args["python_file"])
            @js window appendLog("Created output directory: $output_dir")
            
            # Run benchmark in separate task to avoid blocking GUI
            @async begin
                try
                    result = run_benchmark_with_gui_updates(current_config, window)
                    current_result = result
                    
                    # Prepare results for JavaScript with output directory
                    js_results = prepare_results_for_js(result, args, output_dir)
                    
                    @js window displayResults($js_results)
                    @js window showSuccess("Benchmark completed successfully!")
                    
                catch e
                    error_msg = "Benchmark failed: $(string(e))"
                    @js window showError($error_msg)
                    @js window appendLog($error_msg)
                end
            end
            
        catch e
            error_msg = "Configuration error: $(string(e))"
            @js window showError($error_msg)
        end
    end
    
    # Handle file downloads
    handle(window, "download_file") do args
        try
            # This would typically open a file dialog or copy to clipboard
            # For now, just show the file path
            @js window showSuccess("File available at: $(args["path"])")
        catch e
            @js window showError("Download failed: $(string(e))")
        end
    end
end

function create_output_directory_gui(python_file::String)
    """Create organized output directory for GUI version"""
    # Extract filename without extension
    base_name = splitext(basename(python_file))[1]
    
    # Create directory name with timestamp for uniqueness
    timestamp = Dates.format(now(), "yyyy-mm-dd_HH-MM-SS")
    output_dir = "test-results-$(base_name)-$(timestamp)"
    
    # Create directory if it doesn't exist
    if !isdir(output_dir)
        mkdir(output_dir)
    end
    
    return output_dir
end

function run_benchmark_with_gui_updates(config::BenchmarkConfig, window)
    """Run benchmark with GUI progress updates"""
    
    @js window appendLog("Configuration:")
    @js window appendLog("  File: $(config.python_file)")
    @js window appendLog("  Iterations: $(config.iterations)")
    @js window appendLog("  Warmup runs: $(config.warmup_runs)")
    @js window appendLog("  Memory tracking: $(config.memory_tracking)")
    @js window appendLog("")
    
    execution_times = Float64[]
    memory_usage = Int64[]
    failed_runs = String[]
    success_count = 0
    
    # Warmup runs
    @js window updateProgress(20, "Running warmup...")
    @js window appendLog("Running warmup...")
    
    for i in 1:config.warmup_runs
        @js window appendLog("Warmup run $i/$(config.warmup_runs)...")
        result = run_isolated_python(config)
        if !result.success
            @js window appendLog("Warmup run $i failed: $(result.error)")
        end
        sleep(0.1)  # Small delay for GUI updates
    end
    
    # Actual benchmark runs
    @js window updateProgress(30, "Running benchmark iterations...")
    @js window appendLog("Running benchmark iterations...")
    
    for i in 1:config.iterations
        progress = 30 + (i / config.iterations) * 60
        @js window updateProgress($progress, "Run $i/$(config.iterations)...")
        @js window appendLog("Run $i/$(config.iterations)... ")
        
        result = run_isolated_python(config)
        
        if result.success
            push!(execution_times, result.time)
            push!(memory_usage, result.memory)
            success_count += 1
            @js window appendLog("✓ $(round(result.time, digits=4))s")
        else
            push!(failed_runs, "Run $i: $(result.error)")
            @js window appendLog("✗ Failed: $(result.error)")
        end
        
        sleep(0.1)  # Small delay for GUI updates
    end
    
    if success_count == 0
        error("All benchmark runs failed!")
    end
    
    @js window updateProgress(95, "Analyzing results...")
    @js window appendLog("Analyzing results...")
    
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
    
    result = BenchmarkResult(
        config, execution_times, memory_usage, success_count, failed_runs,
        now(), mean_time, median_time, std_time, min_time, max_time,
        percentiles, mean_memory, peak_memory
    )
    
    @js window updateProgress(100, "Complete!")
    @js window appendLog("Benchmark completed successfully!")
    
    return result
end

function prepare_results_for_js(result::BenchmarkResult, gui_config, output_dir::String)
    """Prepare benchmark results for JavaScript display"""
    
    js_results = Dict(
        "mean_time" => result.mean_time,
        "median_time" => result.median_time,
        "std_time" => result.std_time,
        "min_time" => result.min_time,
        "max_time" => result.max_time,
        "percentiles" => result.percentiles,
        "success_count" => result.success_count,
        "total_runs" => result.config.iterations,
        "peak_memory" => result.peak_memory,
        "mean_memory" => result.mean_memory,
        "execution_times" => result.execution_times,
        "memory_usage" => result.memory_usage,
        "failed_runs" => result.failed_runs,
        "timestamp" => string(result.timestamp)
    )
    
    # Handle exports in organized directory
    if !isempty(gui_config["output_csv"])
        try
            csv_path = joinpath(output_dir, gui_config["output_csv"])
            export_to_csv(result, csv_path)
            js_results["csv_file"] = csv_path
        catch e
            println("CSV export failed: $e")
        end
    else
        # Always create a default CSV export
        try
            default_csv = joinpath(output_dir, "benchmark_results.csv")
            export_to_csv(result, default_csv)
            js_results["csv_file"] = default_csv
        catch e
            println("Default CSV export failed: $e")
        end
    end
    
    if !isempty(gui_config["output_json"])
        try
            json_path = joinpath(output_dir, gui_config["output_json"])
            export_to_json(result, json_path)
            js_results["json_file"] = json_path
        catch e
            println("JSON export failed: $e")
        end
    else
        # Always create a default JSON export
        try
            default_json = joinpath(output_dir, "benchmark_results.json")
            export_to_json(result, default_json)
            js_results["json_file"] = default_json
        catch e
            println("Default JSON export failed: $e")
        end
    end
    
    # Handle plots in organized directory
    if gui_config["generate_plots"]
        try
            plot_dir = joinpath(output_dir, gui_config["plot_dir"])
            create_performance_plots(result, plot_dir)
            
            # List generated plots
            plots = []
            
            plot_files = [
                ("time_distribution.png", "Execution Time Distribution"),
                ("time_series.png", "Execution Time Series"),
                ("box_plot.png", "Box Plot Analysis"),
                ("memory_usage.png", "Memory Usage")
            ]
            
            for (filename, title) in plot_files
                filepath = joinpath(plot_dir, filename)
                if isfile(filepath)
                    push!(plots, Dict("path" => filepath, "title" => title))
                end
            end
            
            js_results["plots"] = plots
        catch e
            println("Plot generation failed: $e")
            js_results["plots"] = []
        end
    else
        js_results["plots"] = []
    end
    
    return js_results
end

function launch_gui()
    """Main function to launch the GUI application"""
    
    println("Launching Python Benchmarker GUI...")
    
    try
        window = create_gui()
        println("GUI launched successfully!")
        println("Close the window to exit the application.")
        
        # Keep the application running
        while active(window)
            sleep(0.1)
        end
        
    catch e
        println("Failed to launch GUI: $e")
        println("Make sure Blink.jl is properly installed:")
        println("julia -e \"using Pkg; Pkg.add(\\\"Blink\\\")")
    end
end