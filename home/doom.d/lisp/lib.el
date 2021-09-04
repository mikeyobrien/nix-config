;;; ../Code/dotfiles/.doom.d/lib.el -*- lexical-binding: t; -*-
(require 'request)

(setq ynab-base-url "")

(defun bb-repl ()
  (interactive)
  (async-start-process "bb --nrepl-server 1677"))

(defun hmov/open-fish-config ()
  (interactive)
  (find-file "~/.config/fish/config.fish"))

(defun hmov/dummy-request ()
  (interactive)
  (request "https://api.youneedabudget.com/v1/budgets"
    :params '(("key" . "value") ("key2" . "value2"))
    :parser 'json-read
    :sync t
    :headers `(("Authorization" . ,(concat "Bearer " ynab-token)))
    :complete (cl-function
               (lambda (&key response &allow-other-keys)
                 (message "Done: %s" (request-response-data response))))))

(defun yabai-restart ()
  (interactive)
  (async-shell-command "brew services restart yabai"))



(provide 'lib)
