;;; m-completion.el --- completion configuration -*- lexical-binding: t -*-

;; Enable Vertico.
(use-package vertico
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 10) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :hook
  (elpaca-after-init . (lambda () (vertico-mode 1)))
  :config
  (require 'vertico-directory)
  (keymap-set vertico-map "RET" #'vertico-directory-enter)
  (keymap-set vertico-map "DEL" #'vertico-directory-delete-char)
  (keymap-set vertico-map "M-DEL" #'vertico-directory-delete-word)
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

;; In-buffer popup completions.
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-preview-current nil)
  :hook
  (elpaca-after-init . (lambda () (global-corfu-mode 1))))

(use-package cape
  :init
  ;; Keep normal capfs first, then add text/file completion helpers.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :demand t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles orderless partial-completion))
                                        (project-file (styles orderless))
                                        (buffer (styles orderless)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :hook
  (elpaca-after-init . (lambda () (marginalia-mode 1))))

(use-package consult
  :ensure t
  :custom
  (consult-fd-args "fd --color=never --full-path --hidden --exclude .git ARG"))

(provide 'm-completion)

;;; m-completion.el ends here
