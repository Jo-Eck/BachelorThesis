#!/bin/bash

# This script goes through the benchmark tests for arkouda,
# iterating trhough the differnt problemsizes, from 10^TEST_SIZE_BEGINNING to 10^TEST_SIZE_END.
# During each iteration, the script runs the benchmark tests and saves the results in a file.

echo "Starting benchmark tests - at $(date)"

for ((i=$TEST_SIZE_BEGINNING; i<=$TEST_SIZE_END; i+=$TEST_SIZE_INCREMENT)); do
    echo "Running benchmark tests for size 10^$i - at $(date)"
    python3 -m pytest -c /opt/arkouda/benchmark.ini --benchmark-autosave --trials 1 --size 10**$i --benchmark-storage=file:///opt/benchmarks
done

echo "Benchmark tests completed"
sleep infinity