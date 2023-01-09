cmake_minimum_required(VERSION 3.20)
project(calc_product)

find_package(CUDA REQUIRED)
cuda_add_executable(calc_product main.cu)