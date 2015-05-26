;;; indent-of-doom.el --- A minor mode and EDSL to manage your mode's indentation rules.

;; Copyright (C) 2015  Kevin W. van Rooijen

;; Author: Kevin W. van Rooijen <kevin.van.rooijen@attichacker.com>
;; Keywords: convenience, matching, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; A library which let's you set your custom indentation rules using a small EDSL.
;;
;; Functions:
;;
;; * indent-of-doom
;;
;; EDSL Functions:
;; * iod/next-tab
;; * iod/current-tab
;; * iod/prev-char
;; * iod/next-char
;; * iod/current-char
;; * iod/prev
;; * iod/next
;; * iod/current
;; * iod/ends-on
;; * iod/starts-with
;; * iod/contains
;;
;;; Code:

(defgroup indent-of-doom ()
  "Customize group for indent-of-doom.el"
  :prefix "indent-of-doom-"
  :group 'indent)

(defcustom iod--use-tab-cycle t
  "Use tab of doom to cycle through 3 indentations depending on previous line."
  :type 'boolean
  :group 'indent-of-doom)

(defcustom iod--skip-empty-lines nil
  "If you're comparing to 'previous line' it must contain characters."
  :type 'boolean
  :group 'indent-of-doom)

(defcustom iod--cycle-zero nil
  "When cycling through the 3 indentation you also cycle to the beginning of the line."
  :type 'boolean
  :group 'indent-of-doom)

(defcustom iod--indent-key "TAB"
  "The key to run tab-of-doom."
  :type '(string)
  :group 'indent-of-doom)

(defvar iod--rules '())

;;;###autoload
(defun indent-of-doom ()
  "Indent current line using Indent of doom.
This will indent the current line according to your doom rules."
  (interactive)
  (let ((rule (iod--get-rule)))
    (if rule (eval rule) (iod--fallback))))

;;;###autoload
(defun iod--fallback ()
  "If no rules are applicable then use the fallback function.
If 'iod--use-tab-cycle' is non nil use the 3 indentation cycling.
If 'iod--use-tab-cycle' is nil then use 'indent-for-tab-command.'"
  (if iod--use-tab-cycle
      (iod--cycle)
    (indent-for-tab-command)))

;;;###autoload
(defun iod--indent (num)
  "Indent the current line by the amount of provided in NUM."
  (unless (equal (iod--current-indent) num)
    (let ((ccn (+ (current-column) (- num (iod--current-indent)))))
      (beginning-of-line)
      (just-one-space 0)
      (insert (make-string num ?\s))
      (move-to-column ccn))))

;;;###autoload
(defun iod--cycle ()
  "Cycle through 3 indentations depending on the previous line."
  (let* ((c (iod--current-indent))
         (p (iod--prev-indent))
         (w (cond
             ((< c (- p tab-width)) (- p tab-width))
             ((< c p) p)
             ((equal c p) (+ p tab-width))
             ((equal c p) (+ p tab-width))
             (t  (if iod--cycle-zero 0 (- p tab-width))))))
    (iod--indent (if (< w 0) 0 w ))))

;;;###autoload
(defun iod--prev-indent ()
  "Get the amount of indentation spaces if the previous line."
  (save-excursion
    (previous-line 1)
    (while (and (iod--line-empty?) iod--skip-empty-lines)
      (previous-line 1))
    (back-to-indentation)
    (current-column)))

;;;###autoload
(defun iod--next-indent ()
  "Get the amount of indentation spaces if the next line."
  (save-excursion
    (next-line 1)
    (while (and (iod--line-empty?) iod--skip-empty-lines)
      (next-line 1))
    (back-to-indentation)
    (current-column)))

;;;###autoload
(defun iod--current-indent ()
  "Get the amount of indentation spaces if the current line."
  (save-excursion
    (back-to-indentation)
    (current-column)))

;;;###autoload
(defun iod--get-next-line ()
  "Get the next line as a string."
  (save-excursion
    (next-line 1)
    (while (and (iod--line-empty?) iod--skip-empty-lines)
      (next-line 1))
    (iod--get-current-line)))

;;;###autoload
(defun iod--get-prev-line ()
  "Get the previous line as a string."
  (save-excursion
    (previous-line 1)
    (while (and (iod--line-empty?) iod--skip-empty-lines)
      (previous-line 1))
    (iod--get-current-line)))

;;;###autoload
(defun iod--get-current-line ()
  "Get the current line as a string."
  (buffer-substring-no-properties (point-at-bol) (point-at-eol)))

;;;###autoload
(defun iod--line-empty? ()
  "Check if the current line is empty."
  (string-match "^\s*$" (iod--get-current-line)))

;;;###autoload
(defun iod--rules ()
  "Check if the current line is empty."
  ;; i-have-no-idea-what-im-doing.jpg
  "Get the indent rules of the current major mode as well as the default 'all' rules"
  (let ((result (cdr (assoc (with-current-buffer (buffer-name) major-mode) iod--rules)))
        (all (cdr (assoc 'all iod--rules))))
    (append (if result result '()) all)))

;;;###autoload
(defun iod--get-rule ()
  "Get the defined rules of the current major mode and the 'all' rules."
  (let* ((filter-list (remove-if-not (lambda(x) (eval (car x))) (iod--rules))))
    (car (last (car filter-list)))))

;;;###autoload
(defun iod--escape-regexp (reg)
  "Escape regexp.
Argument REG regular expression to escape."
  (replace-regexp-in-string "\\[" "\\\\[" reg))

;; EDSL

;;;###autoload
(defun iod/prev-tab (&optional num)
  "Indent the current line by previous line indentation + tab-with * NUM."
  (iod--indent (+ (iod--prev-indent) (* (if num num 0) tab-width))))

;;;###autoload
(defun iod/next-tab (&optional num)
  "Indent the current line by next line indentation + tab-with * NUM."
  (iod--indent (+ (iod--next-indent) (* (if num num 0) tab-width))))

;;;###autoload
(defun iod/current-tab (&optional num)
  "Indent the current by NUM."
  (iod--indent (if num num 0)))

;;;###autoload
(defun iod/prev-char (&optional num)
  "Indent the current line by previous line indentation + NUM."
  (iod--indent (+ (iod--prev-indent) (if num num 0))))

;;;###autoload
(defun iod/next-char (&optional num)
  "Indent the current line by next line indentation + NUM."
  (iod--indent (+ (iod--next-indent) (if num num 0))))

;;;###autoload
(defun iod/current-char (&optional num)
  "Indent the current line by NUM."
  (iod--indent (if num num 0)))

;;;###autoload
(defun iod/prev (function &rest values)
  "Apply a line check on the previous line using the EDSL FUNCTIONs.
Optional argument VALUES Values to compare with."
  "Previous line as a target"
  (funcall function (iod--get-prev-line) values))

;;;###autoload
(defun iod/next (function &rest values)
  "Apply a line check on the next line using the EDSL FUNCTIONs.
Optional argument VALUES Values to compare with."
  (funcall function (iod--get-next-line) values))

;;;###autoload
(defun iod/current (function &rest values)
  "Apply a line check on the current line using the EDSL FUNCTIONs.
Optional argument VALUES Values to compare with."
  (funcall function (iod--get-current-line) values))

;;;###autoload
(defun iod/ends-on (line values)
  "Check if LINE ends on one of the following strings.
Argument VALUES Values to compare with."
  (remove-if-not (lambda (x)
                   (string-match (concat (escape-regexp x) "\s*$") line)) values))

;;;###autoload
(defun iod/starts-with (line values)
  "Check if LINE start with one of the following strings.
Argument VALUES Values to compare with."
  (remove-if-not (lambda (x)
                   (string-match (concat "^\s*" (escape-regexp x) ) line)) values))

;;;###autoload
(defun iod/contains (line values)
  "Check if LINE has any of the following strings (regexp).
Argument VALUES Values to compare with."
  (remove-if-not (lambda (x) (string-match x line)) values))

(defvar indent-of-doom-mode-map (make-keymap) "Indent-of-doom-mode keymap.")

(define-minor-mode indent-of-doom-mode
  "One indentation mode to rule them all."
  nil " IoD" 'indent-of-doom-mode-map)

(define-key indent-of-doom-mode-map (kbd iod--indent-key) 'indent-of-doom)

(provide 'indent-of-doom)
;;; indent-of-doom.el ends here

