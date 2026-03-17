(in-package :cl-gpu)

(defun SHOW-benchmark ()
  "Run both CPU and GPU vector addition benchmarks and display speedup."
  (format t "~%=========================================~%")
  (format t "  CPU vs GPU Vector Addition Benchmark~%")
  (format t "  Common Lisp + CUDA via CFFI~%")
  (format t "=========================================~%~%")

  (format t "--- CPU Benchmark ---~%~%")
  (let ((cpu-time (SHOW-cpu-vector-add)))

    (format t "~%--- GPU Benchmark ---~%~%")
    (let ((gpu-time (SHOW-gpu-vector-add)))

      (format t "~%=========================================~%")
      (format t "  COMPARISON~%")
      (format t "=========================================~%")
      (format t "CPU time: ~,4f seconds~%" cpu-time)
      (format t "GPU time: ~,4f seconds~%" gpu-time)
      (format t "Speedup:  ~,1fx~%" (/ cpu-time gpu-time))
      (format t "=========================================~%"))))

;;; end
