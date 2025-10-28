using Statistics
using StatsBase

function analyze_performance_regression(current_result::BenchmarkResult, 
                                      baseline_result::BenchmarkResult;
                                      significance_threshold=0.05)
    """Compare current results against baseline for regression detection"""
    
    # Performance change percentage
    time_change = ((current_result.mean_time - baseline_result.mean_time) / 
                   baseline_result.mean_time) * 100
    
    memory_change = if baseline_result.mean_memory > 0
        ((current_result.mean_memory - baseline_result.mean_memory) / 
         baseline_result.mean_memory) * 100
    else
        0.0
    end
    
    # Simple statistical significance test (Welch's t-test approximation)
    pooled_std = sqrt((current_result.std_time^2 + baseline_result.std_time^2) / 2)
    t_stat = abs(current_result.mean_time - baseline_result.mean_time) / 
             (pooled_std * sqrt(2 / current_result.success_count))
    
    # Rough significance check (assuming normal distribution)
    is_significant = t_stat > 2.0  # Approximately p < 0.05
    
    return (
        time_change_percent = time_change,
        memory_change_percent = memory_change,
        is_regression = time_change > 5.0 && is_significant,  # 5% threshold
        is_improvement = time_change < -5.0 && is_significant,
        statistical_significance = is_significant,
        t_statistic = t_stat
    )
end

function detect_outliers(execution_times::Vector{Float64}; method=:iqr)
    """Detect outliers in execution times"""
    
    if method == :iqr
        q1 = percentile(execution_times, 25)
        q3 = percentile(execution_times, 75)
        iqr = q3 - q1
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr
        
        outlier_indices = findall(x -> x < lower_bound || x > upper_bound, execution_times)
        return outlier_indices
    elseif method == :zscore
        z_scores = abs.(zscore(execution_times))
        outlier_indices = findall(x -> x > 2.5, z_scores)
        return outlier_indices
    end
end

function calculate_stability_metrics(result::BenchmarkResult)
    """Calculate stability and consistency metrics"""
    
    cv = result.std_time / result.mean_time  # Coefficient of variation
    outliers = detect_outliers(result.execution_times)
    outlier_percentage = length(outliers) / length(result.execution_times) * 100
    
    # Stability rating (lower is more stable)
    stability_score = cv * 100 + outlier_percentage
    
    stability_rating = if stability_score < 5
        "Excellent"
    elseif stability_score < 15
        "Good"
    elseif stability_score < 30
        "Fair"
    else
        "Poor"
    end
    
    return (
        coefficient_of_variation = cv,
        outlier_count = length(outliers),
        outlier_percentage = outlier_percentage,
        stability_score = stability_score,
        stability_rating = stability_rating
    )
end