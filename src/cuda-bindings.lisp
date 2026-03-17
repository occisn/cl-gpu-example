(in-package :cl-gpu)

;; Define shared library — resolve path at read time via ASDF
(cffi:define-foreign-library libclgpu
  (:unix (:or
          #.(namestring
             (merge-pathnames "cuda/libclgpu.so"
                              (asdf:system-source-directory "cl-gpu")))
          "libclgpu.so")))

;; Load the shared library
(cffi:use-foreign-library libclgpu)

;; --- Memory management ---

(cffi:defcfun ("cuda_malloc_floats" cuda-malloc-floats) :pointer
  (n :int))

(cffi:defcfun ("cuda_free" cuda-free) :void
  (d-ptr :pointer))

;; --- Host <-> Device transfers ---

(cffi:defcfun ("cuda_memcpy_host_to_device" cuda-memcpy-host-to-device) :void
  (d-dst :pointer)
  (h-src :pointer)
  (n :int))

(cffi:defcfun ("cuda_memcpy_device_to_host" cuda-memcpy-device-to-host) :void
  (h-dst :pointer)
  (d-src :pointer)
  (n :int))

;; --- Timing ---

(cffi:defcfun ("cuda_event_create" cuda-event-create) :pointer)

(cffi:defcfun ("cuda_event_record" cuda-event-record) :void
  (event :pointer))

(cffi:defcfun ("cuda_event_synchronize" cuda-event-synchronize) :void
  (event :pointer))

(cffi:defcfun ("cuda_event_elapsed_ms" cuda-event-elapsed-ms) :float
  (start :pointer)
  (stop :pointer))

(cffi:defcfun ("cuda_event_destroy" cuda-event-destroy) :void
  (event :pointer))

;; --- Kernel launcher ---

(locally
    (declare (sb-ext:muffle-conditions sb-ext:compiler-note))
  (cffi:defcfun ("launch_vector_add" launch-vector-add) :void
    (d-a :pointer)
    (d-b :pointer)
    (d-c :pointer)
    (n :int)
    (blocks :int)
    (threads-per-block :int)))

;; --- Device info ---

(cffi:defcfun ("cuda_get_device_name" %cuda-get-device-name) :void
  (buf :pointer)
  (buflen :int))

(defun cuda-get-device-name ()
  (cffi:with-foreign-object (buf :char 256)
    (%cuda-get-device-name buf 256)
    (cffi:foreign-string-to-lisp buf)))

;; --- CL convenience macros ---

(defmacro with-cuda-memory ((var n) &body body)
  "Allocate N floats on GPU device, bind device pointer to VAR, free on exit."
  `(let ((,var (cuda-malloc-floats ,n)))
     (unwind-protect
          (progn ,@body)
       (cuda-free ,var))))

(defmacro with-cuda-timing ((elapsed-var) &body body)
  "Execute BODY between CUDA event records, bind elapsed milliseconds to ELAPSED-VAR."
  (let ((start (gensym "START"))
        (stop (gensym "STOP")))
    `(let ((,start (cuda-event-create))
           (,stop (cuda-event-create)))
       (unwind-protect
            (progn
              (cuda-event-record ,start)
              ,@body
              (cuda-event-record ,stop)
              (cuda-event-synchronize ,stop)
              (let ((,elapsed-var (cuda-event-elapsed-ms ,start ,stop)))
                ,elapsed-var))
         (cuda-event-destroy ,start)
         (cuda-event-destroy ,stop)))))

;;; end
