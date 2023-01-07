rm -rf build
cmake -S . -B build
cmake --build build --target all -- -j$(nproc)