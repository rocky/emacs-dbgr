;;; Copyright (C) 2010, 2011 Rocky Bernstein <rocky@gnu.org>
;;; gdb debugger

(eval-when-compile (require 'cl))

(require 'load-relative)
(require-relative-list '("../../common/regexp" "../../common/loc") "dbgr-")

(defvar dbgr-pat-hash)
(declare-function make-dbgr-loc-pat (dbgr-loc))

(defvar dbgr-gdb-pat-hash (make-hash-table :test 'equal)
  "hash key is the what kind of pattern we want to match:
backtrace, prompt, etc.  the values of a hash entry is a
dbgr-loc-pat struct")

(declare-function make-dbgr-loc "dbgr-loc" (a b c d e f))

(defconst dbgr-gdb-frame-file-regexp
 "\\(.+\\):\\([0-9]+\\)")

;; regular expression that describes a gdb location generally shown
;; before a command prompt. NOTE: we assume annotate 1!
(setf (gethash "loc" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp (format "^%s:\\([0-9]+\\):beg:0x\\([0-9a-f]+\\)"
		       dbgr-gdb-frame-file-regexp)
       :file-group 1
       :line-group 2
       :char-offset-group 3))

(setf (gethash "prompt" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp   "^(gdb) "
       ))

;;  regular expression that describes a "breakpoint set" line
(setf (gethash "brkpt-set" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp "^Breakpoint \\([0-9]+\\) at 0x\\([0-9a-f]*\\): file \\(.+\\), line \\([0-9]+\\).\n"
       :num 1
       :file-group 3
       :line-group 4))

(defconst dbgr-gdb-frame-start-regexp
  "\\(?:^\\|\n\\)")

(defconst dbgr-gdb-frame-num-regexp
  "#\\([0-9]+\\)  ")

;; Regular expression that describes a remake "backtrace" command line.
;; For example:
;; #0  main (argc=2, argv=0xbffff564, envp=0xbffff570) at main.c:935
(setf (gethash "debugger-backtrace" dbgr-gdb-pat-hash)
      (make-dbgr-loc-pat
       :regexp 	(concat dbgr-gdb-frame-start-regexp 
			dbgr-gdb-frame-num-regexp
			"\\(.*\\)[ \n]+at "
			dbgr-gdb-frame-file-regexp
			)
       :num 1
       :file-group 3
       :line-group 4)
      )

(defvar dbgr-gdb-command-hash (make-hash-table :test 'equal)
  "Hash key is command name like 'continue' and the value is 
  the gdb command to use, like 'continue'")

(setf (gethash "break"    dbgr-gdb-command-hash) "break %l")
(setf (gethash "continue" dbgr-gdb-command-hash) "continue")
(setf (gethash "quit"     dbgr-gdb-command-hash) "quit")
(setf (gethash "run"      dbgr-gdb-command-hash) "run")
(setf (gethash "step"     dbgr-gdb-command-hash) "step %p")
(setf (gethash "gdb" dbgr-command-hash) dbgr-gdb-command-hash)

(setf (gethash "gdb" dbgr-pat-hash) dbgr-gdb-pat-hash)

(provide-me "dbgr-gdb-")
