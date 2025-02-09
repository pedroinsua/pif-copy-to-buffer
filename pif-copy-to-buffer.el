;;; pif-copy-kill-to-buffer.el --- Copy killed text to a buffer.  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Pedro Insua F.

;; Author: Pedro Insua F. <pedroinsua@gmail.com>
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Simple minor mode to copy current region to a buffer. It works in
;; normal text buffer and with pdf-view buffer.
;;
;; Usage:
;;   When 'pif-copy-to-buffer-minor-mode' is enabled copy the region
;; to the buffer set in the variable 'pif-copy-to-buffer-name'.
;;
;;  TODO
;;   - [ ] function to modify copied text.

;;; Code:
(defvar pif-copy-to-buffer-name nil
  "Buffer name to copy the text.")

(defvar pif-copy-to-buffer-insert-before ""
  "Text to be inserted before each copy.")

(defvar pif-copy-to-buffer-insert-after ""
  "Text to be inserted after each copy.")

(defvar pif-copy-to-buffer-copy-key "C-w"
  "Key binding to execute `pif-copy-to-buffer'.")

;; Functions
(defun pif-copy-to-buffer (beg end)
  "Copy region text to a buffer. Buffer is set in `pif-copy-to-buffer-name' variable."
  (interactive (list (region-beginning) (region-end)))
  (let ((buffer (and (not (null pif-copy-to-buffer-name))
                  (get-buffer pif-copy-to-buffer-name)))
         text)
    (if (not buffer)
      (message "No buffer set.")
      (cond
        ((string= major-mode "pdf-view-mode")
          (setq text (car (pdf-view-active-region-text)))
          (pdf-view-deactivate-region))
        (t (setq text (buffer-substring beg end))))

      (setq text (concat
                   pif-copy-to-buffer-insert-before
                   text
                   pif-copy-to-buffer-insert-after))

      (with-current-buffer buffer
        (insert text)
        (goto-char (point-max))
        (dolist (window (get-buffer-window-list nil nil t))
          (set-window-point window (point)))))))

(defun pif-copy-to-buffer-set-buffer (buffer)
  "Set the BUFFER to selected buffer or current buffer if selection is none."
  (interactive "b")
  (setq pif-copy-to-buffer-name buffer))

;;; ----------------------------------------
;;; Minor mode
;;; ----------------------------------------

(defun pif-copy-to-buffer-keymap ()
  "Keymap used for Pif Copy To Buffer minor mode."
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd pif-copy-to-buffer-copy-key) 'pif-copy-to-buffer)
    map))

(define-minor-mode pif-copy-to-buffer-minor-mode
  "Toggle Pif Copy To Buffer.
     Interactively with no argument, this command toggles the mode.
     A positive prefix argument enables the mode, any other prefix
     argument disables it.  From Lisp, argument omitted or nil enables
     the mode, `toggle' toggles the state.

     When pif-copy-to-buffer minor mode is enabled, the region is
     copied to buffer `pif-copy-to-buffer-name'."
  :init-value nil
  :lighter " PCTB"
  :keymap (pif-copy-to-buffer-keymap)

  (setf (cdr (assoc 'pif-copy-to-buffer-minor-mode minor-mode-map-alist)) (pif-copy-to-buffer-keymap)))

(define-globalized-minor-mode global-pif-copy-to-buffer-minor-mode pif-copy-to-buffer-minor-mode pif-copy-to-buffer-minor-mode)

(provide 'pif-copy-to-buffer)
;;; pif-copy-kill-to-buffer.el ends here
