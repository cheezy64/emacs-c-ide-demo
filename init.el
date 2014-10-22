;; TODO
;;  EVIL, modularize way to override EVIL map
;;  Write script to automatically add company-clang-arguments or create .dir-locals.el
;;  Figure out how to set up c-headers, clang doesn't seem to have the source
;;   https://tuhdo.github.io/c-ide.html
;;    Using generated database from GNU Global
;;  Disable buffers when opening a file
;;  Projectile -- figure out why it can't go to corresponding h or cpp file
;;   Projectile - also automatically create .projectile file in base folder
;;  FunctionArgs can't find definition
(require 'package)
;;; Code:
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(setq inhibit-startup-message t)

(defalias 'yes-or-no-p 'y-or-n-p)

(defconst demo-packages
  '(anzu
    company
    company-c-headers
    duplicate-thing
    ggtags
    helm
    helm-gtags
    helm-swoop
    function-args
    clean-aindent-mode
    comment-dwim-2
    dtrt-indent
    ws-butler
    iedit
    yasnippet
    smartparens
    sml-mode
    projectile
    volatile-highlights
    undo-tree
    zygospore
    evil
    sr-speedbar
    evil-search-highlight-persist
    solarized-theme
    flycheck
    flycheck-pos-tip
    ))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package demo-packages)
    (unless (package-installed-p package)
      (package-install package))))

(install-packages)

;; this variables must be set before load helm-gtags
;; you can change to any prefix key of your choice
(setq helm-gtags-prefix-key "\C-cg")

