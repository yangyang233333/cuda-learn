#include <iostream>
#include <cuda_runtime_api.h>

using std::cout;
using std::cin;
using std::endl;

__global__ void add(const int *a, const int *b, int *c, int len) {
    uint32_t i = threadIdx.x;
    if (i < len) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    // 写一个向量加法
    /*
     * C = A + B
     * 其中A、B、C均为长度为10的向量
     *
     * */
    int length = 10;
    int a[length], b[length], c[length];
    int *a_gpu, *b_gpu, *c_gpu;

    for (int i = 0; i < length; ++i) {
        a[i] = i;
        b[i] = i * i;
    }
    cudaMalloc((void **) &a_gpu, length * sizeof(int));
    cudaMalloc((void **) &b_gpu, length * sizeof(int));
    cudaMalloc((void **) &c_gpu, length * sizeof(int));

    cudaMemcpy(a_gpu, a, length * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(b_gpu, b, length * sizeof(int), cudaMemcpyHostToDevice);

    add<<<1, length>>>(a_gpu, b_gpu, c_gpu, length);

    cudaMemcpy(c, c_gpu, length * sizeof(int), cudaMemcpyDeviceToHost);
    for (int i = 0; i < length; ++i) {
        cout << i << " ";
    }
    cout << endl;

    return 0;
}