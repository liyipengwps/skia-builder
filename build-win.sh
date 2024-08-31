#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is required but not installed."
    exit 1
fi

# Check if CMake is installed
if ! command -v cmake &> /dev/null; then
    print_error "CMake is required but not installed."
    exit 1
fi

# Build Skia for both Debug and Release configurations
build_skia() {
    local arch=$1
    local config=$2
    
    print_message "Building Skia for Windows ($arch) - $config configuration..."
    python3 build-skia.py win -config "$config" -archs "$arch"
}

# Build example using CMake
build_example() {
    local arch=$1
    local config=$2
    local example_build_dir="example/build"
    
    print_message "Building example for Windows ($arch) - $config configuration..."
    
    # Create build directory
    mkdir -p "$example_build_dir"
    
    # Configure CMake
    cmake -B "$example_build_dir" \
          -A "${arch}" \
          -DCMAKE_BUILD_TYPE="$config" \
          ./example
    
    # Build
    cmake --build "$example_build_dir" --config "$config"
}

# Main build process
main() {
   #  local architectures=("x64" "Win32")
    local architectures=("x64")

   # local configs=("Debug" "Release")
    local configs=("Release")   

    for arch in "${architectures[@]}"; do
        for config in "${configs[@]}"; do
            # Build Skia
            build_skia "$arch" "$config"
            
            # Build example
            build_example "$arch" "$config"
        done
    done
    
    print_success "Build completed successfully!"
}

# Run main function
main
