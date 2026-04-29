;;; m-evil-keybindings.el --- evil keybindings -*- lexical-binding: t; -*-

(use-package general
  :ensure t
  :demand t
  :after evil
  :config
  (general-evil-setup)

  (general-define-key
   :states '(normal visual)
   "-" '(dired-jump :which-key "dired"))

  (general-define-key
   :states '(normal visual)
   :prefix "SPC"
   :keymaps 'override
   "" nil
   "p" '(:ignore t :which-key "project")
   "p f" '(projectile-find-file :which-key "find file")
   "p p" '(projectile-switch-project :which-key "switch project")
   "p b" '(projectile-switch-to-buffer :which-key "switch buffer")
   "p d" '(projectile-find-dir :which-key "find dir")
   "p k" '(projectile-kill-buffers :which-key "kill buffers")))

(provide 'm-evil-keybindings)

;;; m-evil-keybindings.el ends here