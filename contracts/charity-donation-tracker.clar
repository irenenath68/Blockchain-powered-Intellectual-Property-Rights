(define-constant ERR-ALREADY-REGISTERED u100)
(define-constant ERR-NOT-OWNER u101)
(define-constant ERR-NOT-FOUND u102)

(define-map donations
  { id: uint }
  { donor: principal, amount: uint, memo: (string-utf8 64) }
)

(define-public (donate (id uint) (amount uint) (memo (string-utf8 64)))
  (if (is-some (map-get? donations {id: id}))
      (err ERR-ALREADY-REGISTERED)
      (begin
        (map-set donations {id: id} {donor: tx-sender, amount: amount, memo: memo})
        (ok true)
      )
  )
)

(define-read-only (get-donation (id uint))
  (map-get? donations {id: id})
)

(define-public (update-memo (id uint) (new-memo (string-utf8 64)))
  (match (map-get? donations {id: id})
    d (if (is-eq (get donor d) tx-sender)
           (begin
             (map-set donations {id: id} {donor: tx-sender, amount: (get amount d), memo: new-memo})
             (ok true)
           )
           (err ERR-NOT-OWNER))
    (err ERR-NOT-FOUND)
  )
)
