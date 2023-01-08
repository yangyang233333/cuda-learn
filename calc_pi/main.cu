#include <iostream>
#include <cuda_runtime_api.h>

using std::cout;
using std::cin;
using std::endl;

//x,y 表示点的坐标，num表示点的数量，计算出result
//result长度为num，如果(x_i, y_i)在圆内，则result[i]为1，反之为0
__global__ void calc_num(const double *x, const double *y, int *result, int num) {
    for (auto thread_id = blockIdx.x * blockDim.x + threadIdx.x;
         thread_id < num; thread_id += blockDim.x * gridDim.x) {
        // 计算点到圆心的距离
        double distance = (x[thread_id] - 1) * (x[thread_id] - 1) + (y[thread_id] - 1) * (y[thread_id] - 1);
        if (distance < 1) {
            result[thread_id] = 1;
        } else {
            result[thread_id] = 0;
        }
    }
}

// 归约求和
__global__ void reduce_sum(const int *array, int *array_sum, int N) {
    int thread_id = threadIdx.x;
    array_sum[0] = 0;
    __shared__ int shared_data[512];

    for (int count = 0; count < ceilf(N / 512); ++count) {
        if (thread_id + count * 512 < N) {
            shared_data[thread_id] = array[thread_id];
            __syncthreads();
        }
        for (int i = 256; i > 0; i /= 2) {
            if (thread_id < i && thread_id + count * 512 < N) {
                shared_data[thread_id] = shared_data[thread_id] + shared_data[thread_id + i];
            }
            __syncthreads();
        }
        if (thread_id == 0) {
            array_sum[0] += shared_data[0];
        }
    }
}

int main() {
    // 写一个计算圆周率PI的kernel
    /*
     * 生成N个点，分别放入x[]和y[]，然后计算(x, y)到圆心的距离，
     * */
    constexpr int N = 100000000;
    srand(time(nullptr));
    auto x = new double[N];
    auto y = new double[N];
    for (int i = 0; i < N; ++i) {
        x[i] = rand() % 10000 / 10000.;
        y[i] = rand() % 10000 / 10000.;
    }
    double *x_gpu, *y_gpu;
    cudaMalloc((void **) &x_gpu, N * sizeof(float));
    cudaMalloc((void **) &y_gpu, N * sizeof(float));
    cudaMemcpy(x_gpu, x, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(y_gpu, y, N * sizeof(float), cudaMemcpyHostToDevice);

    int thread_num = 1024;
    int block_num = 512;
    int *result_gpu;
    cudaMalloc((void **) &result_gpu, N * sizeof(int));
    calc_num<<<block_num, thread_num>>>(x_gpu, y_gpu, result_gpu, N);

    int *cnt_gpu;
    cudaMalloc((void **) &cnt_gpu, 1 * sizeof(int));
    reduce_sum<<<1, 512>>>(result_gpu, cnt_gpu, N);
    int *cnt = new int;
    cudaMemcpy(cnt, cnt_gpu, sizeof(int), cudaMemcpyDeviceToHost);

    cout << "pi=" << 4.0 * (1.0 * (*cnt) / N) << endl;

}