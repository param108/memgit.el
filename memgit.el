;;; memgit --- An in memory git for fast iteration -*- lexical-binding: t; -*-


;; Author: param108 <param.ponnaiyan@gmail.com>
;; Maintainer: param108 <param.ponnaiyan@gmail.com>
;; Created: May 16, 2025
;; Modified: May 16, 2025
;; Version: 0.0.1
;; Keywords: files, versioning
;; Homepage: https://github.com/param108/memgit.el
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;; memgit-mode is a minor mode for versioning files in Emacs. It provides
;; functionality to save, load, and manage file versions in a cache directory.
;;
;;; Code:
(defvar memgit-versions (make-hash-table :test 'equal)
  "Global hash table to store memgit versions.
Keys are absolute file paths, and values are version numbers.")

(defvar memgit-cache-dir "~/memgit-cache/"
  "Directory where memgit stores cached files.")

(defvar memgit-mode-map (make-sparse-keymap)
  "Keymap for `memgit-mode'.")

;; Add key bindings to the keymap
(define-key memgit-mode-map (kbd "C-c m n") 'memgit-replace-with-next-version)
(define-key memgit-mode-map (kbd "C-c m p") 'memgit-replace-with-previous-version)
(define-key memgit-mode-map (kbd "C-c m v") 'memgit-current-version)
(define-key memgit-mode-map (kbd "C-c m d") 'memgit-current-description)
(define-key memgit-mode-map (kbd "C-c m s") 'memgit-copy-current-buffer-file-to-numbered-file)
(define-key memgit-mode-map (kbd "C-c m x") 'memgit-clear-all-versions)


(message "loading memgit-setup")
(defun memgit-setup ()
  "Set up the `memgit-cache-dir` directory`."
  (interactive)
  (let ((versions-file (expand-file-name "memgit-versions" memgit-cache-dir)))
    (unless (file-directory-p memgit-cache-dir)
      (make-directory memgit-cache-dir t)
      (with-temp-file versions-file
        (insert (prin1-to-string (make-hash-table :test 'equal))))
      (message "Created `memgit-cache-dir` and initialized `memgit-versions` file."))))

(defun memgit-load-versions ()
  "Load the `memgit-versions` hash table from a file in `memgit-cache-dir`."
  (interactive)
  (let ((file-path (expand-file-name "memgit-versions" memgit-cache-dir)))
    (if (file-exists-p file-path)
        (with-temp-buffer
          (insert-file-contents file-path)
          (setq memgit-versions (read (buffer-string)))
          (message "Loaded memgit-versions from %s" file-path))
      (message "No memgit-versions file found in %s" memgit-cache-dir))))

(defun memgit-current-version ()
  "Get the current version of the file in the current buffer."
  (interactive)
  (let ((file-path (buffer-file-name)))
    (if file-path
        (let* ((absolute-file-path (expand-file-name file-path)))
          (if (gethash absolute-file-path memgit-versions)
              (let ((version (memgit-get-version absolute-file-path)))
                (if version
                    (message "Current version: %d" version)
                  (message "No version found for: %s" absolute-file-path)))
            (message "No entry found for: %s" absolute-file-path)))
      (message "Buffer is not visiting a file."))))

(defun memgit-current-description ()
  "Get the current description of the file in the current buffer."
  (interactive)
  (let ((file-path (buffer-file-name)))
    (if file-path
        (let* ((absolute-file-path (expand-file-name file-path)))
          (if (gethash absolute-file-path memgit-versions)
              (let ((description (memgit-get-description absolute-file-path)))
                (if description
                    (message "Current description: %s" description)
                  (message "No description found for: %s" absolute-file-path)))
            (message "No entry found for: %s" absolute-file-path)))
      (message "Buffer is not visiting a file."))))

(defun memgit-get-version (absolute-path)
  "Get the version number for the given ABSOLUTE-PATH from `memgit-versions`.
Returns nil if the path is not found."
  (let ((entry (gethash absolute-path memgit-versions)))
    (when entry
      (car entry)))) ; Return the first element of the list (version number)

(defun memgit-get-description (absolute-path)
  "Get the description for the given ABSOLUTE-PATH from `memgit-versions`.
Returns nil if the path is not found."
  (let ((entry (gethash absolute-path memgit-versions)))
    (when entry
      (cadr entry)))) ; Return the second element of the list (description)

(defun memgit-set-version (absolute-path version description)
  "Set VERSION, DESCRIPTION for ABSOLUTE-PATH in `memgit-versions`."
  (puthash absolute-path (list version description) memgit-versions))

(defun memgit-read-file (file-path)
  "Read the contents of the file at FILE-PATH and return it as a string."
  (with-temp-buffer
    (insert-file-contents file-path)
    (buffer-string)))

(defun memgit-write-file (file-path content)
  "Write CONTENT to  the file at FILE-PATH."
  (with-temp-file file-path
    (insert content)))

(define-minor-mode memgit-mode
  "A minor mode for memgit version tracking."
  :lighter " MemGit"
  :keymap memgit-mode-map
  :global nil
  (if memgit-mode
      (progn
        ;; Initialize the file's version in `memgit-versions` if no entry exists
        (let ((file-path (buffer-file-name)))
          (if file-path
              (let ((absolute-file-path (expand-file-name file-path)))
                (unless (memgit-get-version absolute-file-path)
                  (memgit-set-version absolute-file-path -1 "none")
                  (message "Initialized memgit version for: %s" absolute-file-path)))
            (message "Buffer is not visiting a file, memgit-mode not initialized.")))

        (defun memgit-save-versions ()
          "Save the `memgit-versions` hash table to a file in `memgit-cache-dir`."
          (let ((file-path (expand-file-name "memgit-versions" memgit-cache-dir)))
            (make-directory memgit-cache-dir t)
            (with-temp-file file-path
              (insert (prin1-to-string memgit-versions)))
            (message "Saved memgit-versions to %s" file-path)))

        ;; Define functions that are only available in `memgit-mode`
        (defun memgit-copy-current-buffer-file-to-numbered-file (description)
          "Copy the file of the current buffer to `memgit-cache-dir`"
          (interactive "sDescription: ")
          (let ((file-path (buffer-file-name)))
            (if file-path
                (let* ((absolute-file-path (expand-file-name file-path))
                       (relative-path (file-relative-name absolute-file-path "/"))
                       (destination-dir (expand-file-name (file-name-directory relative-path) memgit-cache-dir))
                       (numbered-filename (let ((n 1))
                                            (while (file-exists-p (expand-file-name (number-to-string n) destination-dir))
                                              (setq n (1+ n)))
                                            (number-to-string n)))
                       (destination (expand-file-name numbered-filename destination-dir)))
                  (make-directory destination-dir t)
                  (copy-file absolute-file-path destination t)
                  (memgit-write-file
                   (expand-file-name (concat numbered-filename ".desc") destination-dir)
                   description)
                  (memgit-set-version absolute-file-path
                                      (string-to-number numbered-filename)
                                      description)
                  (memgit-save-versions)
                  (message "File copied to: %s (Version: %s)" destination numbered-filename))
              (message "Current buffer is not visiting a file."))))

        (defun memgit-replace-with-previous-version ()
          "Replace the current buffer's file with its previous version"
          (interactive)
          (if (memgit-check-differences)
              (message "Please save the current file.")
            (let ((file-path (buffer-file-name)))
              (if file-path
                  (let* ((absolute-file-path (expand-file-name file-path))
                         (current-version (memgit-get-version absolute-file-path))
                         (previous-version (and current-version (1- current-version)))
                         (previous-file (when previous-version
                                          (expand-file-name
                                           (concat (file-relative-name (file-name-directory absolute-file-path) "/")
                                                   (number-to-string previous-version))
                                           memgit-cache-dir)))
                         (previous-description (when previous-version
                                                 (expand-file-name
                                                  (concat (file-relative-name (file-name-directory absolute-file-path) "/")
                                                          (concat (number-to-string previous-version) ".desc"))
                                                  memgit-cache-dir))))
                    (if (and previous-version (file-exists-p previous-file))
                        (progn
                          ;; Replace the current file with the previous version
                          (copy-file previous-file absolute-file-path t)
                          ;; Revert the buffer to reflect the changes
                          (revert-buffer t t t)
                          ;; Update `memgit-versions` with the new version number
                          (memgit-set-version absolute-file-path previous-version (memgit-read-file  previous-description))
                          (memgit-save-versions)
                          (message "Replaced with previous version: %s (Version: %d)" previous-file previous-version))
                      (message "Previous version does not exist.")))
                (message "Current buffer is not visiting a file.")))))

        (defun memgit-replace-with-next-version ()
          "Replace the current buffer's file with its next version"
          (interactive)
          (if (memgit-check-differences)
              (message "Please save the current file.")
            (let ((file-path (buffer-file-name)))
              (if file-path
                  (let* ((absolute-file-path (expand-file-name file-path))
                         (current-version (memgit-get-version absolute-file-path))
                         (next-version (and current-version (1+ current-version)))
                         (next-file (when next-version
                                      (expand-file-name
                                       (concat (file-relative-name (file-name-directory absolute-file-path) "/")
                                               (number-to-string next-version))
                                       memgit-cache-dir)))
                         (next-description (when next-version
                                             (expand-file-name
                                              (concat (file-relative-name (file-name-directory absolute-file-path) "/")
                                                      (concat (number-to-string next-version) ".desc"))
                                              memgit-cache-dir))))
                    (if (and next-version (file-exists-p next-file))
                        (progn
                          ;; Replace the current file with the next version
                          (copy-file next-file absolute-file-path t)
                          ;; Revert the buffer to reflect the changes
                          (revert-buffer t t t)
                          ;; Update `memgit-versions` with the new version number
                          (memgit-set-version absolute-file-path next-version (memgit-read-file  next-description))
                          (memgit-save-versions)
                          (message "Replaced with next version: %s (Version: %d)" next-file next-version))
                      (message "Next version does not exist.")))
                (message "Current buffer is not visiting a file.")))))

        (defun memgit-check-differences ()
          "Check if there is a difference between the file in the buffer and the latest version in `memgit-versions`.
Return t if differences are found, nil otherwise."
          (interactive)
          (let ((file-path (buffer-file-name)))
            (if file-path
                (let* ((absolute-file-path (expand-file-name file-path))
                       (current-version (memgit-get-version absolute-file-path))
                       (latest-file (when current-version
                                      (expand-file-name
                                       (concat (file-relative-name (file-name-directory absolute-file-path) "/")
                                               (number-to-string current-version))
                                       memgit-cache-dir))))
                  (if (and current-version (file-exists-p latest-file))
                      (if (not (string= (with-temp-buffer
                                          (insert-file-contents latest-file)
                                          (buffer-string))
                                        (buffer-string)))
                          (progn
                            (message "Differences found between buffer and latest version.")
                            t)
                        (progn
                          (message "No differences found between buffer and latest version.")
                          nil))
                    (progn
                      (message "No latest version found for: %s" absolute-file-path)
                      t)))
              (progn
                (message "Current buffer is not visiting a file.")
                nil))))

        (defun memgit-clear-all-versions ()
          "Clear all versions in the `memgit-cache-dir` for the current file."
          (interactive)
          (let ((file-path (buffer-file-name)))
            (if file-path
                (let* ((absolute-file-path (expand-file-name file-path))
                       (relative-path (file-relative-name absolute-file-path "/"))
                       (version-dir (expand-file-name (file-name-directory relative-path) memgit-cache-dir)))
                  (if (file-directory-p version-dir)
                      (progn
                        (delete-directory version-dir t)
                        (remhash absolute-file-path memgit-versions)
                        (memgit-save-versions)
                        (message "Cleared all versions for: %s" absolute-file-path))
                    (message "No versions found for: %s" absolute-file-path)))
              (message "Current buffer is not visiting a file.")))))

    ;; Disable mode: Remove functions
    (progn
      (fmakunbound 'memgit-replace-with-previous-version)
      (fmakunbound 'memgit-check-differences)
      (fmakunbound 'memgit-clear-all-versions)
      (fmakunbound 'memgit-replace-with-next-version)
      (fmakunbound 'memgit-copy-current-buffer-file-to-numbered-file)
      (message "memgit-mode disabled."))))

(provide 'memgit)
