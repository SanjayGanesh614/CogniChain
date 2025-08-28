;; ai-marketplace-test.clar

(use-trait nft-trait 'SP3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.ai-model)

(define-test test-list-model
  (let
    (
      ;; Call list-model as contract deployer (sender)
      (response (call-function! .ai-marketplace.list-model u1000 none))
      
      ;; The expected next token id (first minted token)
      (token-id u0)
      
      ;; Query model details after listing
      (details (map-get? .ai-marketplace.model-details ((token-id token-id))))
    )
    ;; Assert listing succeeded
    (asserts! (ok? response) "Listing failed")
    
    ;; Assert token id matches
    (asserts! (is-eq response token-id) "Token ID mismatch")
    
    ;; Check model details are stored
    (asserts! (is-some details) "Model details not found")
    
    ;; Check price stored is u1000
    (asserts! (is-eq (get price (unwrap! details (err "No details"))) u1000) "Price mismatch")
  )
)

(define-test test-purchase-model
  (let
    (
      ;; First list model tokenId u0 by contract-deployer (sender)
      (_ (call-function! .ai-marketplace.list-model u1000 none))
      
      ;; Purchase as different user (deployer2)
      (buyer (get-caller 'deployer2))
      
      ;; Transfer STX amount must be attached when calling purchase-model
      ;; Clarinet simulates this with 'principal' and 'stx-transfer-amount'
      ;; Sadly, Clarinet can't simulate native token transfers directly, so test is limited
      
      ;; Call purchase-model
      (response (call-function! .ai-marketplace.purchase-model u0 'deployer2))
      
      ;; Get updated model details
      (details (map-get? .ai-marketplace.model-details ((token-id u0))))
      
      ;; Owner of NFT
      (owner (get-call-result (nft-trait-get-owner 'SP3J2GVMMM2R07ZFBJDWTYEYAR8FZH5WKDTFJ9AHA.ai-model u0)))
    )
    ;; Assert purchase call succeeded
    (asserts! (ok? response) "Purchase failed")

    ;; Assert listing is now false
    (asserts! (is-eq (get is-listed  (unwrap! details (err "No details"))) false) "Listing status not updated")
    
    ;; Check token owner has changed to buyer
    (asserts! (is-eq owner buyer) "Ownership transfer failed")
  )
)
