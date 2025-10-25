;; Independent IP Rights Registry (Clarity v3-style with error constants)
(define-constant ERR-ALREADY-REGISTERED u100)
(define-constant ERR-NOT-OWNER u101)
(define-constant ERR-NOT-FOUND u102)

(define-map ip-records
  ((content-hash (buff 32)))
  ((owner principal) (registered-at uint) (title (string-utf8 64)))
)

(define-read-only (get-record (content-hash (buff 32)))
  (map-get? ip-records {content-hash: content-hash})
)

(define-public (register (content-hash (buff 32)) (title (string-utf8 64)))
  (if (is-some (map-get? ip-records {content-hash: content-hash}))
      (err ERR-ALREADY-REGISTERED)
      (begin
        (map-set ip-records
          {content-hash: content-hash}
          {owner: tx-sender, registered-at: block-height, title: title}
        )
        (ok true)
      )
  )
)

(define-public (update-title (content-hash (buff 32)) (new-title (string-utf8 64)))
  (match (map-get? ip-records {content-hash: content-hash})
    rec
      (if (is-eq (get owner rec) tx-sender)
          (begin
            (map-set ip-records
              {content-hash: content-hash}
              {owner: tx-sender, registered-at: (get registered-at rec), title: new-title}
            )
            (ok true)
          )
          (err ERR-NOT-OWNER)
      )
    (err ERR-NOT-FOUND)
  )
)

(define-public (transfer-ownership (content-hash (buff 32)) (new-owner principal))
  (match (map-get? ip-records {content-hash: content-hash})
    rec
      (if (is-eq (get owner rec) tx-sender)
          (begin
            (map-set ip-records
              {content-hash: content-hash}
              {owner: new-owner, registered-at: (get registered-at rec), title: (get title rec)}
            )
            (ok true)
          )
          (err ERR-NOT-OWNER)
      )
    (err ERR-NOT-FOUND)
  )
)