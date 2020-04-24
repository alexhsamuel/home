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
(set 'package-archives '(
 ("marmalade"       . "http://marmalade-repo.org/packages/")
 ("melpa"           . "http://melpa.milkbox.net/packages/")
 ("melpa-stable"    . "http://stable.melpa.org/packages/")
 ("gnu"             . "http://elpa.gnu.org/packages/")
 ))
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

;; Fuck that C-z shit.  Who thought it was a good idea?
(global-unset-key [(control z)])
(global-unset-key [(control x)(control z)])

;; Use the form of my name that I prefer.
(setq-default user-full-name "Alex Samuel")

;; Fill text to 80 columns.
(setq-default fill-column 80)

;; Wrap lines.
(setq-default truncate-lines t)

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

(set-face-background 'default "black")
(set-face-foreground 'default "#ccc")
(set-face-background 'region "#333")
(set-face-background 'highlight "rgb:70/30/90")
(set-face-foreground 'link "#57b")

; Mode line.
(set-face-attribute
 'mode-line nil
 :foreground "#eee"
 :background "#555"
 :box '(:line-width 1 :color "#555" :style "raised"))
(set-face-attribute 
 'mode-line-highlight nil
 :foreground "red"
 :background "#000"
 :box '(:line-width 1 :color "#f00" :style "raised"))
(set-face-attribute 
 'mode-line-inactive nil
 :foreground "#999"
 :background "#333"
 :box '(:line-width 1 :color "#333" :style "raised"))

(set-face-foreground 'minibuffer-prompt "#fff")

(set-face-foreground 'font-lock-builtin-face "#ccf")
(set-face-foreground 'font-lock-comment-face "#888")
(set-face-foreground 'font-lock-constant-face "#dcc")
(set-face-foreground 'font-lock-doc-face "#b8c8c8")
(set-face-attribute
 'font-lock-doc-face nil
 :foreground "#98a0a0"
 :weight `bold)
(set-face-foreground 'font-lock-function-name-face "#8de")
(set-face-foreground 'font-lock-keyword-face "#a0b8b8")
(set-face-foreground 'font-lock-preprocessor-face "#b8a0b0")
(set-face-foreground 'font-lock-string-face "#988898")
(set-face-foreground 'font-lock-type-face "#bdc")
(set-face-foreground 'font-lock-variable-name-face "#acf")


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

(use-package flycheck)
(use-package flycheck-pyflakes
  :config
  (add-hook 'python-mode-hook 'flycheck-mode)
  (add-to-list 'flycheck-disabled-checkers 'python-flake8)
  (add-to-list 'flycheck-disabled-checkers 'python-pylint)
)


;; ========
;; Flyspell
;; ========

(use-package flyspell
  :config
  (set-face-foreground 'flyspell-incorrect "white")
  (set-face-background 'flyspell-incorrect "rgb:80/40/60")
  (set-face-underline-p 'flyspell-incorrect nil)
  (set-face-foreground 'flyspell-duplicate "white")
  (set-face-background 'flyspell-duplicate "rgb:60/20/40")
  (set-face-underline-p 'flyspell-duplicate nil)
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
  (set-face-font       'markdown-code-face "Inconsolata-13")
  (set-face-background 'markdown-code-face "#223")
  (set-face-foreground 'markdown-code-face "#ccc")
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
)



;; ====
;; Diff
;; ====

(use-package diff-mode
  :config
  (set-face-background 'diff-removed "#400")
  (set-face-background 'diff-added "#031")
)

