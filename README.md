org-babel-j
=============
org-babel functions for j

To install:

Copy ob-j.el to your lisp\org folder
Add to .emacs

(org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
        (j . t)))

(setq j-program-name "C:/.../j64-801/bin/jconsole.exe")

See: http://orgmode.org/worg/org-contrib/babel/

Adds support for J (http://jsoftware.com/) to org-babel

Screencast: http://www.youtube.com/watch?v=4vvVOdPDkTc&feature=youtu.be


