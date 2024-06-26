;;; netlogo-mode.el --- Major mode for editing NetLogo source files  -*- lexical-binding: t -*-
;;
;; Author:
;; Version: 2.0
;; Package-Version:
;; URL: https://github.com/sokobania/netlogo-mode

;;;; MetaData
;;   :PROPERTIES:
;;   :copyright:
;;   :copyright-years:
;;   :version:  2.0
;;   :licence:  GPL 2 or later (free software)
;;   :licence-url: http://www.gnu.org/licenses/
;;   :part-of-emacs: no
;;   :author:
;;   :author_email:
;;   :inspiration: reyman/netlogo-highlight grusell/netlogo-highlight tgolsson/netlogo-mode
;;   :keywords: emacs
;;   :git-repo: https://github.com/sokobania/netlogo-mode
;;   :git-clone:
;;   :END:

;;; Commentary:
;; Major mode for editing NetLogo .nls and .nlogo files.

;;; :TODO: 240322 Add a customizable user option to prevent empty lines to be indented.

;;; Code:

(defgroup netlogo-mode nil
  "Major mode for editing NetLogo files."
  :group 'languages)

(defvar netlogo-mode-hook nil)

(add-to-list 'auto-mode-alist '("\\.nls\\'" . netlogo-mode))
(add-to-list 'auto-mode-alist '("\\.nlogo\\'" . netlogo-mode))
(add-to-list 'auto-mode-alist '("\\.nlogo3d\\'" . netlogo-mode))

(defcustom netlogo-indent-width 2
  "The indentation width (size of tabs) when indenting NetLogo code."
  :type 'integer
  :group 'netlogo-mode)

(defvar netlogo-indent-increase-regexp
  "\\\[\\|\\(^\\|\s\\)to\-report\\|\\(^\\|\s\\)to"
  "Regexp selecting elements that cause an increase in indentation.")

(defvar netlogo-indent-decrease-regexp "\\\]\\|\\(^\\|\s\\)end\\($\\|\s\\)"
  "Regexp selecting elements that cause a decrease in indentation.")

(defvar netlogo-mode-map
  (let ((netlogo-mode-map (make-keymap)))
    (define-key netlogo-mode-map "\C-j" 'newline-and-indent)
    (define-key netlogo-mode-map "\C-cf" 'netlogo-goto-function-def-at-point)
    netlogo-mode-map)
  "Keymap for netlogo major mode.")

(defvar netlogo-mode-syntax-table
  (let ((netlogo-mode-syntax-table (make-syntax-table)))

    ;; Symbols
    (modify-syntax-entry ?_ "_" netlogo-mode-syntax-table)

    ;; Operators (punctuation)
    (modify-syntax-entry ?+ "." netlogo-mode-syntax-table)
    ;;(modify-syntax-entry ?- "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?* "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?/ "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?% "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?& "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?| "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?^ "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?! "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?= "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?< "." netlogo-mode-syntax-table)
    (modify-syntax-entry ?> "." netlogo-mode-syntax-table)

    (modify-syntax-entry ?- "w" netlogo-mode-syntax-table)
    (modify-syntax-entry ?\( "()" netlogo-mode-syntax-table)
    (modify-syntax-entry ?\) ")(" netlogo-mode-syntax-table)
    (modify-syntax-entry ?\; "< b" netlogo-mode-syntax-table)
    (modify-syntax-entry ?\[ "(]" netlogo-mode-syntax-table)
    (modify-syntax-entry ?\] ")[" netlogo-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" netlogo-mode-syntax-table)
    netlogo-mode-syntax-table)
  "Syntax table for netlogo-mode.")

;; Define several classes of keywords
(defvar netlogo-logic-keywords
  '("!=" "*" "+" "-" "/" "<" "<=" "=" ">" ">=" "^" "abs" "acos" "all?" "and" "any?" "approximate-hsb" "approximate-rgb" "asin" "at-points" "atan" "autoplot?" "base-colors" "behaviorspace-run-number" "both-ends" "but-first" "but-last" "can-move?" "cieiling" "color" "cos" "count" "date-and-time" "distance" "distancexy" "dx" "dy" "empty?" "end1" "end2" "error-message" "exp" "extract-hsb" "extract-rgb" "file-at-end?" "file-exists?" "file-read" "file-read-characters" "file-read-line" "filter" "first" "floor" "fput" "heading" "hidden?" "hsb" "hubnet-clients-list" "hubnet-enter-message?" "hubnet-exit-message?" "hubnet-message" "hubnet-message-source" "hubnet-message-tag" "hubnet-message-waiting?" "ifelse-value" "in-cone" "in-link-from" "in-link-neighbor?" "in-link-neighbors" "in-radius" "int" "is-agent?" "is-agentset?" "is-command-task?" "is-directed-link?" "is-link-set?" "is-link?" "is-list?" "is-number?" "is-patch-set?" "is-patch?" "is-reporter-task?" "is-string?" "is-turtle-set?" "is-turtle?" "is-undirected-link?" "item" "label" "label-color" "last" "length" "link" "link-heading" "link-length" "link-neighbor?" "link-neighbors" "link-set" "link-shapes" "link-with" "links" "list" "ln" "log" "lput" "map" "max" "max-n-of" "max-one-of" "max-pxcor" "max-pycor" "max-pzcor" "mean" "median" "member?" "min" "min-n-of" "min-one-of" "min-pxcor" "min-pycor" "min-pzcor" "mod" "modes" "mouse-down?" "mouse-inside?" "mouse-xcor" "mouse-ycor" "mouse-zcor" "movie-status" "my-in-links" "my-links" "my-out-links" "myself" "n-of" "n-values" "neighbors" "neighbors4" "netlogo-applet?" "netlogo-version" "new-seed" "no-links" "no-patches" "no-turtles" "not" "of" "one-of" "or" "other" "other-end" "out-link-neighbor?" "out-link-neighbors" "out-link-to" "patch" "patch-ahead" "patch-at" "patch-at-heading-and-distance" "patch-here" "patch-left-and-ahead" "patch-right-and-ahead" "patch-set" "patch-size" "patches" "pcolor" "pen-mode" "pen-size" "plabel" "plabel-color" "plot-name" "plot-pen-exists?" "plot-x-max" "plot-x-min" "plot-y-max" "plot-y-min" "position" "precision" "pxcor" "pycor" "pzcor" "random" "random-exponential" "random-float" "random-gamma" "random-normal" "random-poisson" "random-pxcor" "random-pycor" "random-pzcor" "random-xcor" "random-ycor" "random-zcor" "read-from-string" "reduce" "remainder" "remove" "remove-duplicates" "remove-item" "replace-item" "reverse" "rgb" "round" "runresult" "scale-color" "self" "sentence" "shade-of?" "shape" "shapes" "shuffle" "sin" "size" "sort" "sort-by" "sort-on" "sqrt" "standard-deviation" "subject" "sublist" "substring" "subtract-headings" "sum" "tan" "task" "thickness" "ticks" "tie-mode" "timer" "towards" "towardsxy" "turtle" "turtle-set" "turtles" "turtles-at" "turtles-here" "turtles-on" "user-directory" "user-file" "user-input" "user-new-file" "user-one-of" "user-yes-or-no?" "variance" "who" "with" "with-max" "with-min" "word" "world-height" "world-width" "wrap-color" "xcor" "xor" "ycor" "zcor")
  "NetLogo keywords.")
(defvar netlogo-types
  '("__includes" "breed" "directed-link-breed" "end" "extensions" "globals" "links-own" "patches-own" "to" "to-report" "turtles-own" "undirected-link-breed"))
(defvar netlogo-constants
  '("black" "blue" "brown" "cyan" "e" "false" "gray" "green" "lime" "magenta" "nobody" "orange" "pi" "pink" "red" "sky" "true" "turquoise" "violet" "white" "yellow"))
(defvar netlogo-events '("eventest"))
(defvar netlogo-functions
  '("__set-line-thickness" "ask" "ask-concurrent" "auto-plot-off" "auto-plot-on" "back" "beep" "bk" "ca" "carefully" "cd" "clear-all" "clear-all-plots" "clear-drawing" "clear-links" "clear-output" "clear-patches" "clear-plot" "clear-ticks" "clear-turtles" "cp" "create-link-from" "create-link-to" "create-link-with" "create-links-from" "create-links-to" "create-links-with" "create-ordered-turtles" "create-temporary-plot-pen" "create-turtles" "cro" "crt" "ct" "die" "diffuse" "diffuse4" "display" "downhill" "downhill4" "error" "every" "export-all-plots" "export-interface" "export-output" "export-plot" "export-view" "export-world" "face" "facexy" "fd" "file-close" "file-close-all" "file-delete" "file-flush" "file-open" "file-print" "file-show" "file-type" "file-write" "follow" "follow-me" "foreach" "forward" "hatch" "hide-link" "hide-turtle" "histogram" "home" "ht" "hubnet-broadcast" "hubnet-broadcast-clear-output" "hubnet-broadcast-message" "hubnet-clear-override" "hubnet-clear-overrides" "hubnet-fetch-message" "hubnet-kick-all-clients" "hubnet-kick-client" "hubnet-reset" "hubnet-reset-perspective" "hubnet-send" "hubnet-send-clear-output" "hubnet-send-follow" "hubnet-send-message" "hubnet-send-override" "hubnet-send-watch" "hubnet-set-client-interface" "if" "ifelse" "import-drawing" "import-pcolors" "import-pcolors-rgb" "import-world" "inspect" "jump" "layout-circle" "layout-radial" "layout-spring" "layout-tutte" "left" "let" "loop" "lt" "move-to" "movie-cancel" "movie-close" "movie-grab-interface" "movie-grab-view" "movie-set-frame-rate" "movie-start" "no-display" "output-print" "output-show" "output-type" "output-write" "pd" "pe" "pen-down" "pen-erase" "pen-up" "plot" "plot-pen-down" "plot-pen-reset" "plot-pen-up" "plotxy" "print" "pu" "random-seed" "repeat" "report" "reset-perspective" "reset-ticks" "reset-timer" "resize-world" "ride" "ride-me" "right" "rp" "rt" "run" "set" "set-current-directory" "set-current-plot" "set-current-plot-pen" "set-default-shape" "set-histogram-num-bars" "set-patch-size" "set-plot-pen-color" "set-plot-pen-interval" "set-plot-pen-mode" "set-plot-x-range" "set-plot-y-range" "setup-plots" "setxy" "show" "show-link" "show-turtle" "sprout" "st" "stamp" "stamp-erase" "startup" "stop" "tick" "tick-advance" "tie" "type" "untie" "update-plots" "uphill" "uphill4" "user-message" "wait" "watch" "watch-me" "while" "with-local-randomness" "without-interruption" "write"))

;; Define the regexp corresponding to the different classes of keywords
(defvar netlogo-types-regexp (regexp-opt netlogo-types 'words))
(defvar netlogo-constants-regexp (regexp-opt netlogo-constants 'words))
(defvar netlogo-events-regexp (regexp-opt netlogo-events 'words))
(defvar netlogo-functions-regexp (regexp-opt netlogo-functions 'words))
(defvar netlogo-keywords-regexp (regexp-opt netlogo-logic-keywords 'words))

(defvar netlogo-keywords-breeds-left "own\\|at\\|here\\|on")
(defvar netlogo-keywords-breeds-right "create\\|create-ordered\\|hatch\\|sprout\\|is\\|at\\|here\\|on")

;; Create the list for font-lock.
;; Each class of keyword is given a particular face.
(defvar netlogo-font-lock-keywords
  `((,netlogo-types-regexp . font-lock-type-face)
    (,netlogo-constants-regexp . font-lock-constant-face)
    (,netlogo-events-regexp . font-lock-builtin-face)
    (,netlogo-functions-regexp . font-lock-function-name-face)
    (,netlogo-keywords-regexp . font-lock-keyword-face)

    ;; FUNCTION NAMES in declarations
    ;;("\\(\\<\\(?:to-report\\|to\\)\\>\\)\s*\\(\\w+\\)\s*\\(\\[\\(\\(\s*?\\<\\w+\\>\s*?\\)+\\)\\]\\)?"
    ;; (1 'font-lock-keyword-face)
    ;; (2 'font-lock-function-name-face)
    ;; (3 'font-lock-variable-name-face)
    ;; )

    ;; ASK
    ("\\(\\<ask\\>\\)\s*\\(\\w+\\)\s*\\(with\s*\\[\\w+\\]\\)?"
     ;; (1 'font-lock-keyword-face)
     ;; (2 'font-lock-function-name-face)
     ;; (3 'font-lock-variable-name-face)
     )

    ;;METHOD PARAM definition
    ;;FIXME : Ne marche pas encore ...
    (,(concat "\\(\\<\\w+-\\(?:" netlogo-keywords-breeds-left "\\)\\>\\)")
     (1 'font-lock-keyword-face))
    (,(concat "\\(\\<\\(?:" netlogo-keywords-breeds-right "\\)-\\w+\\>\\)")
     (1 'font-lock-keyword-face))
    ;; note: order above matters. "mylsl-keywords-regexp" goes last because
    ;; otherwise the keyword "state" in the function "state_entry"
    ;; would be highlighted.
    ))

(defvar netlogo-indent-positive-change 0)
(defvar netlogo-indent-negative-change 0)
(defvar netlogo-search-end-position 0)
(defvar netlogo-indent-change 0)
(defvar netlogo-indent-here 0)

(defun netlogo-is-logic-keyword? (keyword)
  "Return T if KEYWORD is a logic keyword."
  (if (member keyword netlogo-logic-keywords) t nil))

(defun netlogo-is-type? (keyword)
  "Return T if KEYWORD is a type."
  (if (member keyword netlogo-types) t  nil))

(defun netlogo-is-constant? (keyword)
  "Return T if KEYWORD is a constant."
  (if (member keyword netlogo-constants) t  nil))

(defun netlogo-is-event? (keyword)
  "Return T if KEYWORD is an event."
  (if (member keyword netlogo-events) t  nil))

(defun netlogo-is-function? (keyword)
  "Return T if KEYWORD is a function."
  (if (member keyword netlogo-functions) t  nil))

(defun netlogo-is-builtin (keyword)
  "Return the type of KEYWORD as a string."
  (cond
   ((netlogo-is-function? keyword) "function")
   ((netlogo-is-logic-keyword? keyword) "logic keyword")
   ((netlogo-is-type? keyword) "type")
   ((netlogo-is-constant? keyword) "constant")
   ((netlogo-is-event? keyword) "event")))

(defun netlogo-goto-function-def-at-point (function-name)
  "Go to the definition of FUNCTION-NAME.

When called interactively, go to definition of the function at point."
  (interactive
   (let ((fun (thing-at-point 'symbol)))
     (list (read-string (concat "Function name (" fun "): ") nil nil fun))))
  (let ((builtin (netlogo-is-builtin function-name))
        (function-pos))
    (when (or (null function-name)
              (= 0 (length function-name)))
      (setq function-name (thing-at-point 'symbol)))
    (if builtin
        (message (concat function-name " is a builtin " builtin))
      (save-excursion
        (goto-char (point-min))
        (setq function-pos
              (search-forward-regexp (concat "\\(to\\|to-report\\)[[:space:]]+\\(" function-name "\\)[[:space:]\n]") nil t)))
      (if function-pos
          ;; move the point to the beginning of the function name
          (goto-char (match-beginning 2))
        (message (concat "No function definition found for " function-name))))))

(defconst netlogo-source-separator "@#$#@#$#@")

(defun netlogo-indent-change-for-line ()
  "Return the number of indentation changes for the current line."
  (setq netlogo-indent-positive-change 0
        netlogo-indent-negative-change 0)
  (save-excursion
    (beginning-of-line)
    ;; if line has comment, don't do anything beyond it
    (setq netlogo-search-end-position
          (if (search-forward ";" (line-end-position) t)
              (point)
            (line-end-position)))
    ;; calculate net change for the line
    (beginning-of-line)
    (while (re-search-forward netlogo-indent-increase-regexp netlogo-search-end-position t)
      (setq netlogo-indent-positive-change (1+ netlogo-indent-positive-change)))
    (beginning-of-line)
    (while (re-search-forward netlogo-indent-decrease-regexp netlogo-search-end-position t)
      (setq netlogo-indent-negative-change (1+ netlogo-indent-negative-change))))
  (* (- netlogo-indent-positive-change netlogo-indent-negative-change) netlogo-indent-width))


(defun netlogo-indent-previous-indent ()
  "Return the indentation at the previous line with content."
  (if (and (> (count-lines 1 (point)) 0)
           (save-excursion (beginning-of-line)
                           (re-search-backward "^[\s-]*\\(\\w\\|\\]\\|\\[\\)" nil t)))
      (save-excursion
        (beginning-of-line)
        (re-search-backward "^[\s-]*\\(\\w\\|\\]\\|\\[\\)" nil t)
        (setq netlogo-indent-change (netlogo-indent-change-for-line))
        (if (>= netlogo-indent-change 0)
            (+ netlogo-indent-change (current-indentation))
          (current-indentation)))
    0))


(defun line-has-string (arg)
  "Return non-NIL when the current line matches the ARG regexp."
  (save-excursion
    (beginning-of-line)
    (re-search-forward arg (line-end-position) t)))

(defun netlogo-indent-line (&optional args)
  "Indent current line as NetLogo code."
  (interactive)
  (setq netlogo-indent-here (netlogo-indent-previous-indent)
        netlogo-indent-change (netlogo-indent-change-for-line))
  (cond
   ((line-has-string "^[\s-]*;;;")
    (setq netlogo-indent-here 0
          netlogo-indent-change -100))
   ((line-has-string "^[\s-]*;\\([^;]\\|$\\)")
    (setq netlogo-indent-here comment-column
          netlogo-indent-change 0)))
  (save-excursion ; remove
    (back-to-indentation)
    (fixup-whitespace))
  (save-excursion
    (back-to-indentation)
    (if (>= netlogo-indent-change 0) ; positive edge
        (indent-to netlogo-indent-here)
      (indent-to (+ netlogo-indent-here netlogo-indent-change)))) ; negative edge
  (when (= (point) (line-beginning-position))
    (back-to-indentation)))


(defun netlogo-indent-region (start end)
  "Indent current region as NetLogo code.

Called from a program, START and END specify the region to indent."
  (interactive "r")
  (save-excursion
    (goto-char start)
    (setq netlogo-indent-here (netlogo-indent-previous-indent))
    (while (< (point) end)
      (cond
       ((line-has-string "^[\s-]+;;;")
        (beginning-of-line)
        (fixup-whitespace))
       ((line-has-string "^[\s-]+;\\([^;]\\|$\\)")
        (beginning-of-line)
        (fixup-whitespace)
        (indent-to comment-column))
       (t
        (setq netlogo-indent-change (netlogo-indent-change-for-line))
        (beginning-of-line)
        (fixup-whitespace)
        (if (>= netlogo-indent-change 0)
            (progn ; positive change - applies to next line
              (indent-to-column netlogo-indent-here)
              (setq netlogo-indent-here (+ netlogo-indent-here netlogo-indent-change)))
          ;; negative change - applied instantly
          (setq netlogo-indent-here (+ netlogo-indent-here netlogo-indent-change))
          (indent-to-column netlogo-indent-here))))
      (forward-line))))


;;;###autoload
(define-derived-mode netlogo-mode prog-mode "NetLogo"
  "Major mode for editing NetLogo files."
  :group 'netlogo
  ;; code for syntax highlighting
  (setq font-lock-defaults '((netlogo-font-lock-keywords)))

  ;;(set (make-local-variable 'font-lock-defaults) '(netlogo-font-lock-keywords))
  ;;(set (make-local-variable 'indent-line-function) 'netlogo-indent-line)

  ;; for indentation
  (make-local-variable 'indent-line-function)
  (make-local-variable 'indent-region-function)
  (setq indent-line-function 'netlogo-indent-line)
  (setq indent-region-function 'netlogo-indent-region)

  ;; for comments
  (make-local-variable 'comment-start)
  (setq comment-start ";"))

(provide 'netlogo-mode)
;;; netlogo-mode.el ends here
