# Automated Royalty Distribution for Secondary IP Sales

## Overview
Enables original creators to earn perpetual royalties from secondary market transactions of their intellectual property assets. When IP ownership transfers occur after the initial sale, a configurable percentage automatically flows to the original creator while the seller receives the remainder.

## Key Features

**Royalty Configuration**
- Creators set royalty percentages (0-20%) for their registered IP
- Default royalty rate of 10% applied at registration
- Only original creators can modify their IP's royalty terms

**Automatic Collection**
- Royalties automatically calculated and held during ownership transfers
- Smart contract escrows funds until creator withdrawal
- Primary sales (creator → buyer) exempt from royalties
- Secondary sales trigger automatic royalty distribution

**Transparent Tracking**
- Real-time royalty balance queries for creators
- Historical royalty statistics per IP asset
- Total collected and withdrawal count metrics

**Flexible Withdrawals**
- Creators withdraw accumulated royalties anytime
- Single transaction pulls all pending royalties
- Zero balance protection prevents empty withdrawals

## Technical Implementation

**New Data Structures**
- `royalty-balances`: Tracks pending royalties per creator
- `total-royalties-by-ip`: Historical royalty stats per IP
- `original-creator`: Preserves creator identity across transfers
- `royalty-percentage`: Configurable rate per IP (basis points)

**Enhanced Functions**
- `transfer-ownership`: Modified to calculate and escrow royalties
- `set-royalty-percentage`: Creators configure their royalty rate
- `withdraw-royalties`: Pull accumulated royalties
- `get-royalty-balance`: Query pending royalties
- `get-ip-royalty-stats`: Historical data per IP

**Constants**
- `MAX-ROYALTY-PERCENTAGE`: 2000 (20%)
- `DEFAULT-ROYALTY-PERCENTAGE`: 1000 (10%)
- `ERR-NO-ROYALTY-BALANCE`: 403

## Value Proposition
This feature aligns with NFT and digital asset standards where creators deserve ongoing compensation for their work's continued value. It incentivizes high-quality IP creation, establishes sustainable creator economics, and differentiates this platform with built-in creator protection.

## Validation
✅ Contract passes `clarinet check` with zero errors
✅ All variables properly initialized
✅ Royalty calculations use safe arithmetic
✅ Transfer logic preserves backward compatibility
✅ Creator rights enforced through authorization checks
