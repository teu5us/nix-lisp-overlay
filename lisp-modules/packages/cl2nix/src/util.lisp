(defpackage :cl2nix/util
  (:use #:common-lisp)
  (:export
   #:split-on-space
   #:split-on-slash
   #:split-on-dash
   #:split-on
   #:ends-with
   #:in-cl2nix-dir
   #:starts-with
   #:gassoc
   #:trim-end))

(in-package :cl2nix/util)

(defun split-on (str char)
  (uiop:split-string str :separator (list char)))

(defun split-on-space (str)
  (split-on str #\Space))

(defun split-on-slash (str)
  (split-on str #\/))

(defun split-on-dash (str)
  (split-on str #\-))

(defun starts-with (start str)
  (let ((start-position (search start str :test #'string=)))
    (values
     (when start-position
       (= 0 start-position))
     start-position)))

(defun ends-with (end str)
  (let ((end-position (search end str :from-end t :test #'string=)))
    (values
     (and end-position
          (= (length str) (+ end-position (length end))))
     end-position)))

(defun in-cl2nix-dir (pathname)
  (merge-pathnames pathname
                   (asdf:system-source-directory :cl2nix)))

(defun gassoc (list key value)
  (flet ((getf-1 (seq)
           (getf seq key)))
    (find value list :key #'getf-1 :test #'string=)))

(defun trim-end (end str)
  (multiple-value-bind (ends-with end-position)
      (ends-with end str)
    (if ends-with
        (subseq str 0 end-position)
        str)))

(defun %string-fixups (str)
  (let ((replacements '((#\+ "_plus_")
                        (#\/ "_slash_"))))
    (reverse
     (loop :for c :across str
           :for n :from 0 :to (length str)
           :when (member c (mapcar #'car replacements)
                         :test #'char=)
             :collect (list
                       n
                       (cadr (assoc c replacements :test #'char=)))))))

(defun fixname (str &optional (fixups nil fixups-set))
  (if fixups
      (destructuring-bind (pos fix) (car fixups)
        (let ((before (subseq str 0 pos))
              (after (subseq str (+ 1 pos))))
          (fixname (concatenate 'string before fix after)
               (cdr fixups))))
      (if fixups-set
          str
          (fixname str (%string-fixups str)))))

(defun all (lst pred)
  (loop for v in lst
        with result = t
        unless (funcall pred v)
          do (setf result nil)
        finally (return result)))

(defun any (lst pred)
  (loop for v in lst
        with result = nil
        when (funcall pred v)
          do (setf result t)
        finally (return result)))
