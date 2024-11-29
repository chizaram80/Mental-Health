# Mental Health Support Fund Smart Contract

## About
The Mental Health Support Fund Smart Contract is a decentralized application built on the Stacks blockchain using Clarity. It facilitates the collection and distribution of funds for mental health support, managing beneficiaries, tracking donations, and ensuring transparent fund management.

## Features
- **Donation Management**: Secure handling of STX token donations with minimum threshold
- **Beneficiary System**: Registration and management of mental health support recipients
- **Fund Distribution**: Controlled disbursement of funds to registered beneficiaries
- **Donor Tracking**: Comprehensive recording of donation history
- **Administrative Controls**: Robust contract management and emergency features
- **Transparency**: Public access to fund statistics and beneficiary information

## Contract Functions

### Public Read Functions
1. `get-administrator`
   - Returns the current contract administrator's address
   - No parameters required

2. `get-available-funds`
   - Returns the total available funds in the contract
   - No parameters required

3. `get-beneficiary-details (beneficiary-address principal)`
   - Returns detailed information about a specific beneficiary
   - Parameters:
     - `beneficiary-address`: Principal address of the beneficiary

4. `get-donor-details (donor-address principal)`
   - Returns donation history for a specific donor
   - Parameters:
     - `donor-address`: Principal address of the donor

5. `check-contract-status`
   - Returns the current operational status of the contract
   - No parameters required

### Public Write Functions

#### Donation Functions
1. `submit-donation`
   - Accepts STX donations to the fund
   - Minimum donation threshold applies
   - Returns success/failure status

#### Beneficiary Management
1. `add-new-beneficiary (beneficiary-address principal)`
   - Registers a new beneficiary
   - Admin only function
   - Parameters:
     - `beneficiary-address`: Principal address of the new beneficiary

2. `update-beneficiary-status-record (beneficiary-address principal) (new-status-value string-ascii)`
   - Updates beneficiary status
   - Admin only function
   - Parameters:
     - `beneficiary-address`: Principal address of the beneficiary
     - `new-status-value`: New status to be set

#### Fund Distribution
1. `process-fund-disbursement (beneficiary-address principal) (disbursement-amount uint)`
   - Disburses funds to beneficiaries
   - Admin only function
   - Parameters:
     - `beneficiary-address`: Recipient's address
     - `disbursement-amount`: Amount to be disbursed

#### Administrative Functions
1. `update-minimum-donation-requirement (new-minimum-amount uint)`
   - Updates minimum donation threshold
   - Admin only function
   - Parameters:
     - `new-minimum-amount`: New minimum donation amount

2. `toggle-operational-status`
   - Toggles contract operational status
   - Admin only function

3. `activate-emergency-shutdown`
   - Initiates emergency shutdown
   - Admin only function

4. `deactivate-emergency-shutdown`
   - Deactivates emergency shutdown
   - Admin only function

5. `transfer-administrator-rights (new-administrator principal)`
   - Transfers contract administration rights
   - Admin only function
   - Parameters:
     - `new-administrator`: Address of the new administrator

## Error Codes
- `ERROR-UNAUTHORIZED-ACCESS (u100)`: Unauthorized access attempt
- `ERROR-BENEFICIARY-ALREADY-EXISTS (u101)`: Duplicate beneficiary registration
- `ERROR-BENEFICIARY-NOT-FOUND (u102)`: Beneficiary not registered
- `ERROR-INSUFFICIENT-BALANCE (u103)`: Insufficient funds for disbursement
- `ERROR-DONATION-BELOW-MINIMUM (u104)`: Donation below minimum threshold
- `ERROR-CONTRACT-INACTIVE (u105)`: Contract currently inactive

## Security Features
1. **Access Control**
   - Administrative functions restricted to contract administrator
   - Role-based access control for sensitive operations

2. **Fund Safety**
   - Emergency shutdown capability
   - Minimum donation thresholds
   - Balance checks before disbursement

3. **Transparency**
   - Public tracking of all transactions
   - Verifiable beneficiary statuses
   - Donor contribution history

## Usage Examples

### Making a Donation
```clarity
;; Submit a donation
(contract-call? .mental-health-fund submit-donation)
```

### Registering a Beneficiary (Admin Only)
```clarity
;; Register new beneficiary
(contract-call? .mental-health-fund add-new-beneficiary 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Disbursing Funds (Admin Only)
```clarity
;; Process fund disbursement
(contract-call? .mental-health-fund process-fund-disbursement 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u1000000)
```

## Best Practices
1. Always verify contract status before interactions
2. Maintain secure administrator key management
3. Regular monitoring of fund disbursements
4. Periodic review of beneficiary statuses
5. Keep emergency contact information updated