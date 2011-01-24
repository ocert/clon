;;; package.lisp --- Common Lisp Package definition

;; Copyright (C) 2010, 2011 Didier Verna

;; Author:        Didier Verna <didier@lrde.epita.fr>
;; Maintainer:    Didier Verna <didier@lrde.epita.fr>

;; This file is part of Clon.

;; Clon is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License version 3,
;; as published by the Free Software Foundation.

;; Clon is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


;;; Commentary:

;; Contents management by FCM version 0.1.


;;; Code:

(in-package :cl-user)

(defpackage :com.dvlsoft.clon
  (:documentation "The Command-Line Options Nuker package.")
  (:use :cl)
  (:shadow :*readtable*)
  (:import-from :com.dvlsoft.clon.asdf
    :define-constant
    :+release-major-level+
    :+release-minor-level+
    :+release-status+
    :+release-status-level+
    :+release-name+
    :version)
  (:export
   ;; From com.dvlsoft.clon.asd:
   :+release-major-level+
   :+release-minor-level+
   :+release-status+
   :+release-status-level+
   :+release-name+
   :version
   ;; From package.lisp:
   :nickname-package
   ;; From src/util.lisp:
   :exit
   :cmdline
   :dump
   ;; From src/text.lisp:
   :make-text
   ;; From src/options/flag.lisp:
   :make-flag
   ;; From src/options/switch.lisp:
   :make-switch
   ;; From src/options/stropt.lisp:
   :make-stropt
   ;; From src/options/lispobj.lisp:
   :make-lispobj
   ;; From src/options/path.lisp:
   :make-path
   ;; From src/options/enum.lisp:
   :make-enum
   ;; From src/options/xswitch.lisp:
   :make-xswitch
   ;; From src/group.lisp:
   :make-group :defgroup
   ;; From src/synopsis.lisp:
   :*default-synopsis*
   :make-synopsis :defsynopsis
   ;; From src/context.lisp:
   :*current-context*
   :make-context
   :with-context
   :progname
   :remainder
   :getopt
   :getopt-cmdline
   :multiple-value-getopt-cmdline
   :do-cmdline-options
   :help))


(in-package :com.dvlsoft.clon)


;; -------------------
;; External utilities:
;; -------------------

(defun nickname-package (&optional (nickname :clon))
  "Add NICKNAME (:CLON by default) to the :COM.DVLSOFT.CLON package."
  (rename-package :com.dvlsoft.clon
		  (package-name :com.dvlsoft.clon)
		  (adjoin nickname (package-nicknames :com.dvlsoft.clon)
			  :test #'string-equal)))


;; -------------------
;; Internal utilities:
;; -------------------

(defvar *readtable* (copy-readtable)
  "The Clon readtable.")

(defun tilde-reader (stream char)
  "Read a series of ~\"strings\" to be concatenated together."
  (declare (ignore char))
  (apply #'concatenate 'string
	 (loop :for str := (read stream t nil t)
	       :then (progn (read-char stream t nil t)
			    (read stream t nil t))
	       :collect str
	       :while (eql (peek-char t stream nil nil t) #\~))))

(set-macro-character #\~ #'tilde-reader nil *readtable*)

;; ECL and CLISP do not like to see undefined reader macros in expressions
;; that belong to other compilers. For instance this will break:
;; #+ccl (#_ccl-only-function)
;; It seems to be a correct behavior (see *read-suppress* in CLHS), although
;; other implementations like SBCL and CMUCL are more gentle. The solution I
;; use is to define those reader macros to simply return nil.
#+(or ecl clisp)
(progn

  (defun dummy-reader (stream subchar args)
    "Return nil."
    (declare (ignore stream subchar args))
    nil)

  (set-dispatch-macro-character #\# #\_ #'dummy-reader *readtable*)
  (set-dispatch-macro-character #\# #\$ #'dummy-reader *readtable*))

(defmacro in-readtable (name)
  "Set the current readtable to the value of NAME::*READTABLE*."
  `(eval-when (:compile-toplevel :load-toplevel :execute)
    (setf cl:*readtable* (symbol-value (find-symbol "*READTABLE*" ,name)))))


;;; package.lisp ends here
