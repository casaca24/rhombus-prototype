#lang racket/base
(require racket/pretty
         racket/list)

;; Parse "emoji-sequences.text" and "emoji-zwj-sequences.text" on stdin and
;; generate a lexer abbreviation that reocgnizes all sequences. While we
;; could generate an abbreviation that is just a big "or" of all sequences,
;; lexer generation would take quadratic time, which is too slow. We instead
;; collapse things that have the same prefix.

(define table (make-hasheqv))

(let loop ()
  (define l (read-line))
  (unless (eof-object? l)
    (cond
      [(regexp-match #px"^([0-9A-F]+)[.][.]([0-9A-F]+)" l)
       => (lambda (m)
            (for ([i (in-range (string->number (cadr m) 16)
                               (add1 (string->number (caddr m) 16)))])
              (define t (hash-ref table i (lambda () (make-hasheqv))))
              (hash-set! table i t)
              (hash-set! t #f #t)))]
      [(regexp-match? #px"^([0-9A-F]+)" l)
       (let loop ([l l] [table table])
         (cond
           [(regexp-match-positions #px"^[0-9A-F]+" l)
            => (lambda (m)
                 (define i (string->number (substring l (caar m) (cdar m)) 16))
                 (define t (hash-ref table i (lambda () (make-hasheqv))))
                 (hash-set! table i t)
                 (loop (substring l (cdar m)) t))]
           [(regexp-match-positions #px"^\\s" l)
            (loop (substring l 1) table)]
           [else (hash-set! table #f #t)]))])
    (loop)))

(printf "#lang racket/base\n")
(printf ";; This file is generated by \"emoji-parse.rkt\"\n")
(printf ";; with the Unicode standard files\n")
(printf ";; \"emoji-sequences.text\" and \"emoji-zwj-sequences.text\"\n")
(printf ";; provided as input\n")

(define (merge-tails l)
  (cond
    [(null? l) null]
    [(null? (cdr l)) l]
    [(equal? (cddr (car l))
             (cddr (cadr l)))
     (define tail (cddr (cadr l)))
     (let loop ([l l] [heads '()])
       (cond
         [(or (null? l)
              (not (equal? tail (cddr (car l)))))
          (cons `(:: (:or ,@(reverse heads))
                     ,@tail)
                (merge-tails l))]
         [else
          (loop (cdr l) (cons (cadr (car l))
                              heads))]))]
    [else
     (cons (car l) (merge-tails (cdr l)))]))

(define (generate table)
  (define l
    (for/list ([(i v) (in-hash table)])
      (cond
        [(not i) ""]
        [(and (hash-ref v #f #f)
              (= 1 (hash-count v)))
         (string (integer->char i))]
        [else `(:: ,(string (integer->char i)) ,(generate v))])))
  (cond
    [(null? (cdr l)) (car l)]
    [else
     (define strs (filter string? l))
     (define compound (filter (lambda (x) (not (string? x))) l))
     `(:or ,@(sort strs string<?) ,@(merge-tails (sort compound string<? #:key cadr)))]))

(define generated (generate table))

(for-each
 pretty-write
 `((require parser-tools/lex
            (prefix-in : parser-tools/lex-sre))
   (provide one-char-emoji
            emoji)
   (define-lex-abbrevs
     [one-char-emoji (:or ,@(for/list ([(i v) (in-hash table)]
                                       #:when (hash-ref v #f #f))
                              (string (integer->char i))))]
     [emoji ,generated])))

(module test racket/base)

