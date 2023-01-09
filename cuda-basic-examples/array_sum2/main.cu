#include <iostream>
#include <cuda_runtime_api.h>

using std::cout;
using std::cin;
using std::endl;

__global__ void reduce_sum2(const float *a, float *result) {
    int tid = threadIdx.x;

    result[0] = 0;
    __syncthreads();
    atomicAdd(result, a[tid]);
}

int main() {
    // 写一个数组规约求和，使用原子操作版本
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
    reduce_sum2<<<1, 16>>>(a_gpu, result_gpu);
    float result = 0;
    cudaMemcpy(&result, result_gpu, 1 * sizeof(float), cudaMemcpyDeviceToHost);
    cout << "result=" << result << endl;
}