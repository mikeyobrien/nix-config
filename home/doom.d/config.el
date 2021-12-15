;;; .doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here
(load! "lisp/lib")
(load! "lisp/ui")
(load! "lisp/aws")

;; https://github.com/hlissner/doom-emacs/issues/5785
(general-auto-unbind-keys :off)
(remove-hook 'doom-after-init-modules-hook #'general-auto-unbind-keys)

(setq user-full-name "mobrien"
      user-mail-address "hmobrienv@gmail.com")

(setq magit-repository-directories '(("~/Code" . 1)))
(setq git-commit-summary-max-length 150)

(add-to-list 'Info-directory-list "~/info")
(setq which-key-idle-delay 0.5)
(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "◂\\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . "◃\\1"))
   ))

(defun hmov/ssh-add-github ()
  (interactive)
  (shell-command "eval `ssh-agent`; ssh-add ~/.ssh/github_rsa''"))

(setq undo-limit 80000000
      evil-want-fine-undo t
      auto-save-default t
      truncate-string-ellipsis "…")

(display-time-mode 1)
(global-subword-mode 1)

(setq evil-vsplit-window-right t
      evil-split-window-below t)
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (projectile-find-file))
(setq +ivy-buffer-preview t)

(defun save-all ()
  (interactive)
  (save-some-buffers t))
;; (add-hook 'doom-switch-buffer-hook 'save-all)
;; (add-hook 'doom-switch-window-hook 'save-all)

