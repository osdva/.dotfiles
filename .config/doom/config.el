;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "CommitMono Nerd Font" :size 16 :weight 'medium)
      doom-variable-pitch-font (font-spec :family "CommitMono Nerd Font" :size 18))

(setq doom-theme 'base16-theme)
(load-theme 'base16-kanagawa-dragon t)

(setq display-line-numbers-type 'relative)

(setq org-directory "~/org/")
