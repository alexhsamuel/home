;; =========================================================-*- lisp -*-
;;
;; .emacs : configuration for the One True Program
;;
;; =====================================================================

;; Where are we?
(setq host-name (substring (shell-command-to-string "hostname -s") 0 -1))
(setq domain-name (substring (shell-command-to-string "hostname -d") 0 -1))
;; Who are we?
(setq user-name (user-real-login-name))
(setq home-directory (getenv "HOME"))

;; Elisp search path.
(set-variable 'load-path 
	      (append (list "/usr/local/share/emacs/site-lisp"
			    user-emacs-directory
                            )
		      load-path))

;; Info search path.
(load-library "info")

(set-variable 'Info-directory-list 
	      (cons "/usr/local/info" 
		    (if (eq Info-directory-list nil)
			Info-default-directory-list
		      Info-directory-list)))

;; ===========
;; Miscellanea
;; ===========

;; Fuck that C-z shit.  Who thought it was a good idea?
(global-unset-key [(control z)])
(global-unset-key [(control x)(control z)])

;; Use the form of my name that I prefer.
(setq-default user-full-name "Alex Samuel")

;; Fill text to 80 columns.
(setq-default fill-column 80)

;; Wrap lines.
(setq-default truncate-lines t)

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

(global-set-key '[(meta ?o)] 'overwrite-mode)

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

(defun set-default-coding ()
  (interactive)
  (set-buffer-file-coding-system default-buffer-file-coding-system))

