#lang racket/base
(require (for-syntax racket/base
                     syntax/parse/pre
                     "statically-str.rkt"
                     "srcloc.rkt")
         "parens.rkt"
         (submod "assign.rkt" for-assign)
         (only-in "repetition.rkt"
                  identifier-repetition-use)
         "call-result-key.rkt"
         "op-literal.rkt"
         "function-arity.rkt")

(provide (for-syntax dot-parse-dispatch
                     set-parse-function-call!))

(define-for-syntax (dot-parse-dispatch k)
  (lambda (lhs dot field-stx tail more-static? repetition? success-k fail-k)
    (define (ary mask n-k no-k)
      (define (bad msg)
        (raise-syntax-error #f msg field-stx))
      (syntax-parse tail
        [((~and args (p-tag::parens g ...)) . new-tail)
         (define-values (n kws rsts? kwrsts?)
           (let loop ([gs (syntax->list #'(g ...))] [n 0] [kws null] [rsts? #f] [kwrsts? #f])
             (cond
               [(null? gs) (values n kws rsts? kwrsts?)]
               [else
                (syntax-parse (car gs)
                  #:datum-literals (group op)
                  [(group kw:keyword . _)
                   (loop (cdr gs) n (cons #'kw kws) rsts? kwrsts?)]
                  [(group _::&-expr . _)
                   (loop (cdr gs) n kws #t kwrsts?)]
                  [(group _::~&-expr . _)
                   (loop (cdr gs) n kws rsts? #t)]
                  [_
                   (loop (cdr gs) (add1 n) kws rsts? kwrsts?)])])))
         (cond
           [(check-arity #f #f mask n kws rsts? kwrsts? #f)
            (success-k (n-k #'(p-tag g ...)
                            (lambda (e)
                              (relocate+reraw
                               (respan (datum->syntax #f (list lhs dot field-stx #'args)))
                               e)))
                       #'new-tail)]
           [else
            (if more-static?
                (bad (string-append "wrong number of arguments in method call" statically-str))
                (success-k (no-k (lambda (e)
                                   (relocate+reraw
                                    (respan (datum->syntax #f (list lhs dot field-stx)))
                                    e)))
                           tail))])]
        [_
         (if more-static?
             (bad "expected parentheses afterward")
             (success-k (no-k (lambda (e)
                                (relocate+reraw
                                 (respan (datum->syntax #f (list lhs dot field-stx)))
                                 e)))
                        tail))]))

    (define (nary mask direct-id id)
      (define rator
        (cond
          [repetition? (identifier-repetition-use direct-id)]
          [else direct-id]))
      (ary mask
           (lambda (args reloc)
             (define-values (proc tail to-anon-function?)
               (parse-function-call rator (list lhs) #`(#,dot #,args)
                                    #:srcloc (reloc #'#f)
                                    #:static? more-static?
                                    #:can-anon-function? #t
                                    #:repetition? repetition?))
             proc)
           ;; return partially applied method
           (lambda (reloc)
             (reloc #`(#,id #,lhs)))))

    (define field
      (let ([just-access
             (lambda (mk)
               (success-k (mk lhs
                              (lambda (e)
                                (relocate+reraw
                                 (respan (datum->syntax #f (list lhs dot field-stx)))
                                 e)))
                          tail))])
        (case-lambda
          [(mk) (just-access mk)]
          [(mk mk-set)
           (syntax-parse tail
             [assign::assign-op-seq
              (define-values (assign-expr tail)
                (build-assign
                 (attribute assign.op)
                 #'assign.op-name
                 #'assign.name
                 #`(lambda ()
                     #,(mk lhs (lambda (e)
                                 (relocate+reraw
                                  (respan (datum->syntax #f (list lhs dot field-stx)))
                                  e))))
                 #`(lambda (v)
                     #,(mk-set lhs #'v
                               (lambda (e)
                                 (relocate+reraw
                                  (respan (datum->syntax #f (list lhs dot field-stx)))
                                  e))))
                 #'value
                 #'assign.tail))
              (success-k assign-expr tail)]
             [_ (just-access mk)])])))

    (k (syntax-e field-stx) field ary nary repetition? fail-k)))

(define-for-syntax parse-function-call #f)
(define-for-syntax (set-parse-function-call! proc)
  (set! parse-function-call proc))
