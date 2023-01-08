cmake_minimum_required(VERSION 3.20)
project(array_sum2)

find_package(CUDA REQUIRED)
cuda_add_executable(array_sum2 main.cu)