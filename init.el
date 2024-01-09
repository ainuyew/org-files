;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive
(setq comp-async-report-warnings-errors nil)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
;; (unless package-archive-contents
;;   (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
;;(unless (or (package-installed-p 'use-package)
;;            dw/is-guix-system)
;;   (package-install 'use-package))
(require 'use-package)

;; Uncomment this to get a reading on packages that get loaded at startup
;;(setq use-package-verbose t)

;; On non-Guix systems, "ensure" packages by default
;;(setq use-package-always-ensure (not dw/is-guix-system))

(set-default-coding-systems 'utf-8)

;; ESC cancels all
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; clean up emacs' user interface

;; source: https://stackoverflow.com/questions/11670654/how-to-resize-images-in-org-mode
(setq org-image-actual-width (list 550))

;; Thanks, but no thanks
(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)       ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

;; improve scrolling
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time
(setq use-dialog-box nil) ;; Disable dialog boxes since they weren't working in Mac OSX

;; frame transperency and maximize windows by default
;;(set-frame-parameter (selected-frame) 'alpha '(90 . 90))
;;(add-to-list 'default-frame-alist '(alpha . (90 . 90)))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; enable line numbers and customize their format.
(column-number-mode)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; auto saving changed files
(use-package super-save
  :defer 1
  :diminish super-save-mode
  :config
  (super-save-mode +1)
  (setq super-save-auto-save-when-idle t))

;; use spaces instead of tabs for indentation
(setq-default indent-tabs-mode nil)

;; automatically clean whitespace
(use-package ws-butler
  :hook ((text-mode . ws-butler-mode)
         (prog-mode . ws-butler-mode)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(global-visual-line-mode t)
 '(menu-bar-mode nil)
 '(org-src-fontify-natively t)
 '(org-src-preserve-indentation t)
 '(package-selected-packages
   '(org-noter pdf-tools which-key citar-org-roam orderless vertico org-ref jupyter ws-butler rust-mode org-babel-eval-in-repl yasnippet-snippets yasnippet org-roam-ui org-download org-roam markdown-mode))
 '(safe-local-variable-values
   '((eval setq org-download-image-dir
           (concat "./"
                   (file-name-base buffer-file-name)))))
 '(tool-bar-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Monaco" :foundry "nil" :slant normal :weight medium :height 141 :width normal)))))



;; org mode

;; TODO: Mode this to another section
(setq-default fill-column 80)

;; Turn on indentation and auto-fill mode for Org files
(defun dw/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil)
  (diminish org-indent-mode)
  t)

;; Make sure Straight pulls Org from Guix
;;(when dw/is-guix-system
;;  (straight-use-package '(org :type built-in)))


(use-package org
  :defer t
  ;;:hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-fontify-quote-and-verse-blocks t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 2
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-startup-folded 'content
        org-cycle-separator-lines 2)

  (setq org-refile-targets '((nil :maxlevel . 1)
                             (org-agenda-files :maxlevel . 1)))

  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-use-outline-path t)


  (push '("conf-unix" . conf-unix) org-src-lang-modes)

  (setq org-confirm-babel-evaluate nil)
  ;;(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
  ;;(setq org-image-actual-width (list 300))
  

  ;; Make sure org-indent face is available
  (require 'org-indent)


  (add-to-list 'load-path "/Library/Frameworks/Python.framework/Versions/3.11/bin/jupyter")
  (require 'jupyter)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (latex . t)
     (R . t)
     (python . t)
     (jupyter . t)))

)

;; org-download
(use-package org-download
  :ensure t
  :after org
  :defer nil
  :custom
  (org-download-method 'directory)
  ;;(org-download-image-dir "~/Documents/org/figures")
  (org-download-heading-lvl nil)
  (org-download-timestamp "%Y%m%d-%H%M%S_")
  (org-download-screenshot-method "/usr/local/bin/pngpaste %s")
  :bind
  ("C-M-y" . org-download-screenshot)
  :config
  (require 'org-download)
  ;; Add handlers for drag-and-drop when Org is loaded.
  (with-eval-after-load 'org
    (org-download-enable)))
  
;; Org-Roam basic configuration
(setq org-directory (concat (getenv "HOME") "/Documents/org/roam"))

(use-package org-roam
  :ensure t
  :after org
  :init (setq org-roam-v2-ack t) ;; Acknowledge V2 upgrade
  :custom
  
  (org-roam-directory (file-truename org-directory))
  (org-roam-completion-everywhere t)
  ;;(org-roam-db-update-on-save t)
  :config
  (org-roam-setup)
  (org-roam-db-autosync-mode)
  :bind (("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
         ("C-c n l" . org-roam-buffer-toggle)
         :map org-mode-map
	 ("C-M-i" . completion-at-point)))


:custom
;; source: https://github.com/emacs-citar/citar
(use-package citar
  :custom
  (citar-bibliography '("~/Documents/org/bibliography/zotero.bib")))

;; source: https://github.com/emacs-citar/citar-org-roam
(use-package citar-org-roam
  :after (citar org-roam)
  :config
  (setq citar-org-roam-note-title-template "${author} - ${title}")
  (setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :target
         (file+head
          "%<%Y%m%d%H%M%S>-${slug}.org"
          "#+title: ${note-title}\n")
         :unnarrowed t)
        ("n" "literature note" plain
         "%?"
         :target
         (file+head
          "%(expand-file-name (or citar-org-roam-subdir \"\") org-roam-directory)/${citar-citekey}.org"
          "#+title: ${citar-citekey} (${citar-date}). ${note-title}.\n#+created: %U\n#+last_modified: %U\n\n")
         :unnarrowed t)))
  (citar-org-roam-mode))

;; source: https://orgmode.org/manual/Citations.html
(setq org-cite-global-bibliography '("~/Documents/org/bibliography/zotero.bib"))

;; yasnippets
(use-package yasnippet
  :ensure t
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (yas-reload-all)
  (yas-global-mode t))

(use-package yasnippet-snippets
  :ensure t)

;; python
;;(setq org-babel-python-command "python3")
;;(setq python-shell-completion-native-enable nil)
;;(setq python-shell-completion-native-disabled-interpreters '("python3"))

;; source: https://github.com/minad/vertico
;; Enable vertico
(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

;; source: https://github.com/minad/vertico
;; Optionally use the `orderless' completion style.
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; source: https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html
(setq org-agenda-files '("~/Documents/org/inbox.org"
                         "~/Documents/org/gtd.org"
                         "~/Documents/org/tickler.org"))

;; Configure the Modus Themes' appearance
(setq modus-themes-mode-line '(accented borderless)
      modus-themes-bold-constructs t
      modus-themes-italic-constructs t
      modus-themes-fringes 'subtle
      modus-themes-tabs-accented t
      modus-themes-paren-match '(bold intense)
      modus-themes-prompts '(bold intense)
      modus-themes-completions
      '((matches . (extrabold underline))
        (selection . (semibold italic)))
      modus-themes-org-blocks 'tinted-background
      modus-themes-scale-headings t
      modus-themes-region '(bg-only)
      modus-themes-headings
      '((1 . (rainbow overline background 1.4))
        (2 . (rainbow background 1.3))
        (3 . (rainbow bold 1.2))
        (t . (semilight 1.1))))

;; Load the light theme by default
(load-theme 'modus-vivendi t)

;; https://systemcrafters.net/emacs-from-scratch/helpful-ui-improvements/
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

;; source: https://github.com/jkitchin/org-ref/issues/428
(require 'org-id)

;; source: https://github.com/vedang/pdf-tools
(pdf-loader-install)

;; source: https://www.reddit.com/r/orgmode/comments/165zeuu/delighted_by_org_svg_preview/
;; source: https://karthinks.com/software/scaling-latex-previews-in-emacs/
(setq org-preview-latex-default-process 'dvisvgm) ;No blur when scaling
(plist-put org-format-latex-options :foreground nil)
(plist-put org-format-latex-options :background nil)
(defun my/text-scale-adjust-latex-previews ()
  "Adjust the size of latex preview fragments when changing the
buffer's text scale."
  (pcase major-mode
    ('latex-mode
     (dolist (ov (overlays-in (point-min) (point-max)))
       (if (eq (overlay-get ov 'category)
               'preview-overlay)
           (my/text-scale--resize-fragment ov))))
    ('org-mode
     (dolist (ov (overlays-in (point-min) (point-max)))
       (if (eq (overlay-get ov 'org-overlay-type)
               'org-latex-overlay)
           (my/text-scale--resize-fragment ov))))))

(defun my/text-scale--resize-fragment (ov)
  (overlay-put
   ov 'display
   (cons 'image
         (plist-put
          (cdr (overlay-get ov 'display))
          :scale (+ 1.0 (* 0.25 text-scale-mode-amount))))))

(add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews)

;; source: https://emacs.stackexchange.com/questions/43700/export-org-mode-code-blocks-with-minted-style
(setq org-latex-listings 'minted
    org-latex-packages-alist '(("newfloat" "minted"))
    org-latex-pdf-process
    '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
      "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

(add-to-list 'load-path (concat user-emacs-directory "lisp/" ))

(load "ox-ipynb") ;; best not to include the ending “.el” or “.elc”

(setq org-default-notes-file "~/Documents/org/inbox.org")
