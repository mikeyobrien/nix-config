;;; .doom.d/config.el -*- lexical-binding: t; -*-
;; Place your private configuration here
(load! "lisp/lib")
(load! "lisp/ui")
(load! "lisp/aws")

;; Experimental Settings
(setq global-flycheck-mode t)
(setq evil-snipe-scope 'buffer)
;; Experimental End

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

(evil-set-initial-state 'awstk-s3-bucket-mode 'normal)

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
;(setq require-final-newline nil)


;; elfeed
(after! elfeed
  (setq elfeed-db-directory "~/Sync/.elfeed/db/")
  (map! :map elfeed-search-mode-map
        :desc "clear search" "c" #'elfeed-search-clear-filter)
  (setq elfeed-search-filter "@1-week-ago +unread"
        elfeed-search-title-min-width 80)

  (add-hook! 'elfeed-show-mode-hook (hide-mode-line-mode 1))
  (add-hook! 'elfeed-search-update-hook #'hide-mode-line-mode)

  (defface elfeed-show-title-face '((t (:weight ultrabold :slant italic :height 1.5)))
    "title face in elfeed show buffer"
    :group 'elfeed)
  (defface elfeed-show-author-face `((t (:weight light)))
    "title face in elfeed show buffer"
    :group 'elfeed)
  (if (eq nil work-laptop)
      (setq elfeed-feeds (append elfeed-feeds
                                 '(("https://jenkins.vectra.io/view/SaaS%20Platform/job/terraform_apply_saas-platform/rssAll" vectra)
                                   ("https://jenkins.vectra.io/view/SaaS%20Platform/job/verify.data_analytics.multi/job/master/rssAll" vectra))))))


;; wakatime
;; (use-package! wakatime-mode
;;   :init
;;   (setq wakatime-api-key "6e37fd13-897a-4616-96ea-5aa389d2098d")
;;   (setq wakatime-cli-path "wakatime")
;;  (global-wakatime-mode))

(map! :leader
      (:desc "open elfeed" "o e" #'=rss)
      (:desc "open eterm"  "o t" #'+vterm/toggle))

;; smerge
(defun smerge-repeatedly ()
  "Perform smerge actions again and again"
  (interactive)
  (smerge-mode 1)
  (smerge-transient))
(after! transient
  (transient-define-prefix smerge-transient ()
    [["Move"
      ("n" "next" (lambda () (interactive) (ignore-errors (smerge-next)) (smerge-repeatedly)))
      ("p" "previous" (lambda () (interactive) (ignore-errors (smerge-prev)) (smerge-repeatedly)))]
     ["Keep"
      ("b" "base" (lambda () (interactive) (ignore-errors (smerge-keep-base)) (smerge-repeatedly)))
      ("u" "upper" (lambda () (interactive) (ignore-errors (smerge-keep-upper)) (smerge-repeatedly)))
      ("l" "lower" (lambda () (interactive) (ignore-errors (smerge-keep-lower)) (smerge-repeatedly)))
      ("a" "all" (lambda () (interactive) (ignore-errors (smerge-keep-all)) (smerge-repeatedly)))
      ("RET" "current" (lambda () (interactive) (ignore-errors (smerge-keep-current)) (smerge-repeatedly)))]
     ["Diff"
      ("<" "upper/base" (lambda () (interactive) (ignore-errors (smerge-diff-base-upper)) (smerge-repeatedly)))
      ("=" "upper/lower" (lambda () (interactive) (ignore-errors (smerge-diff-upper-lower)) (smerge-repeatedly)))
      (">" "base/lower" (lambda () (interactive) (ignore-errors (smerge-diff-base-lower)) (smerge-repeatedly)))
      ("R" "refine" (lambda () (interactive) (ignore-errors (smerge-refine)) (smerge-repeatedly)))
      ("E" "ediff" (lambda () (interactive) (ignore-errors (smerge-ediff)) (smerge-repeatedly)))]
     ["Other"
      ("c" "combine" (lambda () (interactive) (ignore-errors (smerge-combine-with-next)) (smerge-repeatedly)))
      ("r" "resolve" (lambda () (interactive) (ignore-errors (smerge-resolve)) (smerge-repeatedly)))
      ("k" "kill current" (lambda () (interactive) (ignore-errors (smerge-kill-current)) (smerge-repeatedly)))
      ("q" "quit" (lambda () (interactive) (smerge-auto-leave)))]]))

;; shell stuff
(defalias 'v 'eshell-exec-visual)

;; json
(add-hook 'json-mode-hook
          (lambda ()
            ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

;; GOLANG
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; ivy
(setq ivy-read-action-function #'ivy-hydra-read-action)

;; lsp
(setq lsp-lens-enable nil
      lsp-ui-doc-delay 0.5
      lsp-pyls-plugins-pylint-enabled t
      lsp-flycheck-live-reporting t)

(after! lsp-ui
  (add-hook! 'lsp-ui-mode-hook
    (run-hooks (intern (format "%s-lsp-ui-hook" major-mode)))))

(after! lsp-mode
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("/usr/local/bin/terraform-ls" "serve"))
                    :major-modes '(terraform-mode)
                    :server-id 'terraform-ls)))

(add-hook 'terraform-mode-hook #'lsp)

;; treemacs
(after! treemacs
  (setq treemacs-width 53)
                                        ;(lsp-treemacs-sync-mode 1)
  (treemacs-resize-icons 44))

;; flycheck
(setq-default flycheck-disabled-checkers '(json-jsonlint))

;; (defun mobrien-go-flycheck-setup ()
;;   "Setup Flycheck checkers for Golang"
;;  (flycheck-add-next-checker 'lsp-ui 'golangci-lint))

;; babashka
(defun bb-main ()
  "Run coins main"
  (interactive)
  (projectile-with-default-dir (projectile-project-root)
    (shell-command "bb -m coins.main")))

;; Python
(use-package! python-black
  :init
  (map! :localleader
        :map python-mode-map
        :desc "Deploy package" "d" #'deploy-package
        :desc "Blacken buffer" "b" #'python-black-buffer))

(after! ob-jupyter
  (dolist (lang '(python julia R))
    (cl-pushnew (cons (format "jupyter-%s" lang) lang)
                org-src-lang-modes :key #'car)))

(setq lsp-pyls-plugins-pylint-enabled t)
;;(add-to-list 'flycheck-checkcers 'lsp-ui 'python-pylint))
;; (setq flycheck-python-pylint-executable "~/.pyenv/shims/pylint")
;; (setq flycheck-python-pycompile-executable "~/.pyenv/shims/python3")
;; (with-eval-after-load 'flycheck

;;  (flycheck-add-mode 'proselint 'org-mode))
;;
(after! company
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 2)
  (setq company-show-numbers t)
  (add-hook 'evil-normal-state-entry-hook #'company-abort))

;; tramps
(setq tramp-default-method "ssh")

;; writeroom
;;(setq writeroom-width 150)

;; evil mode
(setq evil-want-fine-undo t)

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


(setq org-roam-directory (file-truename "~/org/braindump")
        org-roam-db-location (file-truename "~/org/org-roam.db")
        org-roam-graph-viewer (lambda (file)
                                (call-process "open" nil t nil "-a" "safari" file))
        org-roam-graph-extra-config '(("concentrate" . "true"))
        org-roam-graph-exclude-matcher '("daily" "private")
        +org-roam-open-buffer-on-find-file nil)


;; (after! org-roam
;;   :commands (org-roam-insert org-roam-find-file org-roam org-roam-switch-to-buffer)
;;   :hook
;;   (after-init . org-roam-mode)
;;   :init
;;     (map! :leader
;;         :prefix "n"
;;         :desc "org-roam-insert" "i" #'org-roam-insert
;;         :desc "org-roam-find"   "/" #'org-roam-find-file
;;         :desc "org-roam-dailies-capture-today" "j" #'org-roam-dailies-capture-today
;;         :desc "org-roam-dailies-today" "t" #'org-roam-dailies-today
;;         :desc "org-roam-find-file" "f" #'org-roam-find-file
;;         :desc "org-roam-capture" "c" #'org-roam-capture)
;;   ;;       :desc "org-roam-buffer" "r" #'org-roam
;;   ;;       :desc "org-roam-capture" "c" #'org-roam-capture)
;;   :config
;;   (require 'org-roam-protocol)
;;   (org-roam-mode +1)
;;   (setq org-roam-capture-templates
;;         '(("d" "default" plain (function org-roam--capture-get-point)
;;            "%?"
;;            :file-name "${slug}"
;;            :head "#+SETUPFILE:./hugo_setup.org
;; #+HUGO_SECTION: zettels
;; #+HUGO_SLUG: ${slug}
;; #+TITLE: ${title}\n"
;;            :unnarrowed t)
;;           ("v" "vectra" plain (function org-roam--capture-get-point)
;;            "%?"
;;            :file-name "${slug}"
;;            :head "#+SETUPFILE:./hugo_setup.org
;; #+HUGO_SECTION: zettels
;; #+HUGO_SLUG: ${slug}
;; #+TITLE: ${title}\n
;; #+ROAM_TAGS: vectra "
;;            :unnarrowed t)
;;           ("p" "private" plain (function org-roam-capture--get-point)
;;            "%?"
;;            :file-name "private-${slug}"
;;            :head "#+TITLE: ${title}\n"
;;            :unnarrowed t)
;;           ("r" "ref" plain (function org-roam-capture--get-point)
;;            "%?"
;;            :file-name "websites/${slug}"
;;            :head "#+SETUPFILE:./hugo_setup.org
;; #+ROAM_KEY: ${ref}
;; #+HUGO_SLUG: ${slug}
;; #+TITLE: ${title}
;; - source :: ${ref}"
;;            :unnarrowed t))))

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :commands org-roam-ui-open
  :hook (org-roam . org-roam-ui-mode)
  :config
  (require 'org-roam) ; in case autoloaded
  (defun org-roam-ui-open ()
    "Ensure the server is active, then open the roam graph."
    (interactive)
    (unless org-roam-ui-mode (org-roam-ui-mode 1))
    (call-process "open" nil t nil "-a" "safari" (format "http://localhost:%d" org-roam-ui-port))))

;; org roam export
(defun my/org-roam--backlinks-list (file)
  (if (org-roam--org-roam-file-p file)
      (--reduce-from
       (concat acc (format "- [[file:%s][%s]]\n"
                           (file-relative-name (car it) org-roam-directory)
                           (org-roam--get-title-or-slug (car it))))
       "" (org-roam-sql [:select [file-from] :from file-links :where (= file-to $s1)] file))
    ""))

(defun my/org-export-preprocessor ()
  (let ((links (my/org-roam--backlinks-list (buffer-file-name))))
    (unless (string= links "")
      (save-excursion
        (goto-char (point-max))
        (insert (concat "\n* Backlinks\n") links)))))

(add-hook 'org-export-before-processing-hook 'my/org-export-preprocessor)

(use-package! smartparens
  :init
  (map! :map smartparens-mode-map
        "C-M-f" #'sp-forward-sexp
        "C-M-b" #'sp-backward-sexp
        "C-M-u" #'sp-backward-up-sexp
        "C-M-d" #'sp-down-sexp
        "C-M-p" #'sp-backward-down-sexp
        "C-M-n" #'sp-up-sexp
        "C-M-s" #'sp-splice-sexp
        "C-)" #'sp-forward-slurp-sexp
        "C-}" #'sp-forward-barf-sexp
        "C-(" #'sp-backward-slurp-sexp
        "C-M-)" #'sp-backward-slurp-sexp
        "C-M-)" #'sp-backward-barf-sexp))


;; hydra settings
(defhydra hydra-smartparens ()
  "Smartparens"
  ("q" nil)
  ;; Wrapping
  ("(" (lambda (_) (interactive "P") (sp-wrap-with-pair "(")))
  ("{" (lambda (_) (interactive "P") (sp-wrap-with-pair "{")))
  ("'" (lambda (_) (interactive "P") (sp-wrap-with-pair "'")))
  ("\"" (lambda (_) (interactive "P") (sp-wrap-with-pair "\"")))
  ("w" (lambda (_) (interactive "P") (sp-wrap-with-pair "(")) "wrap")
  ("W" sp-unwrap-sexp)
  ;; Movement
  ("l" sp-next-sexp)
  ("h" sp-backward-sexp)
  ("j" sp-down-sexp)
  ("k" sp-backward-up-sexp)
  ("L" sp-forward-symbol)
  ("H" sp-backward-symbol)
  ("^" sp-beginning-of-sexp)
  ("$" sp-end-of-sexp)

  ("t" sp-transpose-sexp "transpose")
  ("u" undo-fu-only-undo "undo")

  ("y" sp-copy-sexp "copy")
  ("d" sp-kill-sexp "delete")

  ("s" sp-forward-slurp-sexp "slurp")
  ("S" sp-backward-slurp-sexp)

  ("b" sp-forward-barf-sexp "barf")
  ("B" sp-backward-barf-sexp)

  ("v" sp-select-next-thing "select")
  ("V" sp-select-previous-thing))

;; Call hydra-smartparens/body
(map! :localleader
      :map clojure-mode-map
      :desc "smartparens" "s" #'hydra-smartparens/body)

(use-package! clojure-mode
  :config
  (require 'flycheck-clj-kondo))

;; rust
(setq lsp-rust-server 'rust-analyzer)
(setq lsp-rust-analyzer-server-display-inlay-hints t)


(map! :localleader
      :map emacs-lisp-mode-map
      :desc "smartparens" "s" #'hydra-smartparens/body)

(setq nrepl-force-ssh-for-remote-hosts t)

(use-package! magit-delta
  :config
  (add-hook 'magit-mode-hook (lambda () (magit-delta-mode +1))))

;; org capture frame for alfred
(defun make-orgcapture-frame ()
  "Create a new frame and run org-capture."
  (interactive)
  (make-frame '((name . "remember") (width . 80) (height . 16)
                (top . 400) (left . 300)
                (font . "-apple-Monaco-medium-normal-normal-*-13-*-*-*-m-0-iso10646-1")
                ))
  (select-frame-by-name "remember")
  (org-capture))

;; mu4e
(set-email-account! "gmail.com"
                    '((mu4e-sent-folder       . "/gmail/Sent Mail")
                      (mu4e-drafts-folder     . "/gmail/Drafts")
                      (mu4e-trash-folder      . "/gmail/Trash")
                      (mu4e-refile-folder     . "/gmail/All Mail")
                      (smtpmail-smtp-user     . "hughobrien.v@gmail.com")
                      (user-mail-address      . "hughobrien.v@gmail.com")    ;; only needed for mu < 1.4
                      (mu4e-compose-signature . "---\nHugh OBrien"))
                    t)

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
