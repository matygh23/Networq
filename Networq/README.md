# Networq

**Networq** is a decentralized professional networking smart contract built on the Stacks blockchain using Clarity. It allows users to create verifiable on-chain professional profiles, issue and endorse credentials, and form authenticated peer-to-peer connections.

## 🚀 Features

- **Decentralized Profiles**: Users can create and update professional profiles with name, title, and bio stored on-chain.
- **On-Chain Credentials**: Add and manage credentials issued by organizations or individuals, including verification status.
- **Peer Verification**: Credentials can be verified by a designated third party.
- **Skill Endorsements**: Users can endorse one another for specific skills with optional comments.
- **Trusted Connections**: Users can connect with others in a verified, mutual fashion—similar to "friends" or "connections".
- **Tamper-Proof Reputation**: All actions are recorded immutably, ensuring integrity and transparency.

## 📦 Smart Contract Structure

- **Profiles Map**: Stores user profiles with metadata.
- **Credentials Map**: Contains verifiable credentials tied to users.
- **Endorsements Map**: Skill endorsements between users with timestamp and comment.
- **Connections Map**: Bi-directional connection relationships between users.

## 📘 Functions

### Public Functions

| Function | Description |
|---------|-------------|
| `create-profile` | Create a new user profile |
| `update-profile` | Update existing profile |
| `add-credential` | Add a new professional credential |
| `verify-credential` | Verify a credential (requires permission) |
| `endorse-skill` | Endorse a user for a skill |
| `connect-user` | Form a mutual connection between users |

### Read-Only Functions

| Function | Description |
|----------|-------------|
| `get-profile` | Retrieve user profile data |
| `get-credential` | Fetch credential by ID |
| `are-connected` | Check if two users are connected |
| `get-endorsement` | Retrieve endorsement details |
| `is-credential-verified` | Check credential verification status |
| `get-next-credential-id` | Get latest credential ID (frontend use) |

## 🔐 Access Control & Errors

| Constant | Error Description |
|----------|-------------------|
| `err-owner-only (u100)` | Action requires contract owner |
| `err-not-found (u101)` | Resource not found |
| `err-already-exists (u102)` | Resource already exists |
| `err-unauthorized (u103)` | User not authorized |

## 💡 Use Cases

- **Decentralized LinkedIn**
- **Web3-based Resume Verification**
- **Skill endorsement and talent discovery**
- **On-chain proof of credentials for DAOs or communities**
