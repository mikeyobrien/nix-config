;; -*- no-byte-compile: t; -*-
;;; .doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)
(package! groovy-mode)
(package! lsp-python-ms)
(package! python-black)
(package! esup)
(package! theme-magic)
(package! anki-editor)
(package! ein)
(package! flycheck-clj-kondo)
(package! magit-delta)
(package! org-jira
  :recipe (:host github :repo "ahungry/org-jira"))
