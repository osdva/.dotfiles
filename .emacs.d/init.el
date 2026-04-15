;;; init.el --- init.el loads full configuration -*- lexical-binding: t; -*-

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'm-pkg)

; (use-package emacs
;   :custom
;   (context-menu-mode t)
;   (enable-recursive-minibuffers t)
;   (read-extended-command-predicate #'command-completion-default-include-p)
;   (minibuffer-prompt-properties
;    '(read-only t cursor-intangible t face minibuffer-prompt)))

(elpaca-wait)
(require 'm-editor)
(require 'm-theme)
(require 'm-treesitter)
(require 'm-modes)
(require 'm-completion)

(provide 'init)

;;; init.el ends here
