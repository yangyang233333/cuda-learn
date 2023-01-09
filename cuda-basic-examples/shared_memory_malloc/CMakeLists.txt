cmake_minimum_required(VERSION 3.20)
project(shared_memory_malloc)

find_package(CUDA REQUIRED)
cuda_add_executable(shared_memory_malloc main.cu)