;; I hate electric indent.
(electric-indent-mode -1)
(add-hook 'after-change-major-mode-hook (lambda() (electric-indent-mode -1)))


;; ===================
;; LaTeX customization
;; ===================

(set-variable 'tex-dvi-view-command "xdvi")


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


;; =========
;; SGML mode
;; =========

;; PSGML and the usual emacs HTML mode don't get along.  Load PSGML
;; first to make sure it wins.
(and 
 (load "psgml" t)

 (progn
   (defun ahs-sgml-mode-hook ()
     ; Parse the DTD immediately.
     (set-variable 'sgml-auto-activate-dtd t)
     ; Show the current element in the mode line.
     (set-variable 'sgml-live-element-indicator t)
     ; Activate font lock for SGML.
     (set-variable 'sgml-set-face t)
     (set-variable 'sgml-markup-faces
		   '((start-tag . font-lock-keyword-face)
		     (end-tag . font-lock-keyword-face)
		     (comment . font-lock-comment-face)
		     (pi . bold)
		     (sgml . font-lock-variable-name-face)
		     (doctype . font-lock-variable-name-face)
		     (entity . font-lock-constant-face)
		     (shortref . font-lock-type-face))))

   (add-hook 'sgml-mode-hook 'ahs-sgml-mode-hook)))


;; ==============
;; Global key map
;; ==============

(global-set-key '[(control ?.)] 'shell)
(global-set-key '[(control backspace)] 'backward-kill-word)
(global-set-key '[(control delete)] 'backward-kill-word)
(global-set-key '[(control ?c) ?f] 'font-lock-fontify-buffer)
(global-set-key '[(control ?c) ?F] 'font-lock-mode)
(global-set-key '[(meta ?n)] 'forward-paragraph)
(global-set-key '[(meta ?p)] 'backward-paragraph)
(global-set-key '[(control tab)] 'other-window)
(global-set-key '[(control ?c) (control ?o)] 'oo-browser)
(global-set-key '[(control ?c) (control ?a)] 'auto-fill-mode)
(global-set-key '[(control ?x) (control ?g)] 'goto-line)
(global-set-key '[(control ?x) ?t] 'sort-lines)
(global-set-key '[(meta ?s)] 'center-line)
(global-set-key '[(meta control ? )] 'iso-transl-no-break-space)
(global-set-key '[(control ?$)] 'toggle-truncate-lines)

;; The mouse wheelie.
(defun mouse-wheel-up () (interactive) (scroll-down))
(defun mouse-wheel-down () (interactive) (scroll-up))
(defun mouse-wheel-up-slow () (interactive) (scroll-down 1))
(defun mouse-wheel-down-slow () (interactive) (scroll-up 1))
(global-set-key '[mouse-4] 'mouse-wheel-up)
(global-set-key '[mouse-5] 'mouse-wheel-down)
(global-set-key '[(shift mouse-4)] 'mouse-wheel-up-slow)
(global-set-key '[(shift mouse-5)] 'mouse-wheel-down-slow)

;; Display line and column in the status line.
(setq line-number-mode t)
(setq column-number-mode t)

;; Colorize wherever possible.
(global-font-lock-mode t)

;; Turn on some stuff.
(put 'eval-expression 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Some frame configuration.
(setq default-frame-alist '((horizontal-scroll-bar . nil) 
			    (menu-bar-lines . 0)))

;; Turn off the idiot bars.
(tool-bar-mode 0)
(menu-bar-mode -99)

;; =======
;; Display
;; =======

(set-face-foreground 'default "black")

;; Set the default background depending on the user.
(setq background-color-alist '(("samuel" . "white")
			       ("root" . "rgb:ff/f4/f4")))
;; (if (equal (framep (car (frame-list))) 'x)
;;     (let ((background-color 
;; 	   (assoc-default user-name background-color-alist nil "Grey95")))
;;       (set-face-background 'default background-color)
;;       (set-background-color background-color)))
       
;(set-face-background 'modeline "grey50")
;(set-face-foreground 'modeline "white")
(set-face-background 'region "rgb:f0/e0/d0")
(set-face-background 'highlight "rgb:70/30/90")
(set-face-foreground 'font-lock-keyword-face "rgb:50/00/70")
(set-face-foreground 'font-lock-constant-face "rgb:30/00/70")
(set-face-foreground 'font-lock-builtin-face "gray30")
(set-face-foreground 'font-lock-type-face "rgb:00/00/70")
(set-face-foreground 'font-lock-variable-name-face "rgb:00/70/90")
(set-face-foreground 'font-lock-function-name-face "rgb:00/70/90")
(set-face-foreground 'font-lock-string-face "rgb:40/40/80")
(set-face-foreground 'font-lock-comment-face "grey50")
(if (>= emacs-major-version 21)
    (set-face-foreground 'font-lock-doc-face "rgb:c0/c0/c0"))

;; (and
;;  (load "flyspell" t)
;;  (set-face-foreground 'flyspell-incorrect-face "white")
;;  (set-face-background 'flyspell-incorrect-face "rgb:80/40/60")
;;  (set-face-underline-p 'flyspell-incorrect-face nil)
;;  (set-face-foreground 'flyspell-duplicate-face "white")
;;  (set-face-background 'flyspell-duplicate-face "rgb:60/20/40")
;;  (set-face-underline-p 'flyspell-duplicate-face nil))


;; =====
;; dired
;; =====

(require 'dired)

;; Use `ls -oa' to display directory contents.
(set-variable 'dired-listing-switches "-oa")


;; ========
;; ps-print
;; ========

; Don't print page headers.
(setq ps-print-header nil)


;; ===================
;; Local configuration
;; ===================

(set-variable 'ahs-emacs-config-dir (concat home-directory "/ahs/config/"))
(defun ahs-emacs-config-file (key)
  (concat ahs-emacs-config-dir ".emacs." key))

; Load laptop configration.
(if (and (equal user-name "samuel")
	 (equal host-name "parsley"))
    (load (ahs-emacs-config-file "parsley")))
	 
; Load OS/X configuration.
(if (and (equal host-name "peppermint"))
    (load (ahs-emacs-config-file "osx")))

; Load local configuration for the home network.
(if (and (equal user-name "samuel")
	 (equal domain-name "indetermi.net")
	 (not (equal host-name "parsley")))
    (load (ahs-emacs-config-file "home")))

; Load local configuration for HEP machines.
(if (and (equal user-name "samuel")
	 (or (equal domain-name "hep.caltech.edu")
	     (equal domain-name "slac.stanford.edu")))
    (load (ahs-emacs-config-file "hep")))

; Load host-specific local configuration, if present.
(let ((host-config-file (ahs-emacs-config-file host-name)))
  (if (file-exists-p host-config-file)
      (load host-config-file)))

(let ((local-config-file (concat home-directory "/.emacs.local")))
  (if (file-exists-p local-config-file)
      (load local-config-file)))


;; ===========
;; Matlab mode
;; ===========

(and
 (load "matlab" t)
 (progn
   (setq auto-mode-alist (cons '("\\.m\\'" . matlab-mode) auto-mode-alist))

   (setq matlab-indent-function t)
   (setq matlab-shell-command-switches '("-nojvm"))))


;; ========
;; SQL mode
;; ========

(setq-default sql-product 'ms)


;; ===============
;; JavaScript mode
;; ===============

(and
 (load "js" t)
 (progn
   (setq-default js-indent-level 2)
   (setq auto-mode-alist (cons '("\\.json\\'" . javascript-mode) auto-mode-alist))))


;; ===========
;; Octave mode
;; ===========

(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))


;; ===============
;; Package manager
;; ===============

;; Requires emacs24.

(require 'package)
(set 'package-archives '(
 ("marmalade"       . "http://marmalade-repo.org/packages/")
;("melpa"           . "http://melpa.milkbox.net/packages/")
 ("melpa-stable"    . "http://stable.melpa.org/packages/")
 ("gnu"             . "http://elpa.gnu.org/packages/")
 ))
(package-initialize)

;; ==========
;; Scala mode
;; ==========

(unless (package-installed-p 'scala-mode2)
  (package-refresh-contents) (package-install 'scala-mode2))


;; ============
;; Haskell mode
;; ============

(unless (package-installed-p 'haskell-mode)
  (package-refresh-contents) (package-install 'haskell-mode))


;; =======
;; Go mode
;; =======

(require 'go-mode-autoloads)


;; ========
;; Flycheck
;; ========

(require 'flycheck)

(if (not (require 'flycheck-pyflakes nil t))
    (message "no flycheck-pyflakes")
  (add-hook 'python-mode-hook 'flycheck-mode)
  (add-to-list 'flycheck-disabled-checkers 'python-flake8)
  (add-to-list 'flycheck-disabled-checkers 'python-pylint)
  )

;; =========
;; Rust mode
;; =========

;; ===========
;; Python mode
;; ===========

;; Load Python mode.
(and
 (load "python" t)

 ;; Associate it with .py files.
 (setq auto-mode-alist (append auto-mode-alist '(("\\.py\\'" . python-mode))))

 ;; Use auto-fill in Python mode.
 (add-hook 'python-mode-hook 'turn-on-auto-fill)

 ;; Use python3 to evaluate.
 (setq py-python-command "python3")

 ;; Keymap.
 (define-key python-mode-map "\C-x#" 'comment-region)

 ;; Put triple quotes for docstrings on their own lines.
 (setq python-fill-docstring-style 'django)

 )

;; Pyflakes
(require 'flycheck-pyflakes)
(add-hook 'python-mode-hook 'flycheck-mode)
(add-to-list 'flycheck-disabled-checkers 'python-flake8)
(add-to-list 'flycheck-disabled-checkers 'python-pylint)

