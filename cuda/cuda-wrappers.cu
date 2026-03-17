#include <stdio.h>
#include <cuda_runtime.h>

// Kernel definition (only this part MUST be in .cu)
__global__ void vector_add_kernel(float *a, float *b, float *c, int n) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = index; i < n; i += stride) {
        c[i] = a[i] + b[i];
    }
}

// --- Memory management ---

extern "C" void* cuda_malloc_floats(int n) {
    void *d_ptr;
    cudaMalloc(&d_ptr, (size_t)n * sizeof(float));
    return d_ptr;
}

extern "C" void cuda_free(void *d_ptr) {
    cudaFree(d_ptr);
}

// --- Host <-> Device transfers ---

extern "C" void cuda_memcpy_host_to_device(void *d_dst, float *h_src, int n) {
    cudaMemcpy(d_dst, h_src, (size_t)n * sizeof(float), cudaMemcpyHostToDevice);
}

extern "C" void cuda_memcpy_device_to_host(float *h_dst, void *d_src, int n) {
    cudaMemcpy(h_dst, d_src, (size_t)n * sizeof(float), cudaMemcpyDeviceToHost);
}

// --- Timing ---

extern "C" void* cuda_event_create() {
    cudaEvent_t *event = (cudaEvent_t*)malloc(sizeof(cudaEvent_t));
    cudaEventCreate(event);
    return (void*)event;
}

extern "C" void cuda_event_record(void *event) {
    cudaEventRecord(*(cudaEvent_t*)event);
}

extern "C" void cuda_event_synchronize(void *event) {
    cudaEventSynchronize(*(cudaEvent_t*)event);
}

extern "C" float cuda_event_elapsed_ms(void *start, void *stop) {
    float ms;
    cudaEventElapsedTime(&ms, *(cudaEvent_t*)start, *(cudaEvent_t*)stop);
    return ms;
}

extern "C" void cuda_event_destroy(void *event) {
    cudaEventDestroy(*(cudaEvent_t*)event);
    free(event);
}

// --- Kernel launcher ---

extern "C" void launch_vector_add(void *d_a, void *d_b, void *d_c, int n,
                                   int blocks, int threads_per_block) {
    vector_add_kernel<<<blocks, threads_per_block>>>(
        (float*)d_a, (float*)d_b, (float*)d_c, n);
}

// --- Device info ---

extern "C" void cuda_get_device_name(char *buf, int buflen) {
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    snprintf(buf, buflen, "%s", prop.name);
}
