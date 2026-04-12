;;; m-theme.el --- theme configuration -*- lexical-binding: t -*-

(use-package ef-themes
    :ensure t
    :init
    (ef-themes-take-over-modus-themes-mode 1)
    :config
    (modus-themes-load-theme 'ef-dream))

(provide 'm-theme)

;;; m-theme.el ends here
