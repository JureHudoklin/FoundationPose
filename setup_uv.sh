#!/bin/bash
set -e

# 1. Install dependencies with uv
echo "Installing Python dependencies with uv..."
uv sync


# 2. Install Special packages (NVDiffRast, Kaolin, PyTorch3D)
# We install these via pip inside the uv venv because they often require compilation or specific wheels
echo "Installing NVDiffRast..."
uv pip install --no-build-isolation git+https://github.com/NVlabs/nvdiffrast.git

echo "Installing Kaolin..."
# Installation from source since wheels might not match Python/Torch versions perfectly
uv pip install --no-build-isolation kaolin==0.15.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.7.1_cu128.html || uv pip install --no-build-isolation git+https://github.com/NVIDIAGameWorks/kaolin.git

echo "Installing PyTorch3D..."
# Installation from source is often safer for newer Torch versions
uv pip install --no-build-isolation "git+https://github.com/facebookresearch/pytorch3d.git"

# 3. Setup Eigen3 (needed for C++ extensions)
echo "Setting up Eigen3..."
if [ ! -d "eigen-3.4.0" ]; then
    wget -q https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz
    tar xzf eigen-3.4.0.tar.gz
    rm eigen-3.4.0.tar.gz
fi

# Build and install Eigen3 locally to generate CMake config files
if [ ! -d "eigen-3.4.0/build" ]; then
    echo "Building Eigen3..."
    mkdir -p eigen-3.4.0/build
    cd eigen-3.4.0/build
    cmake .. -DCMAKE_INSTALL_PREFIX=$(pwd)/../install
    make install -j$(nproc)
    cd ../..
fi
export EIGEN3_INSTALL_DIR=$(pwd)/eigen-3.4.0/install

# Check for Boost (System dependency)
echo "Checking for Boost..."
# We can't easily install Boost with uv/pip. We assume system boost or user installed.
# If this fails, user needs: sudo apt-get install libboost-all-dev


# 4. Build Extensions
echo "Building extensions..."
bash build_all_uv.sh
