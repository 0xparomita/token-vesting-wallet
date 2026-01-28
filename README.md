# Token Vesting Wallet

This repository contains a smart contract to handle the linear vesting of ERC20 tokens. It ensures tokens are locked and only released according to a strict schedule.

## How it Works
1. **Cliff**: A period during which no tokens are released.
2. **Vesting**: After the cliff, tokens are released linearly until the duration ends.
3. **Beneficiary**: Only the assigned address can release the tokens to themselves.

## Formula
`vestedAmount = totalBalance * (currentTime - start) / duration`

## Prerequisites
- Node.js & NPM
- Hardhat

## Setup
1. Clone the repo.
2. Install dependencies:
   ```bash
   npm install
