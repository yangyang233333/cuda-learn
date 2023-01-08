#include <iostream>
#include <cuda_runtime_api.h>

using std::cout;
using std::cin;
using std::endl;

__global__ void reduce_sum(const float *a, float *result) {
    // 动态分配的显存，具体大小在调用时指定，例如reduce_sum<<<1, 16, 16>>>
    // 最后一个16就是指的动态显存sh的长度
    extern __shared__ float sh[];
    float *shared_data = sh;
    shared_data[threadIdx.x] = a[threadIdx.x];
    __syncthreads(); // 保证所有线程都完成复制

    for (int i = 8; i > 0; i /= 2) {
        shared_data[threadIdx.x] = shared_data[threadIdx.x] + shared_data[threadIdx.x + i];
        __syncthreads();
    }
    if (threadIdx.x == 0) {
        result[threadIdx.x] = shared_data[threadIdx.x];
    }
}

int main() {
    // 写一个数组规约求和，使用动态分配的显存
    /*
     * A 是一个长度16的数组，对其进行求和
     * */

    float a[16];
    for (int i = 0; i < 16; ++i) {
        a[i] = (float) i;
    }

    float *a_gpu;
    cudaMalloc((void **) &a_gpu, 16 * sizeof(float));
    cudaMemcpy(a_gpu, a, 16 * sizeof(float), cudaMemcpyHostToDevice);

    float *result_gpu;

    cudaMalloc((void **) &result_gpu, 1 * sizeof(float));
    reduce_sum<<<1, 16, 16>>>(a_gpu, result_gpu);
    float result = 0;
    cudaMemcpy(&result, result_gpu, 1 * sizeof(float), cudaMemcpyDeviceToHost);
    cout << "result=" << result << endl;
}