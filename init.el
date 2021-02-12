;;; package --- Summary
;;; Commentary:
;;; Code:
(setq user-full-name "Nickolas Lanasa"
      user-mail-address "nytek@mac.com")

;; Defaults
(set-face-attribute 'default nil :font "Monaco 16")
(set-background-color 'nil)

(setq make-backup-files nil)
(setq auto-save-default t)

;; Save a list of recent files visited. (open recent file with C-x f)
(recentf-mode 1)

;; Save minibuffer history
(savehist-mode 1)
(setq history-length 1000)

;; title
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(setq-default cursor-type 'bar)
(set-cursor-color "red")

(defvar bell-volume 0)
(defvar sound-alist nil)

;; save place
(setq-default save-place t)
(setq save-place-file (expand-file-name ".places" user-emacs-directory))

(save-place-mode 1)

;; auto save mode
(auto-save-mode t)
(auto-save-visited-mode t)

;; auto revert mode
(global-auto-revert-mode t)
(setq global-auto-revert-non-file-buffers t
      auto-revert-verbose nil)

;; global highlight line mode
(if window-system (global-hl-line-mode t))
(global-display-line-numbers-mode)

(setq scroll-margin 5 scroll-conservatively 9999 scroll-step 1) ;; Smooth scrolling
(setq initial-scratch-message ";; Hello, Nick")

(prefer-coding-system 'utf-8)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(setq ring-bell-function 'ignore)

(setq visual-line-mode t)

;; startup size
(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 150))

(show-paren-mode t)

;; Javascript
(setq js-indent-level 2)

;; Packages

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-install 'use-package)
(package-refresh-contents)

(use-package yaml-mode :ensure t)

(use-package kubernetes :ensure t)

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package flycheck-ledger :ensure t)

(use-package ledger-mode
  :ensure t
  :bind (:map ledger-mode-map
	      ("C-x C-s" . ny/ledger-save))
  :config
  (setq ledger-binary-path "/usr/local/bin/ledger"))

(use-package company-ledger :ensure t)

(use-package paredit :ensure t)

(use-package hydra
  :ensure t)

(use-package company
  :bind (("C-." . company-complete)
	 :map company-active-map
	 ("C-n" . company-select-next)
	 ("C-p" . company-select-previous)
	 ("C-d" . company-show-doc-buffer)
	 ("<tab>" . company-complete))
  :init
  (global-company-mode 1)
  :config
  (setq company-show-numbers t
	company-tooltip-align-annotations t))

(use-package web-mode :ensure t)

;;;; smex
(use-package smex
  :ensure t
  :config
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex)
  (global-set-key (kbd "M-X") 'smex-major-mode-commands))

(use-package ido-vertical-mode
  :ensure t
  :init
  (require 'ido)
  (ido-mode t)
  (setq ido-enable-prefix nil
        ido-enable-flex-matching t
        ido-case-fold nil
        ido-auto-merge-work-directories-length -1
        ido-create-new-buffer 'always
        ido-use-filename-at-point nil
        ido-max-prospects 10)

  (require 'ido-vertical-mode)
  (ido-vertical-mode)

  (require 'dash)

  (defun my/ido-go-straight-home ()
    (interactive)
    (cond
     ((looking-back "~/") (insert "Developer/"))
     ((looking-back "/") (insert "~/"))
     (:else (call-interactively 'self-insert-command))))

  (defun my/setup-ido ()
    ;; Go straight home
    (define-key ido-file-completion-map (kbd "~") 'my/ido-go-straight-home)
    (define-key ido-file-completion-map (kbd "C-~") 'my/ido-go-straight-home))

  (add-hook 'ido-setup-hook 'my/setup-ido)

  ;; Always rescan buffer for imenu
  (set-default 'imenu-auto-rescan t)

  (add-to-list 'ido-ignore-directories "node_modules"))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(use-package rainbow-delimiters
  :ensure t)

(use-package smartparens
  :ensure t
  :init
  (smartparens-global-mode t)
  (use-package rainbow-delimiters
    :hook (prog-mode . rainbow-delimiters-mode)))

(use-package emojify
  :init (global-emojify-mode))

(use-package magit
  :bind ("C-x g" . magit-status)
  :ensure t
  :config
  (add-hook 'after-save-hook 'magit-after-save-refresh-status))

(use-package projectile
  :bind ("C-c p" . projectile-switch-project)
  :config

  ;; https://github.com/bbatsov/projectile/issues/1183
  (setq projectile-mode-line
        '(:eval (format " Projectile[%s]"
                        (projectile-project-name))))

  (setq projectile-git-submodule-command nil)
  (setq projectile-enable-caching t)
  (setq projectile-completion-system 'ido)
  ;; (setq projectile-completion-system 'ivy)
  (setq projectile-indexing-method 'alien)
  (projectile-mode))

(use-package flycheck
  :init
  (global-flycheck-mode)
  (setq flycheck-indication-mode 'right-fringe))

(use-package org-roam :ensure t
  :config
  (setq org-roam-directory "~/Dropbox/org/slip-box")
  (global-set-key (kbd "C-c r") 'org-roam-find-file)
  (add-hook 'after-init-hook 'org-roam-mode))

(use-package markdown-mode
  :ensure t
  :config
  (setq markdown-command "/usr/local/bin/markdown"))

;; defuns
(defun ny/org-insert-source-block (name language switches header)
  "Asks name, language, switches, header.
Inserts org-mode source code snippet"
  (interactive "sname? 
slanguage? 
sswitches? 
sheader? ")
  (insert 
   (if (string= name "")
       ""
     (concat "#+NAME: " name) )
   (format "
#+BEGIN_SRC %s %s %s :results verbatim
#+END_SRC" language switches header
))
  (forward-line -1)
  (goto-char (line-end-position)))

(defun ny/vsplit-last-buffer ()
  (interactive)
  (split-window-vertically)
  (other-window 1 nil)
  (switch-to-next-buffer))

(defun ny/hsplit-last-buffer ()
  (interactive)
  (split-window-horizontally)
  (other-window 1 nil)
  (switch-to-next-buffer))

(defun ny/efile ()
  (interactive)
  (find-file "~/.emacs.d/.emacs"))

(defun ny/org-files ()
  (interactive)
  (find-file "~/Dropbox/org"))

(defun ny/markdown-convert-buffer-to-org ()
  "Convert the current buffer's content from markdown to orgmode format and save it with the current buffer's file name but with .org extension."
  (interactive)
  (shell-command-on-region (point-min) (point-max)
                           (format "/usr/local/bin/pandoc -f markdown -t org -o %s"
                                   (concat (file-name-sans-extension (buffer-file-name)) ".org"))))

(defun ny/ledger-save ()
  "Automatically clean the ledger buffer at each save."
  (interactive)
  (save-excursion
    (when (buffer-modified-p)
      (with-demoted-errors (ledger-mode-clean-buffer))
      (save-buffer))))

;; aliases

;;;; Ledger aliases
(defalias 'bud (lambda ()
		 "Load budget report for ledger"
		 (interactive)
		 (ledger-report "bud" nil)))
(defalias 'bal (lambda ()
		 "Load balance report for ledger"
		 (interactive)
		 (ledger-report "bal" nil)))
(defalias 'cash (lambda ()
		  "Load cash report for ledger"
		  (interactive)
		  (ledger-report "cash" nil)))
(defalias 'amex (lambda ()
		  "Load cash report for ledger"
		  (interactive)
		  (ledger-report "amex" nil)))

(defalias 'eb 'eval-buffer)
(defalias 'yes-or-no-p 'y-or-n-p)

;; keybindings

;;;; Global
(global-set-key (kbd "C-c f") 'projectile-find-file)
(global-set-key (kbd "C-c k") 'kubernetes-overview)
(global-set-key (kbd "C-c b") 'eval-buffer)
(global-set-key (kbd "C-c d") 'dired)
(global-set-key (kbd "C-c e") 'ny/efile)
(global-set-key (kbd "C-c o") 'ny/org-files)
(global-set-key (kbd "C-c c") 'org-capture)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c i") 'org-insert-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "C-x c") 'eshell)

;;;; Rebindings
(bind-key "C-x 2" 'ny/vsplit-last-buffer)
(bind-key "C-x 3" 'ny/hsplit-last-buffer)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(web-mode projectile emojify markdown-mode org-roam smartparens rainbow-delimiters which-key ido-vertical-mode smex hydra paredit company-ledger ledger-mode flycheck-ledger exec-path-from-shell kubernetes use-package))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
