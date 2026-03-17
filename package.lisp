(defpackage :cl-gpu
  (:use :cl)
  (:export
   ;; CUDA bindings
   #:cuda-malloc-floats
   #:cuda-free
   #:cuda-memcpy-host-to-device
   #:cuda-memcpy-device-to-host
   #:cuda-event-create
   #:cuda-event-record
   #:cuda-event-synchronize
   #:cuda-event-elapsed-ms
   #:cuda-event-destroy
   #:launch-vector-add
   #:cuda-get-device-name
   ;; CL convenience macros
   #:with-cuda-memory
   #:with-cuda-timing
   ;; Benchmarks
   #:SHOW-cpu-vector-add
   #:SHOW-gpu-vector-add
   #:SHOW-benchmark))
