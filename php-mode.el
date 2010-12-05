
(load "~/emacs/lexlite.el")

(defconst php-mode-lexlite-rules
  `(:base
    (
     ("<\\?php"
      (0 font-lock-keyword-face :php-code))
     ("<!\\(DOCTYPE\\)"
      (0 font-lock-constant-face)
      (1 font-lock-builtin-face :doctype))
     ("<!--"
      (0 font-lock-comment-face :comment))
     ("<[/?]?\\([0-9A-Za-z._:-]+\\)"
      (0 font-lock-constant-face)
      (1 font-lock-function-name-face :tag))
     ("&[#0-9A-Za-z._:-]+;"
      font-lock-constant-face)
     )
    :comment
    (
     ("\\([^<-]+\\|-[^-]\\|--[^>]\\|<[^?]\\|<\\?[^p\\|<\\?p[^h]\\|<\\?ph[^p]\\)+"
      font-lock-comment-face)
     ("<\\?php"
      (0 font-lock-keyword-face :php-code))
     ("-->"
      (0 font-lock-comment-face pop))
     )
    :doctype
    (
     ("\"[^<>\"]*\""
      (0 font-lock-string-face))
     ("'[^<>']*'"
      (0 font-lock-string-face))
     ("<"
      (0 font-lock-variable-name-face :doctype))
     (">"
      (0 font-lock-variable-name-face pop))
     ("[^<>\"]+"
      (0 font-lock-variable-name-face))
     )
    :tag
    (
     ("[0-9A-Za-z._:-]+"
      font-lock-variable-name-face)
     ("\""
      (0 font-lock-string-face :attribute-double))
     ("\'"
      (0 font-lock-string-face :attribute-single))
     ("[/?]?>"
      (0 font-lock-constant-face pop))
     )
    :attribute-double
    (
     ("<\\?php"
      (0 font-lock-keyword-face :php-code)
      )
     ("[^<>&\"]+"
      font-lock-string-face)
     ("\""
      (0 font-lock-string-face pop))
     )
    :attribute-single
    (
     ("<\\?php"
      (0 font-lock-keyword-face :php-code)
      )
     ("[^<>&\']+"
      font-lock-string-face)
     ("&[#0-9A-Za-z._:-]+;"
      font-lock-string-face)
     ("&[#0-9A-Za-z._:-]*[^#0-9A-Za-z._:;'-]"
      font-lock-warning-face)
     ("[<>]"
      font-lock-warning-face)
     ("\'"
      (0 font-lock-string-face pop))
     )
    :php-code
    (
     
     (,(concat "\\<\\("
               (regexp-opt
                '("abstract" "and" "array" "as" "break" "case"
                  "catch" "cfunction" "class" "__CLASS__" "clone"
                  "const" "continue" "declare" "default" "die"
                  "do" "echo" "else" "elseif" "empty" "enddeclare"
                  "endfor" "endforeach" "endif" "endswitch" "endwhile"
                  "eval" "exception" "exit" "extends" "__FILE__"
                  "final" "for" "foreach" "function" "__FUNCTION__"
                  "global" "if" "implements" "include" "include_once"
                  "interface" "isset" "__LINE__" "list" "__METHOD__"
                  "new" "old_function" "or" "php_user_filter" "print"
                  "private" "protected" "public" "require" "require_once"
                  "return" "static" "switch" "throw" "try" "unset"
                  "use" "var" "while" "xor"))
               "\\)\\>")
      font-lock-keyword-face)

     (,(concat "\\<\\("
               (regexp-opt
                '("true" "false" "null"))
               "\\)\\>")
      font-lock-builtin-face)

     (,(concat "\\$_\\("
               (regexp-opt
                '("SERVER" "QUERY" "POST" "COOKIE" "SESSION" "REQUEST"))
               "\\)\\>")
      font-lock-builtin-face)
     
     ("\\(->\\)?\\(\\<[0-9A-Za-z_]+\\)("
      (2 font-lock-function-name-face))
     
     ("->\\([0-9A-Za-z_]+\\)"
      (1 font-lock-variable-name-face))
     
     ("\"\\([^\\\\\"]\\|\\\\.\\)*\""
      font-lock-string-face)
     
     ("'\\([^\\\\']\\|\\\\.\\)*'"
      font-lock-string-face)

     ("//.*?\n"
      font-lock-comment-face)
     
     ("/\\*.*?\\*/"
      font-lock-comment-face)
     
     ("\\?>"
      (0 font-lock-keyword-face pop))
     )
     
     ))


(defvar php-mode-hook nil)

(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))

(defvar php-mode-syntax-table
  (let ((php-mode-syntax-table (make-syntax-table)))
    (modify-syntax-entry ?_ "w" php-mode-syntax-table)
    (modify-syntax-entry ?/ ". 124b" php-mode-syntax-table)
    (modify-syntax-entry ?* ". 23" php-mode-syntax-table)
    (modify-syntax-entry ?\n "> b" php-mode-syntax-table)
    php-mode-syntax-table)
  "Syntax table for php-mode")

(define-derived-mode php-mode fundamental-mode "PHP"
  "Major mode for editing PHP files."
  (set-syntax-table php-mode-syntax-table)
  ;;(set (make-local-variable 'font-lock-defaults) '(php-font-lock-keywords))
  (local-set-key "\C-j" 'newline-and-indent)
  (local-set-key "\C-f" 'lexlite-fontify-buffer)
  (local-set-key "(" 'self-insert-command)
  (local-set-key ")" 'self-insert-command)
  (set (make-local-variable 'lexlite-rules) 'php-mode-lexlite-rules)
  (make-local-variable 'lexlite-state)
  (make-local-variable 'lexlite-state-stack)
  (set (make-local-variable 'indent-line-function) 'php-indent-line)
  (lexlite-mode-on)
  )

(defun php-indent-line (&rest args)
  )
