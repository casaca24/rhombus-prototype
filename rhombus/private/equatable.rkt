#lang racket/base
(require (for-syntax racket/base
                     "interface-parse.rkt")
         racket/hash-code
         "provide.rkt"
         "name-root.rkt"
         (submod "annotation.rkt" for-class)
         (submod "dot.rkt" for-dot-provider)
         "realm.rkt"
         "class-dot.rkt"
         (only-in "class-desc.rkt" define-class-desc-syntax)
         "static-info.rkt")

(provide (for-spaces (rhombus/class
                      rhombus/namespace)
                     Equatable))

(define-values (prop:Equatable Equatable? Equatable-ref)
  (make-struct-type-property
   'Equatable
   #false
   (list (cons prop:equal+hash (lambda (_) bounced-equal+hash-implementation)))))

(define (bounce-to-equal-mode-proc this other recur mode)
  (equal-recur-internal-method this other recur))

(define (bounce-to-hash-mode-proc this recur mode)
  (hash-recur-internal-method this recur))

(define bounced-equal+hash-implementation
  (list bounce-to-equal-mode-proc bounce-to-hash-mode-proc))

(define-class-desc-syntax Equatable
  (interface-desc #'Equatable
                  #'Equatable
                  #'()
                  #'prop:Equatable
                  #'Equatable-ref
                  (vector-immutable (box-immutable 'equals)
                                    (box-immutable 'hash_code))
                  #'#(#:abstract #:abstract)
                  (hasheq 'equals 0 'hash_code 1)
                  #hasheq()
                  #t))

(define (equal-recur-internal-method this other recur)
  ((vector-ref (Equatable-ref this) 0) this other recur))

(define (hash-recur-internal-method this recur)
  ((vector-ref (Equatable-ref this) 1) this recur))

(define-name-root Equatable
  #:fields
  (hash_code_combine
   hash_code_combine_unordered))

(define hash_code_combine
  (case-lambda
    [(a b)
     (unless (exact-integer? a)
       (raise-argument-error* 'Equatable.hash_code_combine rhombus-realm "Integer" a))
     (unless (exact-integer? b)
       (raise-argument-error* 'Equatable.hash_code_combine rhombus-realm "Integer" b))
     (hash-code-combine a b)]
    [(lst)
     (unless (and (list? lst)
                  (andmap exact-integer? lst))
       (raise-argument-error* 'Equatable.hash_code_combine
                              rhombus-realm
                              "List.of(Integer)"
                              lst))
     (hash-code-combine* lst)]))

(define-static-info-syntax hash_code_combine (#%function-arity 6))
                                                               
(define hash_code_combine_unordered
  (case-lambda
    [(a b)
     (unless (exact-integer? a)
       (raise-argument-error* 'Equatable.hash_code_combine_unordered rhombus-realm "Integer" a))
     (unless (exact-integer? b)
       (raise-argument-error* 'Equatable.hash_code_combine_unordered rhombus-realm "Integer" b))
     (hash-code-combine-unordered a b)]
    [(lst)
     (unless (and (list? lst)
                  (andmap exact-integer? lst))
       (raise-argument-error* 'Equatable.hash_code_combine_unordered
                              rhombus-realm
                              "List.of(Integer)"
                              lst))
     (hash-code-combine-unordered* lst)]))

(define-static-info-syntax hash_code_combine_unoredered (#%function-arity 6))