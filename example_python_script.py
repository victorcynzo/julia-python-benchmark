#!/usr/bin/env python3
"""
Example Python script for benchmarking
Simulates some computational work with variable execution time
"""

import time
import random
import sys

def fibonacci(n):
    """Calculate fibonacci number recursively (inefficient on purpose)"""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def simulate_work():
    """Simulate some computational work"""
    # Random computation time between 0.1 and 0.5 seconds
    work_time = 0.1 + random.random() * 0.4
    
    # CPU-intensive work
    result = 0
    iterations = int(work_time * 1000000)
    for i in range(iterations):
        result += i * 0.001
    
    # Some memory allocation
    data = [random.random() for _ in range(10000)]
    
    return result, len(data)

def main():
    if len(sys.argv) > 1:
        # If argument provided, use it as fibonacci number
        try:
            n = int(sys.argv[1])
            result = fibonacci(min(n, 35))  # Cap at 35 to prevent excessive runtime
            print(f"Fibonacci({n}) = {result}")
        except ValueError:
            print("Invalid argument, running default simulation")
            result, data_len = simulate_work()
            print(f"Simulation result: {result:.2f}, data points: {data_len}")
    else:
        # Default simulation
        result, data_len = simulate_work()
        print(f"Simulation result: {result:.2f}, data points: {data_len}")

if __name__ == "__main__":
    main()