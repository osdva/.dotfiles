;;; m-treesitter.el --- treesitter configuration -*- lexical-binding: t; -*-

(use-package treesit-auto
  :ensure t
  :after emacs
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode t))

(provide 'm-treesitter)

;;; m-treesitter.el ends here
