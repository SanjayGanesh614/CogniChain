# AI Model Marketplace with Clarity on Stacks

### Project for Our Build with Stacks Hackathon

---

## Introduction

This is our decentralized AI Model Marketplace project built on the **Stacks** blockchain, using the **Clarity** smart contract language and **IPFS** for decentralized storage. It enables AI developers to mint, list, and sell AI models as NFTs securely and transparently. Buyers can purchase and access models on-chain with guaranteed ownership rights.

---

## Project Overview

* **Blockchain:** Stacks (Smart contracts written in Clarity)
* **Storage:** IPFS (for hosting large AI model files off-chain)
* **Wallet:** Leather Wallet (for signing and managing transactions)

Our marketplace leverages blockchain immutability for ownership and payment while IPFS provides decentralized file storage, creating a trustless system for AI model commerce.

---

## Architecture & Components

### 1. Smart Contract (Clarity)

* Defines an NFT representing AI models via SIP-009 standard.
* Stores model details: price, creator, payment token, listing status.
* Allows minting (`list-model`), purchasing (`purchase-model`), ownership transfer, and listing toggling.
* Manages platform fee and payments in STX (native token).

### 2. IPFS Storage

* AI models are uploaded to IPFS via Web3.Storage.
* Files receive a **CID** (content identifier), a unique hash to fetch model files.
* Metadata JSON points to the IPFS CID, stored off-chain but linked on-chain by NFTs.

### 3. Backend (Node.js)

* API to handle file uploads from users.
* Pins files to IPFS and returns CID.
* Calls Clarity contract functions using Stacks.js and private key to mint/list NFTs.
* API endpoint example: `/api/upload-model` accepts uploaded model file + price data.

### 4. Frontend (React or similar)

* Connects Leather Wallet for user authentication and transaction signing.
* Interfaces with backend APIs to upload models.
* Displays marketplace listings and enables purchases.
* Checks NFT ownership to gate model downloads.

---

## How to Develop & Test Locally

1.  **Setup Clarinet Project**
    * Use `clarinet new` to create project.
    * Write your Clarity contract (`ai-marketplace.clar`) under `/contracts`.
2.  **Compile & Check**
    ```
    clarinet check
    ```
    * Validates syntax.
3.  **Write Automated Tests** (under `/tests`)
    ```
    clarinet test
    ```
    * Runs your Clarity contract test suites.
4.  **Run Interactive Local Blockchain**
    ```
    clarinet console
    ```
    * Manually call contract functions, simulate transactions and inspect state.

---

## Deploying to Stacks Testnet

1.  Go to [Stacks Explorer](https://explorer.stacks.co/) and switch to **Testnet**.
2.  Connect your **Leather Wallet** configured for testnet.
3.  Open “Write & Deploy Contracts” tab.
4.  Paste your Clarity contract code and give it a unique name.
5.  Deploy and sign transaction via Leather Wallet popup.
6.  Wait for confirmation and get your contract principal address.

---

## Backend Setup & Usage

* Use Node.js backend with Express to handle model uploads and blockchain calls.
* Upload files to IPFS using Web3.Storage API.
* Call smart contract `list-model()` to mint NFT using Stacks.js SDK and backend signer.
* API endpoint example: `/api/upload-model` accepts uploaded model file + price data.

---

## Testing & Interacting

* Use Postman or curl to test backend API endpoints locally.
* Use `clarinet console` for local contract interaction and debugging.
* Use frontend connected with Leather Wallet to interact live on testnet.

---

## Important Commands

| Command | Description |
| :--- | :--- |
| `clarinet check` | Compile and lint Clarity contracts |
| `clarinet test` | Run Clarity test suites |
| `clarinet console` | Interactive environment to manually test |
| Wallet + Explorer | Deploy contract on Stacks testnet/mainnet |

---

## Summary

This project offers a **fully decentralized, scalable AI model marketplace** with secure NFT ownership on Stacks and decentralized model storage on IPFS. It leverages modern web3 tools like Clarity, Leather Wallet, and Web3.Storage to deliver a trustless platform for AI developers and consumers.

We built this for the **Build with Stacks Hackathon**, showcasing innovation at the intersection of AI, blockchain, and decentralized storage.

---

## Learn More & Resources

* [Clarinet Documentation](https://docs.clarinet.io/)
* [Stacks Explorer](https://explorer.stacks.co/)
* [Leather Wallet](https://leatherwallet.com/)
* [Web3.Storage](https://web3.storage/)
* [Stacks.js SDK](https://docs.blockstack.org/stacks-blockchain/api-reference/javascript)

---

*Feel free to reach out for help with integration, deployment, or extending this project!*
