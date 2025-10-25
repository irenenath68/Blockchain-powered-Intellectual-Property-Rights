# 📜 Blockchain-powered Intellectual Property Rights

A comprehensive smart contract system for registering, managing, and licensing intellectual property on the Stacks blockchain.

## ✨ Features

- 🔐 **IP Registration**: Secure registration of intellectual property with cryptographic hashes
- 🔄 **Ownership Transfer**: Transfer IP ownership with payment tracking
- 🎯 **Licensing System**: Purchase and manage IP licenses with revenue sharing
- 📊 **Revenue Tracking**: Monitor licensing revenue and usage statistics
- ⏰ **Expiration Management**: Time-based IP validity and license duration
- 🛡️ **Access Control**: Owner-only functions for IP management

## 🚀 Quick Start

### Register Intellectual Property

```clarity
(contract-call? .ipr register-ip
  "My Innovation"
  "Revolutionary new technology"
  "patent"
  u5  ;; 5 years validity
  "sha256hash..."
  true  ;; enable licensing
  u1000000  ;; license fee per month
)
```

### Purchase a License

```clarity
(contract-call? .ipr purchase-license
  u1  ;; IP ID
  "commercial"
  u12  ;; 12 months
  "Standard commercial license terms"
)
```

### Transfer Ownership

```clarity
(contract-call? .ipr transfer-ownership
  u1  ;; IP ID
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7  ;; new owner
  u5000000  ;; sale price
)
```

## 📋 Core Functions

### Public Functions

| Function | Description |
|----------|-------------|
| `register-ip` | Register new intellectual property |
| `transfer-ownership` | Transfer IP to new owner |
| `purchase-license` | Buy license for existing IP |
| `revoke-license` | Revoke active license (owner only) |
| `deactivate-ip` | Deactivate IP registration (owner only) |
| `update-license-fee` | Update licensing fee (owner only) |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-ip-details` | Retrieve IP information |
| `get-license-details` | Get license information |
| `get-ip-revenue` | View IP licensing revenue |
| `is-license-valid` | Check license validity |
| `get-user-ip-count` | Count user's registered IPs |

## 💰 Fee Structure

- **Registration Fee**: 1 STX base + 0.5 STX per year of validity
- **Platform Fee**: 5% of licensing transactions
- **Minimum License Fee**: Set by IP owner

## 🔧 Development

### Testing

```bash
clarinet check
npm install
npm test
```

### Deployment

```bash
clarinet deploy --network testnet
```

## 📁 Project Structure

```
├── contracts/
│   └── ipr.clar           # Main IP rights contract
├── tests/
│   └── ipr.test.ts        # Contract tests
├── Clarinet.toml          # Project configuration
└── README.md              # This file
```


## 📄 License

MIT License - see LICENSE file for details

