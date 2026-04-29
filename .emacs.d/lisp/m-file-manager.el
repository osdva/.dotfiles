;;; m-file-manager.el --- file picker and dired helpers -*- lexical-binding: t; -*-

(use-package
  projectile
  :ensure t
  :demand t
  :hook (elpaca-after-init . projectile-mode)
  :custom
  (projectile-completion-system 'auto)
  (projectile-enable-caching t)
  :init
  (setq projectile-project-search-path '("~/dev/" "~/.dotfiles")))

(provide 'm-file-manager)

;;; m-file-manager.el ends here
