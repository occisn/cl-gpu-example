(asdf:defsystem "cl-gpu"
  :name "cl-gpu"
  :author "Nicolas Occis"
  :licence "MIT"
  :description "CPU vs GPU vector addition benchmark — Common Lisp + CUDA via CFFI"
  :depends-on (#:cffi)
  :serial t
  :around-compile (lambda (next)
                    (proclaim '(optimize (debug 0)
                                (safety 0)
                                (speed 3)))
                    (funcall next))
  :components ((:file "package")
               (:module "src"
                :components
                ((:file "cuda-bindings")
                 (:file "cpu-vector-add")
                 (:file "gpu-vector-add")
                 (:file "benchmark"))))
  :perform (load-op :after (op c)
                    (format t "~%Welcome in cl-gpu!~%~%Run (cl-gpu:SHOW-benchmark) for full CPU vs GPU comparison.~%~%")))
