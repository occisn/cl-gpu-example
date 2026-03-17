(in-package :cl-gpu)

(defun %gpu-vector-add ()
  "Perform GPU vector addition of +N+ single-float elements via CUDA and report results."
  (let ((bytes (* +n+ (cffi:foreign-type-size :float)))
        (block-size +threads-per-block+)
        (num-blocks (ceiling +n+ +threads-per-block+)))

    ;; 1. Allocate host arrays
    (let ((h-a (cffi:foreign-alloc :float :count +n+))
          (h-b (cffi:foreign-alloc :float :count +n+))
          (h-c (cffi:foreign-alloc :float :count +n+)))
      (declare (ignore bytes))
      (unwind-protect
           (progn
             ;; 2. Initialize host arrays
             (format t "Initializing vectors with ~a elements...~%" +n+)
             (loop for i from 0 below +n+ do
               (setf (cffi:mem-aref h-a :float i) (coerce i 'single-float))
               (setf (cffi:mem-aref h-b :float i) (* 2.0 (coerce i 'single-float))))

             ;; 3. Allocate device memory
             (with-cuda-memory (d-a +n+)
               (with-cuda-memory (d-b +n+)
                 (with-cuda-memory (d-c +n+)

                   ;; 4. Copy H->D
                   (format t "Copying data to GPU...~%")
                   (cuda-memcpy-host-to-device d-a h-a +n+)
                   (cuda-memcpy-host-to-device d-b h-b +n+)

                   ;; 5. Launch kernel with timing
                   (format t "Performing GPU vector addition...~%")
                   (format t "Grid size: ~a blocks, Block size: ~a threads~%"
                           num-blocks block-size)

                   (let ((gpu-time-ms
                           (with-cuda-timing (elapsed)
                             (launch-vector-add d-a d-b d-c +n+
                                                num-blocks block-size))))
                     (let ((gpu-time (/ gpu-time-ms 1000.0)))

                       ;; 6. Copy D->H
                       (cuda-memcpy-device-to-host h-c d-c +n+)

                       ;; 7. Verify first 5 elements
                       (format t "~%Verification (first 5 elements):~%")
                       (loop for i from 0 below 5 do
                         (format t "c[~a] = ~,2f (expected ~,2f)~%"
                                 i
                                 (cffi:mem-aref h-c :float i)
                                 (+ (cffi:mem-aref h-a :float i)
                                    (cffi:mem-aref h-b :float i))))

                       ;; 8. Report results
                       (format t "~%=== GPU RESULTS ===~%")
                       (format t "GPU: ~a~%" (cuda-get-device-name))
                       (format t "Time taken: ~,4f seconds~%" gpu-time)
                       (format t "Elements processed: ~a~%" +n+)
                       (format t "Throughput: ~,2f million elements/second~%"
                               (/ (/ +n+ gpu-time) 1000000.0d0))

                       gpu-time))))))

        ;; 10. Free host memory
        (cffi:foreign-free h-a)
        (cffi:foreign-free h-b)
        (cffi:foreign-free h-c)))))

(defun SHOW-gpu-vector-add ()
  (%gpu-vector-add))

;;; end
