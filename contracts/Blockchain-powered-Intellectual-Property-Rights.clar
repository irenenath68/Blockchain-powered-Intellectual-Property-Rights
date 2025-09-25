(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-NOT-AUTHORIZED (err u401))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-PARAMS (err u400))
(define-constant ERR-EXPIRED (err u410))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u402))
(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-REGISTRATION-FEE u1000000)

(define-data-var next-ip-id uint u1)
(define-data-var platform-fee-rate uint u500)

(define-map intellectual-property
    { id: uint }
    {
        owner: principal,
        title: (string-ascii 128),
        description: (string-ascii 512),
        ip-type: (string-ascii 32),
        registration-date: uint,
        expiry-date: uint,
        hash: (string-ascii 64),
        is-active: bool,
        licensing-enabled: bool,
        base-license-fee: uint,
    }
)

(define-map ip-ownership-history
    {
        ip-id: uint,
        transfer-id: uint,
    }
    {
        from: principal,
        to: principal,
        timestamp: uint,
        price: uint,
    }
)

(define-map transfer-counters
    { ip-id: uint }
    { count: uint }
)

(define-map licenses
    {
        licensee: principal,
        ip-id: uint,
    }
    {
        license-type: (string-ascii 32),
        start-date: uint,
        end-date: uint,
        fee-paid: uint,
        terms: (string-ascii 256),
        is-active: bool,
    }
)

(define-map license-revenue
    { ip-id: uint }
    {
        total-earned: uint,
        license-count: uint,
    }
)

(define-map user-ip-count
    { user: principal }
    { count: uint }
)

(define-public (register-ip
        (title (string-ascii 128))
        (description (string-ascii 512))
        (ip-type (string-ascii 32))
        (validity-years uint)
        (hash (string-ascii 64))
        (enable-licensing bool)
        (license-fee uint)
    )
    (let (
            (current-id (var-get next-ip-id))
            (current-height burn-block-height)
            (expiry-height (+ current-height (* validity-years u144000)))
            (registration-fee (+ MIN-REGISTRATION-FEE (* validity-years u500000)))
        )
        (asserts! (>= (stx-get-balance tx-sender) registration-fee)
            ERR-INSUFFICIENT-PAYMENT
        )
        (asserts! (> validity-years u0) ERR-INVALID-PARAMS)
        (asserts! (> (len title) u0) ERR-INVALID-PARAMS)
        (asserts! (> (len hash) u0) ERR-INVALID-PARAMS)

        (try! (stx-transfer? registration-fee tx-sender CONTRACT-OWNER))

        (map-set intellectual-property { id: current-id } {
            owner: tx-sender,
            title: title,
            description: description,
            ip-type: ip-type,
            registration-date: current-height,
            expiry-date: expiry-height,
            hash: hash,
            is-active: true,
            licensing-enabled: enable-licensing,
            base-license-fee: license-fee,
        })

        (map-set user-ip-count { user: tx-sender } { count: (+ (get-user-ip-count tx-sender) u1) })

        (var-set next-ip-id (+ current-id u1))
        (ok current-id)
    )
)

(define-public (transfer-ownership
        (ip-id uint)
        (new-owner principal)
        (price uint)
    )
    (let (
            (ip-data (unwrap! (map-get? intellectual-property { id: ip-id }) ERR-NOT-FOUND))
            (current-height burn-block-height)
        )
        (asserts! (is-eq tx-sender (get owner ip-data)) ERR-NOT-AUTHORIZED)
        (asserts! (get is-active ip-data) ERR-EXPIRED)
        (asserts! (< current-height (get expiry-date ip-data)) ERR-EXPIRED)
        (asserts! (not (is-eq tx-sender new-owner)) ERR-INVALID-PARAMS)

        (if (> price u0)
            (try! (stx-transfer? price new-owner tx-sender))
            true
        )

        (map-set intellectual-property { id: ip-id }
            (merge ip-data { owner: new-owner })
        )

        (let ((transfer-id (get-transfer-count ip-id)))
            (map-set ip-ownership-history {
                ip-id: ip-id,
                transfer-id: transfer-id,
            } {
                from: tx-sender,
                to: new-owner,
                timestamp: current-height,
                price: price,
            })
            (map-set transfer-counters { ip-id: ip-id } { count: (+ transfer-id u1) })
        )

        (map-set user-ip-count { user: tx-sender } { count: (- (get-user-ip-count tx-sender) u1) })

        (map-set user-ip-count { user: new-owner } { count: (+ (get-user-ip-count new-owner) u1) })

        (ok true)
    )
)

