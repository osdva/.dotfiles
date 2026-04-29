;;; m-theme.el --- theme configuration -*- lexical-binding: t -*-

(use-package ef-themes
  :ensure t
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  (load-theme 'ef-dream t))

(provide 'm-theme)

;;; m-theme.el ends here
