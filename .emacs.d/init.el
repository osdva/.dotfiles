;;; init.el --- init.el loads full configuration -*- lexical-binding: t; -*-

;; Add lisp/ to load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Bootstrap pkg manager
(require 'm-pkg)

;; Personal info
(defconst m-full-name "Arthur Diniz")
(defconst m-email-addresses '("arthurvdinizs@gmail.com"))
(defconst m-email (car m-email-addresses))
(defconst m-dotfiles-directory "~/.dotfiles/")

(use-package emacs
  :ensure nil
  :demand t

  :custom
  (user-full-name m-full-name)
  (user-mail-address m-email)
  (display-line-numbers-type 'relative)

  ;; General behavior (startup settings in early-init.el)
  (ring-bell-function 'ignore)
  (use-short-answers t)
  (use-dialog-box nil)
  (confirm-kill-emacs 'y-or-n-p)

  ;; Files and backups
  (make-backup-files nil)
  (auto-save-default nil)
  (create-lockfiles nil)
  (require-final-newline t)

  :hook
  (prog-mode . display-line-numbers-mode)

  :config
  ;; Fonts
  (set-face-attribute 'default nil :family "CommitMono Nerd Font")

  ;; UTF-8 everywhere
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)

  :init
  ) 

;; Custom file (keep init.el clean)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file 'noerror 'nomessage))

(require 'm-editor)
(require 'm-fmt)
(require 'm-modeline)
(require 'm-theme)
(require 'm-treesitter)
(require 'm-modes)
(require 'm-completion)
(require 'm-file-manager)
(require 'm-evil)
(require 'm-evil-keybindings)

(provide 'init)

;;; init.el ends here
