#include <iostream>
#include <cuda_runtime_api.h>
#include <numeric>

using std::cout;
using std::cin;
using std::endl;

#define LENGTH 16
#define THREAD_NUM 4
#define BLOCK_NUM 2

__global__ void dot_product(float *a_gpu, float *b_gpu, float *result_gpu) {
    __shared__ float shared_data[THREAD_NUM];
    int tid = threadIdx.x;
    int bid = blockIdx.x;
    int global_id = tid + bid * blockDim.x;
    while (global_id < LENGTH) {
        shared_data[tid] += a_gpu[global_id] + b_gpu[global_id];
        global_id += THREAD_NUM * BLOCK_NUM;
    }
    __syncthreads();
    // 归约求和
    for (int i = LENGTH / 2; i > 0; i /= 2) {
        if (tid < i) {
            shared_data[tid] = shared_data[tid] + shared_data[tid + i];
        }
        __syncthreads();
    }
    if (tid == 0) {
        result_gpu[bid] = shared_data[0];
    }
}

int main() {
    // 多个block的归约求点积
    /*
     *
     * */

    float a[LENGTH];
    float b[LENGTH];
    for (int i = 0; i < LENGTH; ++i) {
        a[i] = i * (i + 1);
        b[i] = i * (i - 2);
    }

    float *a_gpu, *b_gpu;
    cudaMalloc((void **) &a_gpu, LENGTH * sizeof(float));
    cudaMalloc((void **) &b_gpu, LENGTH * sizeof(float));
    cudaMemcpy(a_gpu, a, LENGTH * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(b_gpu, b, LENGTH * sizeof(float), cudaMemcpyHostToDevice);

    float *result_gpu;
    cudaMalloc((void **) &result_gpu, BLOCK_NUM * sizeof(float));
    // 假设线程数小于LENGTH，模拟需要多个block的场景
    dot_product<<<BLOCK_NUM, THREAD_NUM>>>(a_gpu, b_gpu, result_gpu);

    float result[BLOCK_NUM];
    cudaMemcpy(result, result_gpu, BLOCK_NUM * sizeof(float), cudaMemcpyDeviceToHost);

    cout << "result=" << std::accumulate(std::begin(result), std::end(result), 0.0) << endl;

}