;;; paket.el --- Paket tooling for Emacs

;; Copyright © 2015 Martyn Osborne
;;
;; Author: Martyn Osborne <zzdtri@live.co.uk>

;; URL: https://github.com/zzdtri/paket.el
;; Package-Requires: ((emacs "24")
;; Keywords: paket

;;; Commentary:

;; Paket tooling for Emacs

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

(defcustom paket-hard-by-default nil
  "Whether to add the --hard switch to commands."
  :group 'paket
  :type 'boolean)

(defcustom paket-cache-packages-on-load t
  "Whether to load and cache packages on load"
  :group 'paket
  :type 'boolean)

(defvar paket-executable "paket.exe")

(defun paket-find-executable (executable)
  (locate-file executable load-path))

(require 'paket-bootstrap)
(require 'paket-commands)
(require 'paket-add)
(require 'paket-remove)

(define-compilation-mode paket-buffer-mode "Paket"
  "Paket buffer mode.")

(defvar nuget-line-regex "\\(nuget\s.*?\\)[\s\n]")

(defun get-package-at-line ()
  (let ((line (thing-at-point 'line)))
    (string-match nuget-line-regex line)
    (match-string 1 line)))

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
    (define-key map (kbd "C-c C-i") 'paket-install)
    (define-key map (kbd "C-c C-a") 'paket-add-nuget)
    (define-key map (kbd "C-c C-o") 'paket-outdated)
    (define-key map (kbd "C-c C-r r") 'paket-restore)
    (define-key map (kbd "C-c C-u") 'paket-update)
    (define-key map (kbd "C-c C-r m") 'paket-remove-nuget)
    map))

(define-derived-mode paket-mode prog-mode
  "Major mode for editing paket.dependencies files

\\{paket-mode-map}"

  (use-local-map paket-mode-map)

  (setq font-lock-defaults '(dependencies-keywords))
  (setq mode-name "Paket"))

;;;###autoload
(add-to-list 'auto-mode-alist '("paket.dependencies" . paket-mode))

(easy-menu-define paket-mode-menu paket-mode-map
  "Paket mode menu."
  '("Paket"
    ["Add Nuget" paket-add-nuget]
    ["Install" paket-install]
    ["Outdated" paket-outdated]
    ["Remove Nuget" paket-remove-nuget]
    ["Restore" paket-restore]
    ["Update" paket-update]))

(provide 'paket)

;;; paket.el ends here
