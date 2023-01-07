cmake_minimum_required(VERSION 3.20)
project(array_add)

find_package(CUDA REQUIRED)
cuda_add_executable(array_add main.cu)