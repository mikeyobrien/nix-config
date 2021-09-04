;;; ../Code/dotfiles/.doom.d/lisp/aws.el -*- lexical-binding: t; -*-

(require 'transient)

(setq awscli-executable "aws"
      awstk-profile "default"
      awstk-region "us-east-1"
      process-buf "*awstk*")

(defun awstk-clear-buffer ()
  (with-current-buffer (get-buffer-create process-buf)
    (erase-buffer)))

(defun awstk-call-aws (&rest args)
  (awstk-clear-buffer)
  (let ((options (list "--profile" (if (getenv "AWS_PROFILE")
                                       (getenv "AWS_PROFILE")
                                     awstk-profile)
                       "--region" (if (getenv "AWS_REGION")
                                      (getenv "AWS_REGION")
                                    awstk-region)
                       "--output" "json")))
    (apply #'call-process awscli-executable nil process-buf nil (append options args))))

;; TODO EC2
;; TODO Logs

;;; Lambda
(defun awstk-list-lambdas()
  (interactive)
  (awstk-call-aws "lambda" "list-functions" "--query" "Functions[*].{Name:FunctionName,Runtime:Runtime,LastModified:LastModified}")
  (let ((functions (with-current-buffer process-buf
                     (goto-char (point-min))
                     (json-parse-buffer))))
    (with-current-buffer (get-buffer-create "awstk:lambda")
      (setq buffer-read-only nil)
      (erase-buffer)
      (dotimes (i (length functions))
        (let ((f (elt functions i)))
          (insert (format "%-64s%-16s%-64s"
                          (gethash "Name" f)
                          (gethash "Runtime" f)
                          (gethash "LastModified" f))
                  "\n")))
      (display-buffer "awstk:lambda" '(display-buffer-same-window))
      (awstk-lambda-list-mode))))

(defun awstk--format-lambda-logs ()
  (let ((logs (with-current-buffer process-buf
                (goto-char (point-min))
                (json-parse-buffer))))
    (dotimes (i (length logs))
      (let ((l (elt logs i)))
        (insert (format "%-32s%s" (gethash "message" l) (gethash "timestamp" l)) "\n")))))

(defun awstk-lambda-logs ()
  (interactive)
  (let ((function-name (car (split-string (thing-at-point 'line))))) ;; TODO get name only
    (awstk-call-aws "logs" "filter-log-events" "--log-group-name" (format "/aws/lambda/%s" function-name) "--query" "events[*].{message:message,timestamp:timestamp}")
    (with-current-buffer (get-buffer-create "awstk:lambda-logs")
      (setq buffer-read-only nil)
      (erase-buffer)
      (awstk--format-lambda-logs))))

(defvar awstk-lambda-list-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "i") 'awstk-lambda-info)
    (define-key map (kbd "L") 'awstk-lambda-logs)
    (define-key map (kbd "q") 'previous-buffer)
    (define-key map (kbd "j") 'next-line)
    (define-key map (kbd "k") 'previous-line)
    (define-key map [remap evil-previous-line] 'evil-previous-visual-line)
    (define-key map [remap evil-next-line] 'evil-next-visual-line)
    map)
  "Keymap for `awstk-lambda-list-mode'.")

(define-derived-mode awstk-lambda-list-mode special-mode "S3 Lambdas"
  "Major mode for handling a list of buckets."
  (buffer-disable-undo)
  (setq truncate-lines t)
  (setq buffer-read-only t)
  (setq show-trailing-whitespace nil)
  (setq-local symbol-overlay-inhibit-map t)
  (setq-local line-move-visual t))

;;; S3
(defun awstk--update-buckets ()
  (awstk-call-aws "s3api" "list-buckets" "--query" "Buckets[].Name" "--output" "json")
  (let ((buckets (with-current-buffer process-buf
                   (goto-char (point-min))
                   (json-parse-buffer))))
    (with-current-buffer (get-buffer-create "awstk:s3-buckets")
      (setq buffer-read-only nil)
      (erase-buffer)
      (dotimes (i (length buckets))
        (insert (format "%s\n" (elt buckets i)))))
    (display-buffer "awstk:s3-buckets" '(display-buffer-same-window))
    (awstk-s3-bucket-mode)))

(defun awstk-list-buckets (&optional refresh)
  (interactive)
  (if (or refresh (not (get-buffer "awstk:s3-buckets")))
      (awstk--update-buckets)
    (display-buffer "awstk:s3-buckets" '(display-buffer-same-window (with-current-buffer "awstk:s3-buckets" (awstk-s3-bucket-mode))))))

(defun awstk-s3-info ()
  (interactive)
  (let ((bucket-name (string-trim (thing-at-point 'line))))
    (awstk-call-aws "s3api" "list-objects" "--bucket" bucket-name)
    (let ((objects (gethash "Contents" (with-current-buffer process-buf
                                         (goto-char (point-min))
                                         (json-parse-buffer)))))
      (with-current-buffer (get-buffer-create "awstk:s3-objects")
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (propertize (format "bucket: %s" bucket-name)
                            'face '('bold 'italic))
                "\n\n")
        (dotimes (i (length objects))
          (insert (gethash "Key" (elt objects i)) "\n"))
        (switch-to-buffer "awstk:s3-objects")
        (awstk-s3-object-mode)))))

(defvar awstk-s3-bucket-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "i") 'awstk-s3-info)
    (define-key map "r" (lambda () (interactive (awstk-list-buckets t))))  ;; refresh
    (define-key map (kbd "q") 'previous-buffer)
    (define-key map (kbd "j") 'next-line)
    (define-key map (kbd "k") 'previous-line)
    (define-key map [remap evil-previous-line] 'evil-previous-visual-line)
    (define-key map [remap evil-next-line] 'evil-next-visual-line)
    map)
  "Keymap for `awstk-s3-bucket-mode'.")

(define-derived-mode awstk-s3-bucket-mode special-mode "S3 Bucket Mode"
  "Major mode for handling a list of buckets."
  (buffer-disable-undo)
  (setq truncate-lines t)
  (setq buffer-read-only t)
  (setq show-trailing-whitespace nil)
  (setq-local symbol-overlay-inhibit-map t)
  (setq-local line-move-visual t))

(defvar awstk-s3-object-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map awstk-s3-bucket-mode-map)
    (define-key map "g" 'awstk-s3-get-object)
    (define-key map (kbd "q") (lambda () (interactive) (pop-to-buffer-same-window "awstk:s3-buckets")))
    map)
  "Keymap for `awstk-s3-object-mode'.")

(define-derived-mode awstk-s3-object-mode awstk-s3-bucket-mode "S3 Object Mode"
  "Major mode for handling a objects from a bucket.")



;;;###autoload (autoload 'awstk "awstk" nil t)
(transient-define-prefix awstk ()
  "Transient for awstk."
  :man-page "aws"
  ["AWS"
   ("s" "S3" awstk-list-buckets)
   ("l" "Lambda" awstk-list-lambdas)])

(provide 'awstk)
