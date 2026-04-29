;;; m-modeline.el --- modeline configuration -*- lexical-binding: t; -*-

(use-package nerd-icons
  :ensure t
  :defer t
  :custom
  (nerd-icons-scale-factor 1.35))

(use-package doom-modeline
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . doom-modeline-mode)
  :custom
  (doom-modeline-buffer-file-name-style 'file-name-with-project)
  (doom-modeline-project-detection 'project)
  (doom-modeline-buffer-name t)
  (doom-modeline-vcs-max-length 20)
  (doom-modeline-height 42)
  (doom-modeline-bar-width 4)
  (doom-modeline-window-width-limit nil)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-major-mode-color-icon t)
  (doom-modeline-buffer-state-icon t)
  (doom-modeline-buffer-modification-icon t)
  (doom-modeline-modal t)
  (doom-modeline-modal-icon t)
  (doom-modeline-modal-modern-icon t)
  (doom-modeline-check 'simple)
  (doom-modeline-minor-modes nil)
  (doom-modeline-time nil)
  :config
  (doom-modeline-def-modeline 'm-main
    '(bar window-number modals matches buffer-info buffer-position)
    '(misc-info buffer-encoding major-mode vcs check))
  (doom-modeline-set-modeline 'm-main t)

  (setq doom-modeline-spc-face-overrides
        (list :family (face-attribute 'fixed-pitch :family)))

  (set-face-attribute 'mode-line nil :box nil)
  (set-face-attribute 'mode-line-inactive nil :box nil)
  (when (facep 'mode-line-active)
    (set-face-attribute 'mode-line-active nil :box nil)))

(provide 'm-modeline)

;;; m-modeline.el ends here
