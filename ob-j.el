;;; ob-j.el --- org-babel functions for J - http://jsoftware.com/

;;;Copyright (c) 2013 Joe Bogner
;;;
;;;Permission is hereby granted, free of charge, to any person obtaining a copy
;;;of this software and associated documentation files (the "Software"), to deal
;;;in the Software without restriction, including without limitation the rights
;;;to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;;;copies of the Software, and to permit persons to whom the Software is
;;;furnished to do so, subject to the following conditions:
;;;
;;;The above copyright notice and this permission notice shall be included in
;;;all copies or substantial portions of the Software.
;;;
;;;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;;FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;;;AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;;LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;;OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;;;THE SOFTWARE.

;; Author: Joe Bogner
;; Keywords: literate programming, reproducible research, scheme
;; Homepage: http://orgmode.org

;; This file is not part of GNU Emacs.

;; Tested with J version 8
;;
;; This certainly isn't optimally robust, but it seems to be working
;; for the basic use cases.

;;; Requirements:
;;; (setq j-program-name "C:/.../Downloads/j64-801/bin/jconsole.exe")
;;; Add to list of babel languages (for example:)
;;; (org-babel-do-load-languages
;;;      'org-babel-load-languages
;;      '((emacs-lisp . t)
;;        (sh . t)
;;        (j . t)))


(require 'ob)
(eval-when-compile (require 'cl))

(defvar org-babel-j-eoe-indicator "smoutput '_done_'" "Command to output completion indicator.")
(defvar org-babel-j-eoe-output "_done_" "String to indicate completion")

(defvar j-program-name)
(defun org-babel-execute:j (body params)
  "Execute a block of j code with org-babel. This function is called by `org-babel-execute-src-block'"
  (let* ((result-type (cdr (assoc :result-type params)))
	 (result (if (not (string= (cdr (assoc :session params)) "none"))
                 (let*
                     ((session (org-babel-j-initiate-session (cdr (assoc :session params))))
                      (raw (org-babel-comint-with-output
                                  (session org-babel-j-eoe-output t body)
                                (mapc
                                 (lambda (line)
                                   (insert (org-babel-chomp line))
                                   (comint-send-input nil t))
                                 (list body org-babel-j-eoe-indicator)))))
                   (if (string-match "+" (car (cdr raw)))
                       (mapconcat ;; <- joins the list back together into a single string
                        #'identity
                        (butlast (butlast (cdr (mapcar #'org-babel-trim raw))))
                        "\n")
                   (butlast (mapcar
                       #'org-babel-j-read
                       (butlast (cdr raw))))))
               ;; external evaluation
               (message "external evaluation is not implemented"))))
    (org-babel-result-cond (cdr (assoc :result-params params)) result result)))

(defun org-babel-j-read (results)
  "Convert RESULTS into an appropriate elisp value.
If RESULTS look like a table, then convert them into an
Emacs-lisp table, otherwise return the results as a string."
  (org-babel-read
   (if (and (stringp results) (string-match "\n" results))
       (org-babel-read
        (concat "'(" results ")"))
     results)))

(defun org-babel-j-initiate-session (&optional session)
  "If there is not a current inferior-process-buffer in SESSION
then create.  Return the initialized session."
  (make-comint-in-buffer session nil j-program-name nil))

(provide 'ob-j)
;;; ob-j.el ends here
