IP Rights Registry (Independent Clarity v3 Contract)

Overview
Adds an independent Clarity smart contract that enables proof-of-existence registration of content hashes with owner, title, and registration height. Includes update-title and transfer-ownership with strict error handling.

Technical Implementation
- Contract: contracts/ip-rights.clar
- Key data: map ip-records {(content-hash) -> (owner, registered-at, title)}
- Errors: ERR-ALREADY-REGISTERED u100, ERR-NOT-OWNER u101, ERR-NOT-FOUND u102
- Public functions: register, update-title, transfer-ownership
- Read-only: get-record

Testing & Validation
- ✅ npm test passes (smoke test)
- ✅ CI runs clarinet check via hiro systems container
- ✅ Independent contract (no cross-contract calls or traits)
- ✅ Line endings normalized to LF