(global-auto-revert-mode 1)
(setq auth-sources (delete 'macos-keychain-generic auth-sources)
      auth-sources (delete 'macos-keychain-internet auth-sources))
(setq byte-compile-warnings '(cl-functions))

(if (equal (system-name) "mobrien-mbp19.local")
    (progn
      (setq work-laptop t)
      (setq user-mail-address "mobrien@vectra.ai")
      (setq magit-repository-directories '(("~/vectra/" . 1)))
      (load! "lisp/vectra"))
  (setq work-laptop nil))

;; wsl
(setq-default sysTypeSpecific  system-type) ;; get the system-type value

(cond
 ;; If type is "gnu/linux", override to "wsl/linux" if it's WSL.
 ((eq sysTypeSpecific 'gnu/linux)
  (when (string-match "Linux.*Microsoft.*Linux"
                      (shell-command-to-string "uname -a"))

    (setq-default sysTypeSpecific "wsl/linux") ;; for later use.
    (setq
     cmdExeBin"/mnt/c/Windows/System32/cmd.exe"
     cmdExeArgs '("/c" "start" "") )
    (setq
     browse-url-generic-program  cmdExeBin
     browse-url-generic-args     cmdExeArgs
     browse-url-browser-function 'browse-url-generic)
    )))

(unless window-system
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

(after! lsp-python-ms
  (setq lsp-python-ms-executable (executable-find "python-language-server"))
  (set-lsp-priority! 'mspyls 1))

(after! org
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (defvar hmov/org-agenda-bulk-process-key ?f
    "Default key for bulk processing inbox items.")
  (defun org-file-path (filename)
    (concat (file-name-as-directory org-directory) filename))
  (setq org-id-track-globally t
        org-directory "~/org"
        org-babel-clojure-backend 'cider
        org-inbox-file        (org-file-path "inbox.org")
        org-index-file        (org-file-path "gtd.org")
        org-notes-refile      (org-file-path "notes-refile.org")
        org-work-journal-file (org-file-path "work-journal.org")
        org-ellipsis " ▼ "
        org-superstar-headline-bullets-list '("●" "○")
        org-plantuml-jar-path "/usr/local/bin/plantuml"
        org-links-file        (org-file-path "links.org")
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                            (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))

  (setq org-archive-location
        (concat (org-file-path "/archive/archive") "::* From %s"))

  (defun hmov/is-project-p ()
    "Any task with a todo keyword subtask"
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task has-subtask))))

  (defun hmov/find-project-task ()
    "Move point to the parent (project) task if any"
    (save-restriction
      (widen)
      (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
        (while (org-up-heading-safe)
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (goto-char parent-task))))

  (defun hmov/is-project-subtree-p ()
    "Any task with a todo keyword that is in a project subtree.
     Callers of this function already widen the buffer view."
    (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                                (point))))
      (save-excursion
        (hmov/find-project-task)
        (if (equal (point) task)
            nil
          t))))

  (defun hmov/is-task-p ()
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task (not has-subtask)))))

  (defun hmov/skip-non-stuck-projects ()
    "Skip trees that are not stuck projects"
    (save-restriction
      (widen)
      (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
        (if (hmov/is-project-p)
            (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                   (has-next ))
              (save-excursion
                (forward-line 1)
                (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                  (unless (member "WAITING" (org-get-tags-at))
                    (setq has-next t))))
              (if has-next
                  next-headline
                nil))
          next-headline))))

  (defun hmov/skip-non-projects ()
    "Skip trees that are not projects"
    (if (save-excursion (hmov/skip-non-stuck-projects))
        (save-restriction
          (widen)
          (let ((subtree-end (save-excursion (org-end-of-subtree t))))
            (cond
             ((hmov/is-project-p)
              nil)
             ((and (hmov/is-project-subtree-p) (not (hmov/is-task-p)))
              nil)
             (t
              subtree-end))))
      (save-excursion (org-end-of-subtree t))))


  (defun hmov/org-inbox-capture ()
    (interactive)
    "Capture a task in agenda mode."
    (org-capture nil "i"))

  (defun hmov/bulk-process-entries ()
    (if (not (null org-agenda-bulk-marked-entries))
        (let ((entries (reverse org-agenda-bulk-marked-entries))
              (processed 0)
              (skipped 0))
          (dolist (e entries)
            (let ((pos (text-property-any (point-min) (point-max) 'org-hd-marker e)))
              (if (not pos)
                  (progn (message "Skipping removed entry at %s" e)
                         (cl-incf skipped))
                (goto-char pos)
                (let (org-loop-over-headlines-in-active-region) (funcall 'hmov/org-agenda-process-inbox-item))
                ;; `post-command-hook; is not run yet. We make sure any
                ;; pending log note is processed.
                (when (or (memq 'org-add-log-note (default-value 'post-command-hook))
                          (memq 'org-add-log-note post-command-hook))
                  (org-add-log-note))
                (cl-incf processed))))
          (org-agenda-redo)
          (unless org-agenda-persistent-marks (org-agenda-bulk-unmark-all))
          (message "Acted on %d entries %s%s"
                   processed
                   (if (= skipped 0)
                       ""
                     (format ", skipped %d (disappeared before their turn)"
                             skipped))
                   (if (not org-agenda-persistant-marks) "" " (kept marked)")))))


  (defun hmov/org-agenda-process-inbox-item ()
    "Process a single item in the org-agenda."
    (org-with-wide-buffer
     (org-agenda-set-tags)
     (org-agenda-priority)
     (org-agenda-refile nil nil t)))

  (defun hmov/org-process-inbox ()
    "called in org-agenda-mode, processes all inbox items"
    (interactive)
    (org-agenda-bulk-mark-regexp ":REFILE:")
    (hmov/bulk-process-entries))

  (setq org-capture-templates
        `(("i" "Inbox" entry (file org-inbox-file)
           ,(concat "* TODO %?\n"
                    "/Entered on/ %u"))))

  (setq org-tag-alist '(("@work" . ?w)
                        ("@home" . ?h)
                        ("@errand" . ?e)
                        ("@computer" . ?C)
                        ("@phone" . ?p)))

  (setq org-stuck-projects (quote ("" nil nil "")))

  (setq
   org-agenda-span 'day
   org-agenda-prefix-format '((agenda . " %i %-12:c%?-12t% s")
                              (todo   . " ")
                              (tags   . " %i %-12:c")
                              (search . " %i %-12:c"))
   org-agenda-start-day "+0d"
   org-agenda-start-with-log-mode t
   org-agenda-dim-blocked-tasks t
   org-agenda-compact-blocks t
   org-agenda-bulk-custom-functions `((?P hmov/org-agenda-process-inbox-item))
   org-agenda-custom-commands
   '((" " "GTD"
      ((agenda "" ((org-agenda-start-with-log-mode '(closed clock state))))
       (tags "REFILE"
             ((org-agenda-overriding-header "Tasks to Refile")
              (org-tags-match-list-sublevels nil)))
       (tags-todo "-CANCELLED-SOMEDAY/!"
                  ((org-agenda-overriding-header "Stuck Projects")
                   (org-agenda-skip-function 'hmov/skip-non-stuck-projects)))
       (tags-todo "-CANCELLED-SOMEDAY/!"
                  ((org-agenda-overriding-header "Projects")
                   (org-agenda-skip-function 'hmov/skip-non-projects)
                   (org-tags-match-list-sublevels 'indented)
                   (org-agenda-sorting-strategy
                    '(category-keep))))
       (tags-todo "-CANCELLED-SOMEDAY/!NEXT"
                  ((org-agenda-overriding-header "Next Tasks")
                   (org-agenda-skip-function 'hmov/skip-projects-and-single-tasks)
                   (org-tags-match-list-sublevels t)
                   (org-agenda-sorting-strategy
                    '(todo-state-down effort-up category-keep))))
       (tags-todo "-REFILE-SOMEDAY-PROJECT/-NEXT"
                  ((org-agenda-overriding-header "Standalone Tasks")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))))
     ("p" "Agenda"
      ((agenda ""
               ((org-agenda-span 'day)
                (org-agenda-start-with-log-mode '(closed clock state))
                (org-deadline-warning-days 365)
                (org-agenda-log-mode)))
       (tags-todo "+REFILE-LEVEL=2"
                  ((org-agenda-overriding-header "To Refile")))
       (todo "NEXT"
             ((org-agenda-overriding-header "Next Tasks")))
       (tags-todo "PROJECT-REFILE-NEXT"
                  ((org-agenda-overriding-header "Project Tasks")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("NEXT")))))
       (tags-todo "-REFILE-PROJECT-SOMEDAY"
                  ((org-agenda-overriding-header "One-off Tasks")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))))
     ("w" "Work Agenda"
      ((agenda ""
               ((org-agenda-span 7)
                (org-agenda-tag-filter-preset '("+@work"))))
       (tags-todo "+@work+REFILE-LEVEL=2"
                  ((org-agenda-overriding-header "To Refile")))
       (tags-todo "+@work-NEXT"
                  ((org-agenda-overriding-header "Next")))))))

  (with-eval-after-load 'ob-clojure
    (defcustom org-babel-clojure-backend nil
      "Backend used to evaluate clojure code blocks"
      :group 'org-babel
      :type '(choice
              (const :tag "inf-clojure" inf-clojure)
              (const :tag "cider" cider)
              (const :tag "slime" slime)
              (const :tag "bb" bb)
              (const :tag "Not configured yet" nil)))
    (defun elisp->clj (in)
      (cond
       ((listp in) (concat "[" (s-join " " (mapcar #'elisp->clj in)) "]"))
       (t (format "%s" in))))

    (defun ob-clojure-eval-with-bb (expanded params)
      "Evaluate EXPANDED code blockwith PARAMS using babashka."
      (unless (executable-find "bb")
        (user-error "Babashka not installed"))
      (let* ((stdin (let ((stdin (cdr (assq :stdin params))))
                      (when stdin
                        (elisp-clj
                         (org-babel-ref-resolve stdin)))))
             (input (cdr (assq :input params)))
             (file (make-temp-file "ob-clojure-bb" nil nil expanded))
             (command (concat (when stdin (format "echo %s | " (shell-quote-argument stdin)))
                              (format "bb %s -f %s"
                                      (cond
                                       ((equal input "edn") "")
                                       ((equal input "text") "-i")
                                       (t ""))
                                      (shell-quote-argument file))))
             (result (shell-command-to-string command)))
        (s-trim result)))
    (defun org-babel-execute:clojure (body params)
      "Execute a block of Clojure code with babel."
      (unless org-babel-clojure-backend
        (user-error "You need to customize org-babel-clojure-backend"))
      (let* ((expanded (org-babel-expand-body:clojure body params))
             (result-params (cdr (assq :result-params params)))
             result)
        (setq result
              (cond
               ((eq org-babel-clojure-backend 'inf-clojure)
                (ob-clojure-eval-with-inf-clojure expanded params))
               ((eq org-babel-clojure-backend 'cider)
                (ob-clojure-eval-with-cider expanded params))
               ((eq org-babel-clojure-backend 'slime)
                (ob-clojure-eval-with-slime expanded params))
               ((eq org-babel-clojure-backend 'bb)
                (ob-clojure-eval-with-bb expanded params))))
        (org-babel-result-cond result-params
          result
          (condition-case nil (org-babel-script-escape result)
            (error result)))))
    (customize-set-variable 'org-babel-clojure-backend 'bb))

  (add-transient-hook! #'org-babel-execute-src-block
    (require 'ob-async))

  (defvar org-babel-auto-async-languages '()
    "Babel languages which should be executed asyncronously by default.")

  (defadvice! org-babel-get-src-block-info-eager-async-a (orig-fn &optional light datum)
    "Eagarly add an :async parameter to the src information, unless it seems problematic.
     This only acts o languages in `org-babel-auto-async-languages'.
     Not added when either:
     + session is not \"none\"
     + :sync is set"
    :around #'org-babel-get-src-block-info
    (let ((result (funcall orig-fn light datum)))
      (when (and (string= "none" (cdr (assoc :session (caddr result))))
                 (member (car result) org-babel-auto-async-languages)
                 (not (assoc :async (caddr result))) ; don't duplicate
                 (not (assoc :sync (caddr result))))
        (push '(:async) (caddr result)))
      result))

  (add-hook 'focus-out-hook 'save-all))


(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "~/kaalaman"))
  (org-roam-dailies-directory (file-truename "~/kaalaman/journals/"))
  (org-roam-capture-templates
    '(("d" "default" plain "%?"
       :target (file+head "pages/${slug}.org"
                          "#+title: ${title}\n")
       :unnarrowed t))))


(use-package! magit-delta
  :config
  (add-hook 'magit-mode-hook (lambda () (magit-delta-mode +1))))

(setq lsp-terraform-server `(,"terraform-ls", "serve"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#f0f0f0" "#e45649" "#50a14f" "#986801" "#4078f2" "#a626a4" "#0184bc" "#383a42"])
 '(custom-safe-themes
   (quote
    ("632694fd8a835e85bcc8b7bb5c1df1a0164689bc6009864faed38a9142b97057" "99ea831ca79a916f1bd789de366b639d09811501e8c092c85b2cb7d697777f93" default)))
 '(fci-rule-color "#383a42")
 '(jdee-db-active-breakpoint-face-colors (cons "#f0f0f0" "#4078f2"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#f0f0f0" "#50a14f"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#f0f0f0" "#9ca0a4"))
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (1 ((shift) . 5) ((control)))))
 '(objed-cursor-color "#e45649")
 '(pdf-view-midnight-colors (cons "#383a42" "#fafafa"))
 '(rustic-ansi-faces
   ["#fafafa" "#e45649" "#50a14f" "#986801" "#4078f2" "#a626a4" "#0184bc" "#383a42"])
 '(vc-annotate-background "#fafafa")
 '(vc-annotate-color-map
   (list
    (cons 20 "#50a14f")
    (cons 40 "#688e35")
    (cons 60 "#807b1b")
    (cons 80 "#986801")
    (cons 100 "#ae7118")
    (cons 120 "#c37b30")
    (cons 140 "#da8548")
    (cons 160 "#c86566")
    (cons 180 "#b74585")
    (cons 200 "#a626a4")
    (cons 220 "#ba3685")
    (cons 240 "#cf4667")
    (cons 260 "#e45649")
    (cons 280 "#d2685f")
    (cons 300 "#c07b76")
    (cons 320 "#ae8d8d")
    (cons 340 "#383a42")
    (cons 360 "#383a42")))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:family "Iosevka" :height 0.9))))
 '(mode-line-inactive ((t (:family "Iosevka" :height 0.9)))))
