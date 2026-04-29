;;; m-editor.el --- editor configuration -*- lexical-binding: t; -*-

(use-package which-key
  :ensure nil  
  :defer t        
  :hook
  (elpaca-after-init . which-key-mode))

(use-package indent-guide
  :ensure t
  :defer t
  :hook
  (prog-mode . indent-guide-mode)
  :config
  (setq indent-guide-char "│")) 

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook
  (prog-mode . rainbow-delimiters-mode))

(provide 'm-editor)

;;; m-editor.el ends here
