;;; ../Code/dotfiles/.doom.d/lisp/ui.el -*- lexical-binding: t; -*-

;; Display
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)
(setq display-line-numbers-type t)
(setq-default left-margin-width 3 right-margin-width 3)
(set-window-buffer nil (current-buffer))

(delete-selection-mode 1)
(global-subword-mode 1)
(setq fancy-splash-image (concat doom-private-dir "splash.png"))

;; zen mode
(setq +zen-text-scale 0.8)

;; Modeline
(custom-set-faces!
  '(mode-line :family "Iosevka" :height 0.90)
  '(mode-line-inactive :family "Iosevka" :height 0.90))

;; fonts
(if (equal (system-name) "tower")
    (setq doom-font (font-spec :family "Iosevka" :size 24))
  (setq doom-font (font-spec :family "JetBrains Mono" :size 22)))
(setq doom-serif-font (font-spec :family "JetBrains Mono"))
(setq doom-theme 'doom-gruvbox)
(setq doom-themes-treemacs-theme "doom-colors")
(doom-themes-org-config)

(if (not (equal (system-name) "sculpin"))
        (use-package! tree-sitter
          :config
          (require 'tree-sitter-langs)
          (global-tree-sitter-mode)
          (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)))

(provide 'ui)
