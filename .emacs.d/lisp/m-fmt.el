;;; m-fmt.el --- formatter configuration -*- lexical-binding: t; -*-

 (use-package apheleia
  :ensure t
  :hook
  (elpaca-after-init . apheleia-global-mode)
  :config
  (setf (alist-get 'json-mode apheleia-mode-alist) '(jq))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) '(jq))
  (setf (alist-get 'emacs-lisp-mode apheleia-mode-alist) '(lisp-indent)))

(provide 'm-fmt)

;;; m-fmt.el ends here
