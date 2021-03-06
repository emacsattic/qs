;;; qs.el --- search utility

;; Copyright (C) 2004 by Free Software Foundation, Inc.

;; Author:  <jay@kldp.org>
;; Keywords: convenience, hypermedia

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Quickly search via the web search engine with one key stroke.
;; sample usage:
;; 1. load this file into your emacs and eval:
;;    (define-key mode-specific-map "d" 'qs-search)
;; 2. try "C-c d" and enter "g Emacs"
;;; Code:

(defvar qs-keywords
  '(
    av
    "http://www.altavista.com/cgi-bin/query?text=yes&q=%s"
    bible
    "http://bible.gospelcom.net/cgi-bin/bible?passage=%s"
    dict
    "http://www.dictionary.com/cgi-bin/dict.pl?term=%s"
    dmoz
    "http://search.dmoz.org/cgi-bin/search?search=%s"
    fm
    "http://freshmeat.net/search/?q=%s"
    s
    "http://citeseer.ist.psu.edu/cis?q=%s&submit=Search+Documents&cs=1"
    t
    "http://s.teoma.com/search?q=%s&qcat=1&qsrc=0"
    f
    "http://wombat.doc.ic.ac.uk/foldoc/foldoc.cgi?query=%s&action=Search"
    m
    "http://planetmath.org/?op=search&term=%s"
    a
    "http://www.google.com/answers/search?qtype=answered&q=%s"
    g
    "http://www.google.com/search?q=%s"
    gg
    "http://www.google.com/search?btnI=1&q=%s"
    gk
    "http://labs.google.com/cgi-bin/keys?q=%s"
    gl
    "http://labs.google.com/glossary?q=%s"
    gm
    "http://www.google.com/microsoft?hq=microsoft&q=%s"
    gn
    "http://groups.google.com/groups?q=%s"
    imdb
    "http://www.imdb.com/Tsearch?%s"
    isbn
    "http://isbn.nu/%s/price"
    mskb
    "http://cryo.gen.nz/projects/mskb/?q=%s"
    mw
    "http://www.m-w.com/cgi-bin/dictionary?book=Dictionary&va=%s"
    n
    "http://search.naver.com/search.naver?where=nexearch&query=%s"
    nb
    "http://100.naver.com/search.naver?query=%s"
    yd
    "http://kr.engdic.yahoo.com/search/engdic?p=%s"
    nd
    "http://dic.naver.com/endic?where=dic&query=%s"
    ni
    "http://kinsearch.naver.com/search.naver?where=allqna&query=%s"
    r
    "http://ragingsearch.altavista.com/cgi-bin/query?q=%s"
    rc5
    "http://stats.distributed.net/rc5-64/psearch.php3?st=%s"
    rfc
    "http://www.faqs.org/rfcs/rfc%s.html"
    rhyme
    "http://rhyme.lycos.com/r/rhyme.cgi?Word=%s"
    thes
    "http://www.thesaurus.com/cgi-bin/search?config=roget&words=%s"
    w
    "http://www.wikipedia.org/w/wiki.phtml?search=%s"
    whats
    "http://www.netcraft.com/whats/?host=%s"
    whois
    "http://www.domainwatch.com/getwho.cgi?dom=%s"
    wp
    "http://www.whitepages.co.nz/cgi-bin/search?loc=AK&key=%s"
    yp
    "http://www.yellowpages.co.nz/quick/search?lkey=Auckland&key=%s"
    )
  "*List of keyword and it's url mapping.
generated by:
wget -O - -q http://people.kldp.org/~jay/win/searchurl.reg |
  grep '^[[@]' |
  sed -e '1d' -e 's,^.*\\,,g' -e 's,]\r,,' -e 's,@=,,' |
  tr -d '\r'
")

(defun qs-url-encode (str &optional coding)
  "stolen from w3m-url-encode-string"
  (apply #'concat
         (mapcar
          (lambda (ch)
            (cond
             ((eq ch ?\n)               ; newline
              "%0D%0A")
             ((string-match "[-a-zA-Z0-9_:/.]" (char-to-string ch)) ; xxx?
              (char-to-string ch))      ; printable
             ((char-equal ch ?\x20)     ; space
              "+")
             (t
              (format "%%%02x" ch))))   ; escape
          ;; Coerce a string to a list of chars.
          (append (encode-coding-string (or str "")
                                        (or coding
                                            'euc-kr
                                            'iso-8859-1))
                  nil))))

(defun qs-search (url-string)
  "immitage the search url facility in MSIE w/ web accessories"
  (interactive "sURL ('?' for help): ")
  (let* ((pos (position ? url-string))
         (key (intern (substring url-string 0 pos)))
         (idx (position key qs-keywords)))
    (if (and pos idx)
        (let ((buzzword (substring url-string (1+ pos))))
          (browse-url (format (nth (1+ idx) qs-keywords)
                              (qs-url-encode buzzword))))
      (if (string= url-string "?")
          (with-output-to-temp-buffer "*Help*"
            (princ "Simply type any url ('https?://' is optional) or")
            (terpri) (terpri)
            (loop for key in qs-keywords by #'cddr
                  for url in (cdr qs-keywords) by #'cddr
                  do (princ (format "  %-10s%s" key url))
                  do (terpri)))
        (or (string-match "^https?://" url-string)
            (setq url-string (concat "http://" url-string)))
        (browse-url url-string)))))
;;; qs.el ends here
