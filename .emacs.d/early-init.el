;;; early-init.el --- early init -*- lexical-binding: t; -*-

;; Performance
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 4 1024 1024))
(setq native-comp-jit-compilation nil)

;; Disable file handlers for a faster startup
(defvar m/startup-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Reset GC threshold after startup to prevent long pauses
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist m/startup-file-name-handler-alist
                  native-comp-jit-compilation t
                  gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.1)))

;; Prevent package.el from auto-initializing (using Elpaca instead)
(setq package-enable-at-startup nil)

;; Disable expensive GUI elements early
(setq default-directory "~/"
      inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil
      initial-major-mode 'fundamental-mode)

;; Disable GUI elements before they load
(setq default-frame-alist
      (append '((menu-bar-lines . 0)
                (tool-bar-lines . 0)
                (vertical-scroll-bars)
                (horizontal-scroll-bars)
                (internal-border-width . 0)) 
              default-frame-alist))

;; Prevent frame resize during startup
(setq frame-inhibit-implied-resize t)

;; Rendering optimizations
(setq-default bidi-display-reordering nil
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
(setq redisplay-skip-fontification-on-input t)
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

(provide 'early-init)

;;; early-init.el ends here
