(in-package :cl-gpu)

(defconstant +n+ 100000000 "100 million elements")
(defconstant +threads-per-block+ 256)

(defun %cpu-vector-add ()
  "Perform CPU vector addition of +N+ single-float elements and report results."
  (let ((a (make-array +n+ :element-type 'single-float))
        (b (make-array +n+ :element-type 'single-float))
        (c (make-array +n+ :element-type 'single-float)))
    (declare (type (simple-array single-float (*)) a b c))

    ;; Initialize vectors
    (format t "Initializing vectors with ~a elements...~%" +n+)
    (loop for i fixnum from 0 below +n+ do
      (setf (aref a i) (coerce i 'single-float))
      (setf (aref b i) (* 2.0 (coerce i 'single-float))))

    ;; Perform addition and measure time
    (format t "Performing CPU vector addition...~%")
    (let* ((start (get-internal-real-time))
           (_ (progn
                (loop for i fixnum from 0 below +n+ do
                  (setf (aref c i) (+ (aref a i) (aref b i))))))
           (end (get-internal-real-time))
           (cpu-time (/ (coerce (- end start) 'double-float)
                        (coerce internal-time-units-per-second 'double-float))))
      (declare (ignore _))

      ;; Verify result
      (format t "~%Verification (first 5 elements):~%")
      (loop for i from 0 below 5 do
        (format t "c[~a] = ~,2f (expected ~,2f)~%" i (aref c i) (+ (aref a i) (aref b i))))

      ;; Report results
      (format t "~%=== CPU RESULTS ===~%")
      (format t "Time taken: ~,4f seconds~%" cpu-time)
      (format t "Elements processed: ~a~%" +n+)
      (format t "Throughput: ~,2f million elements/second~%"
              (/ (/ +n+ cpu-time) 1000000.0d0))

      cpu-time)))

(defun SHOW-cpu-vector-add ()
  (%cpu-vector-add))

;;; end