(define-public (purchase-license
        (ip-id uint)
        (license-type (string-ascii 32))
        (duration-months uint)
        (terms (string-ascii 256))
    )
    (let (
            (ip-data (unwrap! (map-get? intellectual-property { id: ip-id }) ERR-NOT-FOUND))
            (current-height burn-block-height)
            (end-height (+ current-height (* duration-months u4320)))
            (total-fee (* (get base-license-fee ip-data) duration-months))
            (platform-fee (/ (* total-fee (var-get platform-fee-rate)) u10000))
            (owner-fee (- total-fee platform-fee))
        )
        (asserts! (get licensing-enabled ip-data) ERR-NOT-AUTHORIZED)
        (asserts! (get is-active ip-data) ERR-EXPIRED)
        (asserts! (< current-height (get expiry-date ip-data)) ERR-EXPIRED)
        (asserts! (> duration-months u0) ERR-INVALID-PARAMS)
        (asserts! (>= (stx-get-balance tx-sender) total-fee)
            ERR-INSUFFICIENT-PAYMENT
        )
        (asserts!
            (is-none (map-get? licenses {
                licensee: tx-sender,
                ip-id: ip-id,
            }))
            ERR-ALREADY-EXISTS
        )

        (try! (stx-transfer? owner-fee tx-sender (get owner ip-data)))
        (try! (stx-transfer? platform-fee tx-sender CONTRACT-OWNER))

        (map-set licenses {
            licensee: tx-sender,
            ip-id: ip-id,
        } {
            license-type: license-type,
            start-date: current-height,
            end-date: end-height,
            fee-paid: total-fee,
            terms: terms,
            is-active: true,
        })

        (let ((current-revenue (default-to {
                total-earned: u0,
                license-count: u0,
            }
                (map-get? license-revenue { ip-id: ip-id })
            )))
            (map-set license-revenue { ip-id: ip-id } {
                total-earned: (+ (get total-earned current-revenue) owner-fee),
                license-count: (+ (get license-count current-revenue) u1),
            })
        )

        (ok true)
    )
)

(define-public (revoke-license
        (licensee principal)
        (ip-id uint)
    )
    (let (
            (ip-data (unwrap! (map-get? intellectual-property { id: ip-id }) ERR-NOT-FOUND))
            (license-data (unwrap!
                (map-get? licenses {
                    licensee: licensee,
                    ip-id: ip-id,
                })
                ERR-NOT-FOUND
            ))
        )
        (asserts! (is-eq tx-sender (get owner ip-data)) ERR-NOT-AUTHORIZED)
        (asserts! (get is-active license-data) ERR-EXPIRED)

        (map-set licenses {
            licensee: licensee,
            ip-id: ip-id,
        }
            (merge license-data { is-active: false })
        )

        (ok true)
    )
)

(define-public (deactivate-ip (ip-id uint))
    (let ((ip-data (unwrap! (map-get? intellectual-property { id: ip-id }) ERR-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get owner ip-data)) ERR-NOT-AUTHORIZED)

        (map-set intellectual-property { id: ip-id }
            (merge ip-data { is-active: false })
        )

        (ok true)
    )
)

(define-public (update-license-fee
        (ip-id uint)
        (new-fee uint)
    )
    (let ((ip-data (unwrap! (map-get? intellectual-property { id: ip-id }) ERR-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get owner ip-data)) ERR-NOT-AUTHORIZED)
        (asserts! (> new-fee u0) ERR-INVALID-PARAMS)

        (map-set intellectual-property { id: ip-id }
            (merge ip-data { base-license-fee: new-fee })
        )

        (ok true)
    )
)

(define-read-only (get-ip-details (ip-id uint))
    (map-get? intellectual-property { id: ip-id })
)

(define-read-only (get-license-details
        (licensee principal)
        (ip-id uint)
    )
    (map-get? licenses {
        licensee: licensee,
        ip-id: ip-id,
    })
)

(define-read-only (get-ip-revenue (ip-id uint))
    (default-to {
        total-earned: u0,
        license-count: u0,
    }
        (map-get? license-revenue { ip-id: ip-id })
    )
)

(define-read-only (get-user-ip-count (user principal))
    (get count (default-to { count: u0 } (map-get? user-ip-count { user: user })))
)

(define-read-only (is-license-valid
        (licensee principal)
        (ip-id uint)
    )
    (match (map-get? licenses {
        licensee: licensee,
        ip-id: ip-id,
    })
        license-data (and
            (get is-active license-data)
            (< burn-block-height (get end-date license-data))
        )
        false
    )
)

(define-read-only (get-current-ip-id)
    (- (var-get next-ip-id) u1)
)

(define-read-only (get-platform-fee-rate)
    (var-get platform-fee-rate)
)

(define-private (get-transfer-count (ip-id uint))
    (get count
        (default-to { count: u0 } (map-get? transfer-counters { ip-id: ip-id }))
    )
)
