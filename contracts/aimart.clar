;; SPDX-License-Identifier: MIT
;; Clarity contract implementing a simplified AI model NFT marketplace

;; Import the standard non-fungible token (NFT) trait
;; This provides the basic NFT interface with minting, transferring, and querying owners.
(define-non-fungible-token ai-model uint)

;; Map token IDs to their listing details
;; Store price, creator principal, payment token (optional), and listing status
(define-map model-details
  ((token-id uint)) ;; key is token ID
  (
    (price uint) ;; price in microstx or fungible token smallest units
    (creator principal) ;; principal of the creator who owns this model
    (payment-token (optional principal)) ;; token to pay with, None means STX
    (is-listed bool) ;; is the model currently listed for sale
  )
)

;; Counter for next token ID to mint
(define-data-var next-token-id uint u0)

;; Platform fee in percentage points (5%)
(define-constant platform-fee 5)

;; Event indicating a new model has been listed
(define-event model-listed (token-id uint) (price uint) (creator principal) (payment-token (optional principal)))

;; Event indicating a model has been purchased
(define-event model-purchased (token-id uint) (price uint) (buyer principal) (payment-token (optional principal)))

;; Function to get the contract owner (deployer)
(define-read-only (get-contract-owner)
  (contract-owner)
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
      nft-success
        (begin
          ;; Store model details for this token id
          (map-set model-details ((token-id token-id))
                   (
                     (price price)
                     (creator sender)
                     (payment-token payment-token)
                     (is-listed true)
                   ))
          ;; Increment token ID for next mint
          (var-set next-token-id (+ token-id u1))
          ;; Emit event for listing
          (emit-event (model-listed token-id price sender payment-token))
          (ok token-id)
        )
      nft-failed
        (err nft-failed)
    )
  )
)

;; Purchase a listed model NFT
;; Buyer pays with {payment-token} if specified, else with STX.
;; Transfers NFT ownership and updates listing status.
(define-public (purchase-model (token-id uint))
  (let (
        (buyer tx-sender)
        (model (map-get? model-details ((token-id token-id))))
       )
    (match model
      none (err u404) ;; Model not found
      (some detail
        (begin
          (asserts! (get is-listed detail) (err u405)) ;; Must be listed

          ;; Calculate platform fee and creator payment
          (let (
                (price (get price detail))
                (creator (get creator detail))
                (payment-token (get payment-token detail))
                (platform-cut (/ (* price platform-fee) u100))
                (creator-cut (- price platform-cut))
               )
            ;; Transfer funds
            (match payment-token
              none
                ;; Payment in STX (native coin)
                (begin
                  ;; Contract expects STX to be sent with this call; check amount
                  (asserts! (is-eq (stx-get-transfer-amount) price) (err u406))
                  ;; Transfer STX to creator
                  (stx-transfer? creator-cut buyer creator)
                  ;; Platform keeps fee automatically as STX in contract balance
                )
              some token
                ;; Payment by Fungible Token (not implemented detailed here)
                (begin
                  ;; Buyer must have approved this contract to spend tokens
                  ;; Call FT transferFrom from buyer to creator with creator-cut
                  ;; Call FT transferFrom from buyer to contract for platform-cut
                  ;; This requires calling external FT contract, 
                  ;; which is more complex and omitted for brevity.
                  ;; Return error for now.
                  (err u407)
                )
            )

            ;; Transfer NFT ownership from creator to buyer
            (nft-transfer? ai-model token-id buyer creator)

            ;; Mark as no longer listed
            (map-set model-details ((token-id token-id)) (merge detail {is-listed: false}))

            ;; Emit purchase event
            (emit-event (model-purchased token-id price buyer payment-token))

            (ok true)
          )
        )
      )
    )
  )
)

;; Read-only function to get model details
(define-read-only (get-model-details (token-id uint))
  (map-get? model-details ((token-id token-id)))
)

;; Allow contract to receive STX payments (fees)
(define-public (withdraw-fees (recipient principal))
  (begin
    ;; Only contract owner can withdraw accumulated STX in contract balance
    (asserts! (is-eq tx-sender (contract-owner)) (err u403))
    (ok (stx-transfer? (stx-get-balance) (as-contract) recipient))
  )
)
