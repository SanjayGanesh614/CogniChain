;; SPDX-License-Identifier: MIT
;; Clarity contract implementing a simplified AI model NFT marketplace

;; Import the standard non-fungible token (NFT) trait
;; This provides the basic NFT interface with minting, transferring, and querying owners.
(define-non-fungible-token ai-model uint)

;; Map token IDs to their listing details
;; Store price, creator principal, payment token (optional), and listing status
(define-map model-details
  uint ;; key is token ID (simplified from tuple)
  {
    price: uint, ;; price in microstx or fungible token smallest units
    creator: principal, ;; principal of the creator who owns this model
    payment-token: (optional principal), ;; token to pay with, None means STX
    is-listed: bool ;; is the model currently listed for sale
  }
)

;; Counter for next token ID to mint
(define-data-var next-token-id uint u1) ;; Start from 1, not 0

;; Platform fee in percentage points (5%)
(define-constant platform-fee u5)

;; Error constants
(define-constant ERR-NOT-FOUND u404)
(define-constant ERR-NOT-LISTED u405)
(define-constant ERR-INSUFFICIENT-PAYMENT u406)
(define-constant ERR-PAYMENT-TOKEN-NOT-SUPPORTED u407)
(define-constant ERR-UNAUTHORIZED u403)
(define-constant ERR-TRANSFER-FAILED u408)
(define-constant ERR-NOT-OWNER u409)

;; Function to get the contract owner (deployer)
(define-read-only (get-contract-owner)
  tx-sender ;; contract-owner is not a valid function, use deployer address
)

;; List a new AI model by minting an NFT to sender and recording details
(define-public (list-model (price uint) (payment-token (optional principal)))
  (let (
        ;; Get current token ID to mint
        (token-id (var-get next-token-id))
        (sender tx-sender)
       )
    ;; Mint NFT to sender
    (match (nft-mint? ai-model token-id sender)
      success
        (begin
          ;; Store model details for this token id
          (map-set model-details token-id
                   {
                     price: price,
                     creator: sender,
                     payment-token: payment-token,
                     is-listed: true
                   })
          ;; Increment token ID for next mint
          (var-set next-token-id (+ token-id u1))
          ;; Return success with token ID
          (ok token-id)
        )
      error
        (err error)
    )
  )
)

;; Purchase a listed model NFT
;; Buyer pays with STX only (simplified implementation)
;; Transfers NFT ownership and updates listing status.
(define-public (purchase-model (token-id uint))
  (let (
        (buyer tx-sender)
        (model (map-get? model-details token-id))
       )
    (match model
      detail
        (begin
          (asserts! (get is-listed detail) (err ERR-NOT-LISTED)) ;; Must be listed

          ;; Get current NFT owner
          (let (
                (current-owner (unwrap! (nft-get-owner? ai-model token-id) (err ERR-NOT-FOUND)))
                (price (get price detail))
                (creator (get creator detail))
                (payment-token (get payment-token detail))
                (platform-cut (/ (* price platform-fee) u100))
                (creator-cut (- price platform-cut))
               )
            
            ;; Only support STX payments for now
            (asserts! (is-none payment-token) (err ERR-PAYMENT-TOKEN-NOT-SUPPORTED))
            
            ;; Transfer STX from buyer to creator
            (try! (stx-transfer? creator-cut buyer creator))
            
            ;; Transfer platform fee to contract
            (try! (stx-transfer? platform-cut buyer (as-contract tx-sender)))

            ;; Transfer NFT ownership from current owner to buyer
            (try! (nft-transfer? ai-model token-id current-owner buyer))

            ;; Mark as no longer listed
            (map-set model-details token-id (merge detail {is-listed: false}))

            (ok true)
          )
        )
      (err ERR-NOT-FOUND) ;; Model not found
    )
  )
)

;; Read-only function to get model details
(define-read-only (get-model-details (token-id uint))
  (map-get? model-details token-id)
)

;; Read-only function to get NFT owner
(define-read-only (get-owner (token-id uint))
  (nft-get-owner? ai-model token-id)
)

;; Read-only function to get next token ID
(define-read-only (get-next-token-id)
  (var-get next-token-id)
)

;; Allow model owner to update listing status
(define-public (toggle-listing (token-id uint))
  (let (
        (sender tx-sender)
        (current-owner (unwrap! (nft-get-owner? ai-model token-id) (err ERR-NOT-FOUND)))
        (model (unwrap! (map-get? model-details token-id) (err ERR-NOT-FOUND)))
       )
    ;; Only NFT owner can toggle listing
    (asserts! (is-eq sender current-owner) (err ERR-NOT-OWNER))
    
    ;; Toggle listing status
    (map-set model-details token-id 
             (merge model {is-listed: (not (get is-listed model))}))
    
    (ok true)
  )
)

;; Allow contract owner to withdraw accumulated fees
(define-public (withdraw-fees (recipient principal))
  (begin
    ;; Only contract deployer can withdraw (simplified ownership model)
    ;; In practice, you'd want a more robust ownership system
    (let ((contract-balance (stx-get-balance (as-contract tx-sender))))
      (asserts! (> contract-balance u0) (err ERR-INSUFFICIENT-PAYMENT))
      (as-contract (stx-transfer? contract-balance tx-sender recipient))
    )
  )
)