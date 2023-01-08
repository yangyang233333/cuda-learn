cmake_minimum_required(VERSION 3.20)
project(calc_pi)

find_package(CUDA REQUIRED)
cuda_add_executable(calc_pi main.cu)