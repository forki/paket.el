;;; paket.el --- Paket tooling for Emacs

;; Copyright © 2015 Martyn Osborne
;;
;; Author: Martyn Osborne <zzdtri@live.co.uk>

;; URL: https://github.com/zzdtri/paket.el
;; Package-Requires: ((emacs "24")
;; Keywords: paket


;;; Commentary:
;;

;;; Code:

(defgroup paket nil
  "Paket tooling for Emacs"
  :link '(url-link :tag "Github" "https://github.com/zzdtri/paket.el")
  :group 'applications
  :prefix "paket-")

(require 'compile)

(defconst paket-buffer-name "*paket*"
  "The buffer for Paket results.")

(defcustom paket-program-name "paket"
  "The shell command for Paket."
  :group 'paket
  :type 'string)

(defcustom paket-hard-by-default t
  "Whether to add the --hard switch to commands."
  :group 'paket
  :type 'boolean)

(define-compilation-mode paket-buffer-mode "Paket"
  "Paket buffer mode.")

(defun paket-install ()
  (interactive)
  (paket--send-command "paket install"))

(defun paket-add-nuget (package)
  (interactive
   (list
    (read-string "Package name:")))
  (paket--send-command (concat "paket add nuget " package)))

(defun paket-outdated ()
  (interactive)
  (paket--send-command "paket outdated"))

(defun paket--add-switches (command)
  (if paket-hard-by-default
      (concat command " --hard")
    command))

(defun paket--send-command (command)
  (let ((default-directory (paket--find-root)))
    (if default-directory
        (with-current-buffer
            (compilation-start (paket--add-switches command)
                               nil
                               (lambda (x) paket-buffer-name)))
      (message "Unable to find paket.dependencies"))))

(defun paket--find-root ()
  (locate-dominating-file
   (file-name-as-directory
    (file-name-directory buffer-file-name))
   "paket.dependencies"))

(defun paket--overlay-new-version (version)
  (overlay-put
   (make-overlay
    (line-beginning-position)
    (line-end-position))
   'after-string
   (concat " " version)))

(defun paket--remove-overlays () (remove-overlays))

(defvar dependencies-keywords
  '(("nuget \\|source \\|github " . font-lock-keyword-face)
    (".*\s.*\s\\(.*\\)" (1 font-lock-string-face))))

(defvar paket-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-i" 'paket-install)
    (define-key map "\C-c\C-a" 'paket-add-nuget)
    (define-key map "\C-c\C-o" 'paket-outdated)
    map))

(define-derived-mode paket-mode prog-mode
  "Major mode for editing paket.dependencies files

\\{paket-mode-map}"

  (use-local-map paket-mode-map)

  (setq font-lock-defaults '(dependencies-keywords))
  (setq mode-name "Paket"))

;;;###autoload
(add-to-list 'auto-mode-alist '("paket.dependencies" . paket-mode))

(provide 'paket)

;;; paket.el ends here
