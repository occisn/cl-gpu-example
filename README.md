# cl-gpu-example: CPU vs GPU Vector Addition Benchmark — Common Lisp

CPU vs GPU vector addition (100 million single-floats) in Common Lisp, using CFFI to call CUDA via a shared library.

Prepared with the help of Claude Code.

## Results

| Version | Time (s) | Speedup |
|---------|----------|---------|
| CPU     | 0.6207   | 1×      |
| GPU     | 0.0168   | ~37×    |

## Architecture

```
Common Lisp (SBCL)
    │
    ├── CPU benchmark: pure CL with optimized (simple-array single-float)
    │
    └── GPU benchmark: CL orchestrates full CUDA pipeline via CFFI
            │
            └── libclgpu.so (thin C wrappers around CUDA runtime API)
                    │
                    └── CUDA kernel (vector_add_kernel)
```

The CL side controls the entire GPU workflow — memory allocation, host/device transfers, kernel launch with timing, verification, and cleanup — making the GPU programming model fully transparent and reusable for other kernels.

## Requirements

- **SBCL** with Quicklisp (for CFFI dependency)
- **CUDA Toolkit** (nvcc compiler)
- **NVIDIA GPU** with CUDA support

### WSL2 Setup (Windows)

1. Install NVIDIA drivers on Windows (regular GeForce/Studio drivers)
2. Install CUDA Toolkit in WSL2:
   ```bash
   wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-keyring_1.1-1_all.deb
   sudo dpkg -i cuda-keyring_1.1-1_all.deb
   sudo apt-get update
   sudo apt-get install -y cuda-toolkit-12-8
   ```
3. Add to `~/.bashrc`:
   ```bash
   export PATH=/usr/local/cuda/bin:$PATH
   export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
   ```

## Build & Run

```bash
make cuda       # Build cuda/libclgpu.so
make cpu        # Run CPU benchmark only (no GPU needed)
make gpu        # Build CUDA + run GPU benchmark
make run        # Build CUDA + run full comparison with speedup
make clean      # Remove build artifacts
```

Run `make` from within WSL2, not from Windows cmd/PowerShell.

`--dynamic-space-size 4096` is set in the Makefile because the benchmark allocates 3 arrays of 100M single-floats (~1.2 GB), exceeding SBCL's default 1 GB heap.

## Bash usage

```bash
# Full benchmark (CPU vs GPU with speedup)
sbcl --dynamic-space-size 4096 --non-interactive \
  --eval '(push *default-pathname-defaults* asdf:*central-registry*)' \
  --eval '(asdf:load-system "cl-gpu")' \
  --eval '(cl-gpu:SHOW-benchmark)'

# CPU only (no GPU needed)
sbcl --dynamic-space-size 4096 --non-interactive \
  --eval '(push *default-pathname-defaults* asdf:*central-registry*)' \
  --eval '(asdf:load-system "cl-gpu")' \
  --eval '(cl-gpu:SHOW-cpu-vector-add)'

# GPU only
sbcl --dynamic-space-size 4096 --non-interactive \
  --eval '(push *default-pathname-defaults* asdf:*central-registry*)' \
  --eval '(asdf:load-system "cl-gpu")' \
  --eval '(cl-gpu:SHOW-gpu-vector-add)'
```
       
## REPL Usage

From an interactive SBCL session (started with `sbcl --dynamic-space-size 4096`):

```lisp
(push *default-pathname-defaults* asdf:*central-registry*)
(asdf:load-system "cl-gpu")

(cl-gpu:SHOW-benchmark)       ; Full comparison
(cl-gpu:SHOW-cpu-vector-add)  ; CPU only
(cl-gpu:SHOW-gpu-vector-add)  ; GPU only
```

## CL-Specific Notes

- CPU version uses `(declare (type (simple-array single-float (*))))` with `(optimize (speed 3) (safety 0))` for SBCL to generate efficient native code
- GPU version uses `cffi:foreign-alloc` for host arrays (required for CUDA memcpy compatibility)
- `with-cuda-memory` and `with-cuda-timing` macros provide clean resource management with `unwind-protect`
- All CUDA bindings are exported from the `:cl-gpu` package for reuse with custom kernels

## end of file