(add-to-list 'load-path "~/.emacs.d/custom")

(require 'setup-helm)
(require 'setup-helm-gtags)
;; (require 'setup-ggtags)
(require 'setup-cedet)
(require 'setup-editing)
(require 'setup-custom-keys)

(windmove-default-keybindings)

;; set the theme to solarized
(load-theme 'solarized-dark t)

;; function-args
(require 'function-args)
(fa-config-default)
(define-key c-mode-map  [(tab)] 'moo-complete)
(define-key c++-mode-map  [(tab)] 'moo-complete)
(define-key c-mode-map (kbd "M-o")  'fa-show)
(define-key c++-mode-map (kbd "M-o")  'fa-show)

;; company
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(delete 'company-semantic company-backends)
(define-key c-mode-map  [(control tab)] 'company-complete)
(define-key c++-mode-map  [(control tab)] 'company-complete)
(setq company-idle-delay 0)

;; company-c-headers
(add-to-list 'company-backends 'company-c-headers)

;; hs-minor-mode for folding source code
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;; Available C style:
;; “gnu”: The default style for GNU projects
;; “k&r”: What Kernighan and Ritchie, the authors of C used in their book
;; “bsd”: What BSD developers use, aka “Allman style” after Eric Allman.
;; “whitesmith”: Popularized by the examples that came with Whitesmiths C, an early commercial C compiler.
;; “stroustrup”: What Stroustrup, the author of C++ used in his book
;; “ellemtel”: Popular C++ coding standards as defined by “Programming in C++, Rules and Recommendations,” Erik Nyquist and Mats Henricson, Ellemtel
;; “linux”: What the Linux developers use for kernel development
;; “python”: What Python developers use for extension modules
;; “java”: The default style for java-mode (see below)
;; “user”: When you want to define your own style
(setq
 c-default-style "linux" ;; set style to "linux"
 )

(global-set-key (kbd "RET") 'newline-and-indent)  ; automatically indent when press RET

;; activate whitespace-mode to view all whitespace characters
(global-set-key (kbd "C-c w") 'whitespace-mode)

;; show unncessary whitespace that can mess up your diff
(add-hook 'prog-mode-hook (lambda () (interactive) (setq show-trailing-whitespace 1)))

;; use space to indent by default
(setq-default indent-tabs-mode nil)

;; set appearance of a tab that is represented by 4 spaces
(setq-default tab-width 3)

;; Compilation
(global-set-key (kbd "<f5>") (lambda ()
                               (interactive)
                               (setq-local compilation-read-command nil)
                               (call-interactively 'compile)))

;; setup GDB
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )

;; Package: clean-aindent-mode
(require 'clean-aindent-mode)
(add-hook 'prog-mode-hook 'clean-aindent-mode)

;; Package: dtrt-indent
(require 'dtrt-indent)
(dtrt-indent-mode 1)

;; Package: ws-butler
(require 'ws-butler)
(add-hook 'prog-mode-hook 'ws-butler-mode)

;; Package: yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;; Package: smartparens
(require 'smartparens-config)
(setq sp-base-key-bindings 'paredit)
(setq sp-autoskip-closing-pair 'always)
(setq sp-hybrid-kill-entire-symbol nil)
(sp-use-paredit-bindings)

(show-smartparens-global-mode +1)
(smartparens-global-mode 1)

;; Package: projectile
(require 'projectile)
(projectile-global-mode)
(setq projectile-enable-caching t)

;; Package zygospore
(global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows)

;; Package: sr-speedbar
(require 'sr-speedbar)

;; Package: EVIL
(setq evil-want-C-u-scroll t)
(require 'evil)
(evil-mode 1)
;;  Override "evil-repeat" with gtags
(define-key evil-normal-state-map (kbd "M-.") 'helm-gtags-dwim)
;;  Ensure that j and k will move with the visual line
(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
;;  Scroll smoothly at boundaries
(setq scroll-margin 5
   scroll-conservatively 9999
   scroll-step 1)
;; change mode-line color by evil state
(lexical-let ((default-color (cons (face-background 'mode-line)
                                   (face-foreground 'mode-line))))
   (add-hook 'post-command-hook
      (lambda ()
         (let ((color (cond ((minibufferp) default-color)
           ((evil-insert-state-p) '("#e80000" . "#ffffff"))
           ((evil-visual-state-p) '("#ffa200" . "#ffffff"))
           ((evil-emacs-state-p) '("#444488" . "#ffffff"))
           ((buffer-modified-p)  '("#006fa0" . "#ffffff"))
           (t default-color))))
        (set-face-background 'mode-line (car color))
        (set-face-foreground 'mode-line (cdr color))
        ;; change cursor by state
        (setq evil-emacs-state-cursor '("red" box))
        (setq evil-normal-state-cursor '("green" box))
        (setq evil-visual-state-cursor '("orange" box))
        (setq evil-insert-state-cursor '("red" bar))
        (setq evil-replace-state-cursor '("red" bar))
        (setq evil-operator-state-cursor '("red" hollow))
        )
      )
   )
)
(require 'evil-search-highlight-persist)
(global-evil-search-highlight-persist t)

;; Specify that any company-clang-arguments are safe to remove confirmation
;;  on .dir-locals.el
;;   http://stackoverflow.com/questions/19806176/in-emacs-how-do-i-make-a-local-variable-safe-to-be-set-in-a-file-for-all-possibl
(put 'company-clang-arguments 'safe-local-variable (lambda (xx) t))

;; Don't indent braces
;;  http://blog.binchen.org/posts/ccjava-code-indentation-in-emacs.html
(defun fix-c-indent-offset-according-to-syntax-context (key val)
;; remove the old element
(setq c-offsets-alist (delq (assoc key c-offsets-alist) c-offsets-alist))
;; new value
(add-to-list 'c-offsets-alist '(key . val)))

(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              ;; indent
              (fix-c-indent-offset-according-to-syntax-context 'substatement 0)
              (fix-c-indent-offset-according-to-syntax-context 'func-decl-cont 0))))

;; flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)
(global-flycheck-mode t)

;; flycheck errors on a tooltip (doesnt work on console)
;;  TODO fix this

(setq make-backup-files nil)

(setq save-place-file "~/.emacs.d/saveplace")
(setq-default save-place t)
(require 'saveplace)

(provide 'init)
;;; init.el ends here
