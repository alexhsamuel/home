;; =========================================================-*- lisp -*-
;;
;; .emacs : configuration for the One True Program
;;
;; =====================================================================

;; Who are we?
(setq user-name (user-real-login-name))
(setq home-directory (getenv "HOME"))


;; ===================
;; Local configuration
;; ===================

;; Elisp search path.
(set-variable 'load-path
              (append (list "/usr/local/share/emacs/site-lisp"
                            (concat user-emacs-directory "lisp")
                            )
                      load-path))

(let ((local-config-file (concat home-directory "/.emacs.local")))
  (if (file-exists-p local-config-file)
      (load local-config-file)))


;; ======
;; Custom
;; ======

; Stop fucking up my init.el.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)


;; ===============
;; Package manager
;; ===============

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)


(eval-when-compile
  (require 'use-package))


;; ============
;; Backup files
;; ============

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)


;; ===========
;; Miscellanea
;; ===========

(setq-default inhibit-startup-screen t)
(tool-bar-mode -1)

(global-set-key [(control z)] 'undo)
(global-unset-key [(control x)(control z)])

;; Undo instead.
(global-set-key '[(control z)] 'undo)

;; Use the form of my name that I prefer.
(setq-default user-full-name "Alex Samuel")

;; Fill text to 80 columns.
(setq-default fill-column 80)

;; Wrap lines.
(setq-default truncate-lines t)

;; Show whitespace
(setq-default show-trailing-whitespace t)
(global-set-key '[(control ?c) (?w) (?w)] 'whitespace-mode)
(global-set-key '[(control ?c) (?w) (?o)] 'whitespace-toggle-options)

;; Enable auto-revert (reload).
(global-auto-revert-mode t)

(defun ahs-revert-buffer ()
  (interactive)
  (revert-buffer t t))

(global-set-key '[(control ?x) (?j)] 'ahs-revert-buffer)

;; Fontify buffers up to 1MB.
(set-variable 'font-lock-maximum-size (* 1024 1024))

;; Don't GC too often.
(setq gc-cons-threshold 1000000)

;; Turn off annoying end-of-buffer newline query.
(setq require-final-newline nil)

;; Stop beeping at me.
(setq ring-bell-function 'ignore)

;; Use the more explicit uniquifying method.
(toggle-uniquify-buffer-names)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; Colorize wherever possible.
(global-font-lock-mode t)

;; I hate electric indent.
(electric-indent-mode -1)
(add-hook 'after-change-major-mode-hook (lambda() (electric-indent-mode -1)))

(defun set-default-coding ()
  (interactive)
  (set-buffer-file-coding-system default-buffer-file-coding-system))

(defun unfill-region (beg end)
  "Unfill the region, joining text paragraphs into a single logical line."
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))

(define-key global-map "\C-\M-Q" 'unfill-region)

; Don't ask about following a symlink to a VC file.
(setq-default vc-follow-symlinks t)


;; Functions to draw lines.

(defun ahs-finish-line (character)
  (while (< (current-column) (current-fill-column))
    (insert character)))

(defun ahs-finish-minus-line ()
  (interactive)
  (ahs-finish-line "-"))

(defun ahs-finish-equals-line ()
  (interactive)
  (ahs-finish-line "="))

(global-set-key '[(control ?c) (control ?-)] 'ahs-finish-minus-line)
(global-set-key '[(control ?c) (control ?=)] 'ahs-finish-equals-line)

(defun ahs-indent-to-4 ()
  "Move the point to the next column that is a multiple of 4."
  (interactive)
  (indent-to (let ((col (current-column))) (+ col (- 4 (% col 4))))))

(global-set-key '[(meta ?i)] 'ahs-indent-to-4)

(defun insert-xos (count)
  (interactive "nCount: ")
  (while (> count 0)
    (insert (if (= (random 2) 1) "x" "o"))
    (if (>= (current-column) (current-fill-column))
        (insert "\n"))
    (setq count (1- count))))

;; C-x 8 r inserts RIGHTWARDS ARROW.
(global-set-key (kbd "C-x 8 r") (lambda () (interactive) (insert "→")))

;; Shortcuts for vowels with umlaut.
(global-set-key (kbd "C-' a") (lambda () (interactive (insert "ä"))))
(global-set-key (kbd "C-' o") (lambda () (interactive (insert "ö"))))
(global-set-key (kbd "C-' u") (lambda () (interactive (insert "ü"))))
(global-set-key (kbd "C-' A") (lambda () (interactive (insert "Ä"))))
(global-set-key (kbd "C-' O") (lambda () (interactive (insert "Ö"))))
(global-set-key (kbd "C-' U") (lambda () (interactive (insert "Ü"))))
(global-set-key (kbd "C-' s") (lambda () (interactive (insert "ß"))))
(global-set-key (kbd "C-' \"")(lambda () (interactive (insert "„"))))


;; ====================
;; C-mode customization
;; ====================

(setq-default indent-tabs-mode nil)

(defvar ahs-c-arg-column 32
  "The column at which function arguments should begin.")

(defun ahs-move-to-arg-column ()
  "Move the point to the column given by ahs-c-arg-column."
  (interactive)
  (indent-to ahs-c-arg-column))

(c-add-style
 "ahs"   ;; style name
 '("user"  ;; base style
   (arglist-intro . +)
   (arglist-close . 0)
   (inline-open . 0)
   (member-init-intro . -)
   (member-init-cont . +)
   (statement-cont . +)
   (c-offsets-alist . ((innamespace . [0])))))

(setq-default c-default-style "ahs")

(setq-default c-basic-offset 2)
(defun ahs-c-mode-common-hook ()
  (define-key c++-mode-map "\C-c\C-f" 'compile)
  (set-variable 'c-basic-offset 2)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'innamespace 0))
(add-hook 'c-mode-common-hook 'ahs-c-mode-common-hook)

(defun ahs-c-mode-hook ()
  (define-key c-mode-map "\C-c\C-f" 'compile))
(add-hook 'c-mode-hook 'ahs-c-mode-hook)
(defun ahs-c++-mode-hook ()
  (define-key c++-mode-map "\C-cl" 'ahs-move-to-arg-column)
  (define-key c++-mode-map "\C-c\C-r" 'shell-command))
(add-hook 'c++-mode-hook 'ahs-c++-mode-hook)

(defun my-java-mode-hook ()
  (setq tab-width 4)
  (c-set-offset 'substatement-open 0))
(add-hook 'java-mode-hook 'my-java-mode-hook)

;; add to the list of file extensions recognized for major-modes
(setq auto-mode-alist (append auto-mode-alist '(("\\.F\\'" . fortran-mode))))
(setq auto-mode-alist (append auto-mode-alist '(("\\.inc\\'" . fortran-mode))))
(setq auto-mode-alist (append auto-mode-alist '(("\..icc\\'" . c++-mode))))
(setq auto-mode-alist (append auto-mode-alist '(("\\.mjs\\'" . js-mode))))


;; ==============
;; Global key map
;; ==============

(global-set-key '[(meta ?o)] 'overwrite-mode)
(global-set-key '[(control ?.)] 'shell)
(global-set-key '[(control backspace)] 'backward-kill-word)
(global-set-key '[(control delete)] 'backward-kill-word)
(global-set-key '[(control ?c) ?f] 'font-lock-fontify-buffer)
(global-set-key '[(control ?c) ?F] 'font-lock-mode)
(global-set-key '[(meta ?n)] 'forward-paragraph)
(global-set-key '[(meta ?p)] 'backward-paragraph)
(global-set-key '[(control tab)] 'other-window)
(global-set-key '[(control ?c) (control ?a)] 'auto-fill-mode)
(global-set-key '[(control ?x) (control ?g)] 'goto-line)
(global-set-key '[(control ?x) ?t] 'sort-lines)
(global-set-key '[(meta ?s)] 'center-line)
(global-set-key '[(meta control ? )] 'iso-transl-no-break-space)
(global-set-key '[(control ?$)] 'toggle-truncate-lines)
(global-set-key '[(control ?x) (meta ?t)] 'auto-revert-tail-mode)

;; The mouse wheelie.
(defun mouse-wheel-up () (interactive) (scroll-down))
(defun mouse-wheel-down () (interactive) (scroll-up))
(defun mouse-wheel-up-slow () (interactive) (scroll-down 1))
(defun mouse-wheel-down-slow () (interactive) (scroll-up 1))
(global-set-key '[mouse-4] 'mouse-wheel-up)
(global-set-key '[mouse-5] 'mouse-wheel-down)
(global-set-key '[(shift mouse-4)] 'mouse-wheel-up-slow)
(global-set-key '[(shift mouse-5)] 'mouse-wheel-down-slow)

(global-set-key '[(meta up  )] 'mouse-wheel-up-slow)
(global-set-key '[(meta down)] 'mouse-wheel-down-slow)

;; Scroll without moving point.
(defun interactive-scroll-up   (count) (interactive "p") (scroll-up   count))
(defun interactive-scroll-down (count) (interactive "p") (scroll-down count))


;; Display line and column in the status line.
(setq line-number-mode t)
(setq column-number-mode t)

;; Turn on some stuff.
(put 'eval-expression 'disabled nil)
(put 'upcase-region 'disabled nil)


;; ======
;; Colors
;; ======

;; M-x list-colors-display to show available colors.

(setq ahs-bg "#f8f8f8")
(setq ahs-fg "#222")
(setq ahs-fg-dim "#666")

(set-face-background 'default ahs-bg)
(set-face-foreground 'default ahs-fg)
(set-face-background 'region "#d0d2d2")
(set-face-background 'highlight "rgb:70/30/90")
(set-face-foreground 'link "#57b")
(set-face-background 'cursor "#9bc0b0")

; Mode line.
(set-face-attribute
 'mode-line nil
 :foreground "#eee"
 :background "#777"
 :box '(:line-width 1 :color "#888" :style "raised"))
(set-face-attribute
 'mode-line-highlight nil
 :foreground "#eef"
 :background "#777"
 :box '(:line-width 1 :color "#888" :style "raised"))
(set-face-attribute
 'mode-line-inactive nil
 :foreground "#999"
 :background "#666"
 :box '(:line-width 1 :color "#666" :style "raised"))

(set-face-attribute
 'minibuffer-prompt nil
 :foreground "#404040"
 :weight 'bold)

(set-face-foreground 'font-lock-builtin-face "#6b4760")
(set-face-foreground 'font-lock-comment-face "#808888")
(set-face-foreground 'font-lock-constant-face "#247")
(set-face-attribute
 'font-lock-doc-face nil
 :foreground "#808888"
 :weight `bold)
(set-face-foreground 'font-lock-function-name-face "#2d6a6c")
(set-face-foreground 'font-lock-keyword-face "#1c3a4f")
(set-face-foreground 'font-lock-preprocessor-face "#6a6")
(set-face-foreground 'font-lock-string-face "#635483")
(set-face-foreground 'font-lock-type-face "#36795e")
(set-face-foreground 'font-lock-variable-name-face "#2d8667")


;; =====
;; dired
;; =====

(use-package dired
  :init
  (setq foo-variable t)
  :config
  ;; Use `ls -oa' to display directory contents.
  (set-variable 'dired-listing-switches "-oa")
)


;; ========
;; SQL mode
;; ========

(setq-default sql-product 'ms)


;; ===============
;; JavaScript mode
;; ===============

(use-package js
  :config
  (setq-default js-indent-level 2)
  (setq auto-mode-alist (cons '("\\.json\\'" . javascript-mode) auto-mode-alist))
)


;; ========
;; Flycheck
;; ========

(use-package flycheck
  :config
  (setq-default flycheck-disabled-checkers '(python-pylint))
  (global-flycheck-mode))


;; ========
;; Flyspell
;; ========

(use-package flyspell
  :config
  (set-face-attribute
   'flyspell-incorrect nil
   :foreground nil
   :background "#401"
   :underline nil)
  (set-face-attribute
   'flyspell-duplicate nil
   :foreground nil
   :background "#280008"
   :underline nil)
)


;; ===========
;; Python mode
;; ===========

;; Load Python mode.
(use-package python
  :config
  ;; Associate it with .py files.
  (setq auto-mode-alist (append auto-mode-alist '(("\\.py\\'" . python-mode))))

  ;; Don't auto-fill in Python mode.
  (add-hook 'python-mode-hook 'turn-off-auto-fill)

  ;; Use python3 to evaluate.
  (setq py-python-command "python3")

  ;; Keymap.
  (define-key python-mode-map "\C-x#" 'comment-region)

  ;; Put triple quotes for docstrings on their own lines.
  (setq python-fill-docstring-style 'django)
)


;; ==========
;; shell mode
;; ==========

(use-package sh-script
  :config
  (set-face-foreground 'sh-quoted-exec "#a04060")
)


;; =========
;; Rust mode
;; =========

(use-package rust-mode
  :config
  (add-hook 'rust-mode-hook 'cargo-minor-mode)
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)

  (add-hook 'python-mode-hook 'flycheck-mode)
  (add-to-list 'flycheck-disabled-checkers 'python-flake8)
  (add-to-list 'flycheck-disabled-checkers 'python-pylint)

  (setq rust-rustfmt-bin (concat home-directory "/.cargo/bin/rustfmt"))
)


;; ========
;; Markdown
;; ========

(use-package markdown-mode
  :config
  (set-face-attribute
   'markdown-code-face nil
   :foreground "#222"
   :background "#ecf4f6")
  (setq markdown-code-lang-modes
   (quote
    (("ocaml" . tuareg-mode)
     ("elisp" . emacs-lisp-mode)
     ("ditaa" . artist-mode)
     ("asymptote" . asy-mode)
     ("dot" . fundamental-mode)
     ("sqlite" . sql-mode)
     ("calc" . fundamental-mode)
     ("C" . c-mode)
     ("cpp" . c++-mode)
     ("C++" . c++-mode)
     ("screen" . shell-script-mode)
     ("shell" . sh-mode)
     ("bash" . sh-mode)
     ("py" . python-mode))))
  (setq markdown-fontify-code-blocks-natively t)
  (setq markdown-gfm-additional-languages (quote ("py")))
  (add-hook 'markdown-mode-hook 'turn-on-auto-fill)
)


;; ====
;; Diff
;; ====

(use-package diff-mode
  :config
  (set-face-attribute
   'diff-indicator-removed nil
   :weight `bold
   :foreground "#a00"
   :background "#f8f8f8")
  (set-face-attribute
   'diff-removed nil
   :foreground "#222"
   :background "#fff0f0")
  (set-face-attribute
   'diff-refine-removed nil
   :foreground "#222"
   :background "#f0d0d0")
  (set-face-attribute
   'diff-indicator-added nil
   :weight `bold
   :foreground "#0a4"
   :background "#f8f8f8")
  (set-face-attribute
   'diff-added nil
   :foreground "#222"
   :background "#f0fff0")
  (set-face-attribute
   'diff-refine-added nil
   :foreground "#222"
   :background "#d0f0d0")
)


;; ====
;; helm
;; ====

(use-package helm
  :defer nil
  :config

  ;; I'd like some helm functions, but I don't want it injected everywhere.  Uninject it.
  ;; Maybe there's a better way to do this.
  (helm-mode 1)
  (remove-function completing-read-function #'helm--completing-read-default)
  (remove-function read-file-name-function #'helm--generic-read-file-name)
  (remove-function read-buffer-function #'helm--generic-read-buffer)
  (remove-function completion-in-region-function #'helm--completion-in-region)

  ;; Don't go overboard with helm stuff.  It's pretty annoyingly different from find-file.
  (define-key helm-map (kbd "TAB") #'helm-execute-persistent-action)
  (define-key helm-map (kbd "<tab>") #'helm-execute-persistent-action)
  (define-key helm-map (kbd "C-z") #'helm-select-action)
  ;; (global-set-key (kbd "M-x")                           'undefined)
  (global-set-key (kbd "M-x")                           'helm-M-x)
  ;; (global-set-key (kbd "M-y")                           'helm-show-kill-ring)
  (global-set-key (kbd "C-M-y")                         'helm-show-kill-ring)
  (global-set-key (kbd "C-x C-z")                       'helm-find-files)
  ;; (global-set-key (kbd "C-c <SPC>")                     'helm-all-mark-rings)
  ;; (global-set-key [remap bookmark-jump]                 'helm-filtered-bookmarks)
  ;; (global-set-key (kbd "C-:")                           'helm-eval-expression-with-eldoc)
  ;; (global-set-key (kbd "C-,")                           'helm-calcul-expression)
  ;; (global-set-key (kbd "C-h d")                         'helm-info-at-point)
  (global-set-key (kbd "C-h i")                         'helm-info)
  (global-set-key (kbd "C-x C-a")                       'helm-browse-project)
  ;; (global-set-key (kbd "<f1>")                          'helm-resume)
  ;; (global-set-key (kbd "C-h C-f")                       'helm-apropos)
  (global-set-key (kbd "C-h a")                         'helm-apropos)
  ;; (global-set-key (kbd "C-h C-d")                       'helm-debug-open-last-log)
  ;; (global-set-key (kbd "<f5> s")                        'helm-find)
  ;; (global-set-key (kbd "S-<f3>")                        'helm-execute-kmacro)
  ;; (global-set-key (kbd "C-c i")                         'helm-imenu-in-all-buffers)
  ;; (global-set-key (kbd "C-c C-i")                       'helm-imenu)
  ;; (global-set-key (kbd "<f11>")                         nil)
  ;; (global-set-key (kbd "<f11> o")                       'helm-org-agenda-files-headings)
  ;; (global-set-key (kbd "M-s")                           nil)
  ;; (global-set-key (kbd "M-s")                           'helm-occur-visible-buffers)
  ;; FIXME: Shadows center-line, above.
  (global-set-key (kbd "M-s")                           'helm-occur)
  ;; (global-set-key (kbd "<f6> h")                        'helm-emms)
  (define-key global-map [remap jump-to-register]       'helm-register)
  ;; (define-key global-map [remap list-buffers]           'helm-mini)
  (define-key global-map [remap dabbrev-expand]         'helm-dabbrev)
  (define-key global-map [remap find-tag]               'helm-etags-select)
  (define-key global-map [remap xref-find-definitions]  'helm-etags-select)
  ;; (define-key global-map (kbd "M-g a")                  'helm-do-grep-ag)
  ;; (define-key global-map (kbd "M-g g")                  'helm-grep-do-git-grep)
  ;; (define-key global-map (kbd "M-g i")                  'helm-gid)
  ;; (define-key global-map (kbd "C-x r p")                'helm-projects-history)
  ;; (define-key global-map (kbd "C-x r c")                'helm-addressbook-bookmarks)
  ;; (define-key global-map (kbd "C-c t r")                'helm-dictionary)

  (set-face-attribute 'helm-buffer-directory nil :foreground ahs-fg :background ahs-bg)
  (set-face-attribute 'helm-buffer-file nil :foreground ahs-fg :background ahs-bg)
  (set-face-attribute 'helm-buffer-modified nil :foreground ahs-fg :background "#f8f0f0")
  (set-face-attribute 'helm-buffer-process nil :foreground ahs-fg-dim :background ahs-bg)
  (set-face-attribute 'helm-candidate-number nil :foreground "#bfe" :background "#777")
  (set-face-attribute 'helm-ff-directory nil :foreground ahs-fg :background ahs-bg :weight 'bold)
  (set-face-attribute 'helm-ff-dotted-directory nil :foreground ahs-fg-dim :background ahs-bg :weight 'bold)
  (set-face-attribute 'helm-ff-dotted-symlink-directory nil :foreground ahs-fg-dim :background ahs-bg :weight 'bold)
  (set-face-attribute 'helm-ff-executable nil :foreground ahs-fg)
  (set-face-attribute 'helm-ff-file nil :foreground ahs-fg)
  (set-face-attribute 'helm-ff-file-extension nil :foreground ahs-fg :weight 'normal)
  (set-face-attribute 'helm-ff-symlink nil :foreground ahs-fg)
  (set-face-attribute 'helm-ff-truename nil :foreground ahs-fg)
  (set-face-attribute 'helm-match nil :foreground 'unspecified :underline t)
  (set-face-attribute 'helm-selection nil :background "#d0e8e0" :weight 'unspecified)
  (set-face-attribute 'helm-source-header nil :family "Monospace" :height 1.0 :background "#aaa" :foreground "white")
)


;; ====================
;; find-file-in-project
;; ====================

(use-package find-file-in-project
  :defer nil
  :config
  (global-set-key (kbd "C-x C-d") 'find-file-in-project))


;; ====
;; mu4e
;; ====

; mu4e is installed with mu, by apt/dpkg.
(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")

(use-package mu4e
  :defer t
  :init
  (autoload 'mu4e "mu4e" nil t)  ; Not 100% sure this is right.
  :config
  (setq
   mue4e-headers-skip-duplicates  t
   mu4e-view-show-images t
   mu4e-view-show-addresses t
   mu4e-compose-format-flowed nil
   mu4e-date-format "%Y-%m-%d"
   mu4e-headers-date-format "%Y-%m-%d"
   mu4e-change-filenames-when-moving t

   mu4e-attachments-dir "~/dl"

   mu4e-maildir "~/mail/fastmail"
   mu4e-refile-folder "/Archive"
   mu4e-sent-folder "/Sent"
   mu4e-drafts-folder "/Drafts"
   mu4e-trash-folder "/Trash"

   mu4e-get-mail-command "/usr/bin/mbsync --pull --all"
   ))


;; ====================
;; Host-specific config
;; ====================

; MacOS
(when (string-equal system-type "darwin")
  (setq ispell-program-name "/usr/local/bin/ispell"))


