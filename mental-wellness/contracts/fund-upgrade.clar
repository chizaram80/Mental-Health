;; Mental Health Support Fund Smart Contract
;; Handles donations, fund distribution, and beneficiary management

;; Error Constants
(define-constant ERROR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERROR-BENEFICIARY-ALREADY-EXISTS (err u101))
(define-constant ERROR-BENEFICIARY-NOT-FOUND (err u102))
(define-constant ERROR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERROR-DONATION-BELOW-MINIMUM (err u104))
(define-constant ERROR-CONTRACT-INACTIVE (err u105))

;; Data Variables
(define-data-var contract-administrator principal tx-sender)
(define-data-var total-available-funds uint u0)
(define-data-var contract-operational-status bool true)
(define-data-var minimum-donation-threshold uint u1000000) ;; 1 STX
(define-data-var emergency-shutdown-status bool false)

;; Data Maps
(define-map mental-health-beneficiaries 
    principal 
    {
        beneficiary-active: bool,
        total-support-received: uint,
        previous-disbursement-block: uint,
        beneficiary-current-status: (string-ascii 20)
    }
)

(define-map support-fund-donors
    principal
    {
        lifetime-donation-amount: uint,
        most-recent-donation-block: uint
    }
)

;; Read-only functions
(define-read-only (get-administrator)
    (var-get contract-administrator)
)

(define-read-only (get-available-funds)
    (var-get total-available-funds)
)

(define-read-only (get-beneficiary-details (beneficiary-address principal))
    (map-get? mental-health-beneficiaries beneficiary-address)
)

(define-read-only (get-donor-details (donor-address principal))
    (map-get? support-fund-donors donor-address)
)

(define-read-only (check-contract-status)
    (and (var-get contract-operational-status) (not (var-get emergency-shutdown-status)))
)

;; Private functions
(define-private (verify-administrator-access)
    (is-eq tx-sender (var-get contract-administrator))
)

(define-private (update-donor-records (donor-address principal) (donation-amount uint))
    (let (
        (existing-donor-info (default-to 
            { lifetime-donation-amount: u0, most-recent-donation-block: u0 } 
            (map-get? support-fund-donors donor-address)
        ))
    )
    (map-set support-fund-donors
        donor-address
        {
            lifetime-donation-amount: (+ (get lifetime-donation-amount existing-donor-info) donation-amount),
            most-recent-donation-block: block-height
        }
    ))
)

;; Public functions
(define-public (submit-donation)
    (let (
        (donation-amount (stx-get-balance tx-sender))
    )
    (asserts! (>= donation-amount (var-get minimum-donation-threshold)) ERROR-DONATION-BELOW-MINIMUM)
    (asserts! (check-contract-status) ERROR-CONTRACT-INACTIVE)
    
    (try! (stx-transfer? donation-amount tx-sender (as-contract tx-sender)))
    (var-set total-available-funds (+ (var-get total-available-funds) donation-amount))
    (update-donor-records tx-sender donation-amount)
    (ok donation-amount))
)

(define-public (add-new-beneficiary (beneficiary-address principal))
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (asserts! (is-none (map-get? mental-health-beneficiaries beneficiary-address)) ERROR-BENEFICIARY-ALREADY-EXISTS)
        
        (map-set mental-health-beneficiaries 
            beneficiary-address
            {
                beneficiary-active: true,
                total-support-received: u0,
                previous-disbursement-block: u0,
                beneficiary-current-status: "active"
            }
        )
        (ok true)
    )
)

(define-public (process-fund-disbursement (beneficiary-address principal) (disbursement-amount uint))
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (asserts! (check-contract-status) ERROR-CONTRACT-INACTIVE)
        (asserts! (>= (var-get total-available-funds) disbursement-amount) ERROR-INSUFFICIENT-BALANCE)
        (asserts! 
            (is-some (map-get? mental-health-beneficiaries beneficiary-address)) 
            ERROR-BENEFICIARY-NOT-FOUND
        )
        
        (try! (as-contract (stx-transfer? disbursement-amount tx-sender beneficiary-address)))
        (var-set total-available-funds (- (var-get total-available-funds) disbursement-amount))
        
        (let (
            (beneficiary-record (unwrap! (map-get? mental-health-beneficiaries beneficiary-address) ERROR-BENEFICIARY-NOT-FOUND))
        )
        (map-set mental-health-beneficiaries
            beneficiary-address
            {
                beneficiary-active: (get beneficiary-active beneficiary-record),
                total-support-received: (+ (get total-support-received beneficiary-record) disbursement-amount),
                previous-disbursement-block: block-height,
                beneficiary-current-status: (get beneficiary-current-status beneficiary-record)
            }
        )
        (ok disbursement-amount))
    )
)

;; Administrative functions
(define-public (update-minimum-donation-requirement (new-minimum-amount uint))
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (var-set minimum-donation-threshold new-minimum-amount)
        (ok true)
    )
)

(define-public (toggle-operational-status)
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (var-set contract-operational-status (not (var-get contract-operational-status)))
        (ok true)
    )
)

(define-public (activate-emergency-shutdown)
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (var-set emergency-shutdown-status true)
        (ok true)
    )
)

(define-public (deactivate-emergency-shutdown)
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (var-set emergency-shutdown-status false)
        (ok true)
    )
)

(define-public (update-beneficiary-status-record (beneficiary-address principal) (new-status-value (string-ascii 20)))
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (asserts! 
            (is-some (map-get? mental-health-beneficiaries beneficiary-address)) 
            ERROR-BENEFICIARY-NOT-FOUND
        )
        
        (let (
            (current-beneficiary-record (unwrap! (map-get? mental-health-beneficiaries beneficiary-address) ERROR-BENEFICIARY-NOT-FOUND))
        )
        (map-set mental-health-beneficiaries
            beneficiary-address
            {
                beneficiary-active: (get beneficiary-active current-beneficiary-record),
                total-support-received: (get total-support-received current-beneficiary-record),
                previous-disbursement-block: (get previous-disbursement-block current-beneficiary-record),
                beneficiary-current-status: new-status-value
            }
        )
        (ok true))
    )
)

;; Transfer ownership
(define-public (transfer-administrator-rights (new-administrator principal))
    (begin
        (asserts! (verify-administrator-access) ERROR-UNAUTHORIZED-ACCESS)
        (var-set contract-administrator new-administrator)
        (ok true)
    )
)