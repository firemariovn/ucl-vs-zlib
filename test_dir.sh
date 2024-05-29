#!/bin/bash

# Ensure the directory is specified as an argument.
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Directory containing files to benchmark.
DIRECTORY=$1

# Ensure the provided argument is a directory.
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: $DIRECTORY is not a directory."
    exit 1
fi

# Function to benchmark files recursively.
benchmark_files() {
    local DIR=$1

    for ENTRY in "$DIR"/*; do
        if [ -d "$ENTRY" ]; then
            benchmark_files "$ENTRY"
        elif [ -f "$ENTRY" ]; then
            echo "Benchmarking file: $ENTRY"
            ./benchmark "$ENTRY"
            echo ""
        fi
    done
}

# Start benchmarking from the specified directory.
benchmark_files "$DIRECTORY"
