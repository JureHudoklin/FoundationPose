#!/bin/bash
PROJ_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Setup paths for uv environment
# We try to detect the site-packages path from the active uv venv or default .venv location
if [ -z "$VIRTUAL_ENV" ]; then
    if [ -d ".venv" ]; then
        export VIRTUAL_ENV=$(pwd)/.venv
    else
        echo "Error: Virtual environment not found. Please run 'uv sync' first or activate your env."
        exit 1
    fi
fi

PYTHON_BIN="$VIRTUAL_ENV/bin/python"
SITE_PACKAGES=$($PYTHON_BIN -c "import site; print(site.getsitepackages()[0])")
CMAKE_PYBIND_PATH="$SITE_PACKAGES/pybind11/share/cmake/pybind11"

echo "Using Python: $PYTHON_BIN"
echo "Using Pybind11 CMake: $CMAKE_PYBIND_PATH"
echo "Using Eigen3: $EIGEN3_INCLUDE_DIR"

# Install mycpp
cd ${PROJ_ROOT}/mycpp/ && \
rm -rf build && mkdir -p build && cd build && \
# Pass EIGEN3_INCLUDE_DIR and CMAKE_PREFIX_PATH to cmake
cmake .. -DCMAKE_PREFIX_PATH="$CMAKE_PYBIND_PATH;$EIGEN3_INSTALL_DIR" && \
make -j$(nproc)

# Install mycuda
cd ${PROJ_ROOT}/bundlesdf/mycuda && \
rm -rf build *egg* *.so && \
uv pip install --no-build-isolation -e .

cd ${PROJ_ROOT}
