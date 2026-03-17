# Makefile for CUDA shared library

NVCC = nvcc
NVCCFLAGS = -O3 --shared --compiler-options '-fPIC'

TARGET = libclgpu.so
SRC = cuda-wrappers.cu

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(NVCCFLAGS) -o $(TARGET) $(SRC)
	@echo "Built $(TARGET) successfully!"

clean:
	rm -f $(TARGET)

.PHONY: all clean
