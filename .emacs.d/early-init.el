;;; early-init.el --- early init -*- lexical-binding: t; -*-

;;; Performance
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 4 1024 1024))
(setq native-comp-jit-compilation nil)

;; Prevent package.el from auto-initializing
(setq package-enable-at-startup nil)

;; Disable expensive GUI elements early
(setq inhibit-startup-screen t
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

;; Rendering optimizations
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
(setq redisplay-skip-fontification-on-input t)
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

(provide 'early-init)

;;; early-init.el ends here
