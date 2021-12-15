;; -*- no-byte-compile: t; -*-
;;; .doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:host github :repo "username/repo"))
;; (package! builtin-package :disable t)

; https://github.com/hlissner/doom-emacs/issues/5721
(unpin! org-mode)

(package! groovy-mode)
(package! lsp-python-ms)
(package! python-black)
(package! esup)
(package! theme-magic)
(package! anki-editor)
(package! ein)
(package! flycheck-clj-kondo)
(package! magit-delta)
(package! tree-sitter)
(package! tree-sitter-langs)

(package! screenshot :recipe (:local-repo "lisp/screenshot"))

;; org-roam
(package! org-roam-ui :recipe (:host github :repo "org-roam/org-roam-ui" :files ("*.el" "out")) :pin "c745d07018a46b1a20b9f571d999ecf7a092c2e1")
(package! websocket :pin "fda4455333309545c0787a79d73c19ddbeb57980") ; dependency of `org-roam-ui'
