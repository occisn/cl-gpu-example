# Makefile for cl-gpu — Common Lisp + CUDA benchmark

SBCL = sbcl --noinform --dynamic-space-size 4096 --non-interactive
ASDF_SETUP = --eval '(push *default-pathname-defaults* asdf:*central-registry*)'
LOAD_SYSTEM = --eval '(asdf:load-system "cl-gpu")'

# Default target
all: cuda

# Build CUDA shared library
cuda:
	$(MAKE) -C cuda

# Run CPU benchmark only (no GPU/CUDA needed)
cpu:
	$(SBCL) $(ASDF_SETUP) $(LOAD_SYSTEM) \
		--eval '(cl-gpu:SHOW-cpu-vector-add)'

# Build CUDA library and run GPU benchmark
gpu: cuda
	$(SBCL) $(ASDF_SETUP) $(LOAD_SYSTEM) \
		--eval '(cl-gpu:SHOW-gpu-vector-add)'

# Run both benchmarks with comparison
run: cuda
	$(SBCL) $(ASDF_SETUP) $(LOAD_SYSTEM) \
		--eval '(cl-gpu:SHOW-benchmark)'

# Clean all build artifacts
clean:
	$(MAKE) -C cuda clean
	@echo "Cleaned all build artifacts"

# Help
help:
	@echo "Available targets:"
	@echo "  make all    - Build CUDA shared library (default)"
	@echo "  make cuda   - Build CUDA shared library"
	@echo "  make cpu    - Run CPU benchmark (no GPU needed)"
	@echo "  make gpu    - Build CUDA + run GPU benchmark"
	@echo "  make run    - Build CUDA + run full benchmark (CPU vs GPU)"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make help   - Show this help message"

.PHONY: all cuda cpu gpu run clean help
