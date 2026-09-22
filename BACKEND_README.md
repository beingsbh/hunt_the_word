# 🎯 Word Hunt — Backend Architecture & API Specification

> Scalable, modular, offline-first REST API built with **Node.js**, **TypeScript**, **Express.js**, and **MongoDB (Mongoose)**.

**Word Hunt Backend** powers cloud synchronization, authentication, anti-cheat score validation, leaderboard indexing, daily challenge generation, and player progression for the **Word Hunt** Flutter mobile application.

---

## 📋 Table of Contents

- [1. Architecture & Design Principles](#1-architecture--design-principles)
- [2. Technology Stack](#2-technology-stack)
- [3. Project Directory Structure](#3-project-directory-structure)
- [4. Game Economy & Mechanics Rules](#4-game-economy--mechanics-rules)
- [5. MongoDB Collections & Mongoose Schemas](#5-mongodb-collections--mongoose-schemas)
- [6. REST API Specification](#6-rest-api-specification)
- [7. Anti-Cheat & Server-Side Verification](#7-anti-cheat--server-side-verification)
- [8. Offline-to-Online Batch Synchronization](#8-offline-to-online-batch-synchronization)
- [9. Security & Error Handling](#9-security--error-handling)
- [10. Development Setup & Deployment](#10-development-setup--deployment)

---

## 1. Architecture & Design Principles

Word Hunt uses an **offline-first client-server architecture**. The mobile client functions autonomously using local storage (Hive CE), and synchronizes seamlessly with the Node.js API when network connectivity is available.

```text
                           WORD HUNT
                               │
               ┌───────────────┴───────────────┐
               │                               │
          Flutter App                     Node.js API
               │                               │
       ┌───────┴────────┐                      │
       │                │                      │
    Game Engine       Hive                     │
       │             Local DB                  │
       │                                       │
       └─────────────┐                         │
                     │                         │
                     └─────── REST API ────────┘
                                               │
                                               ▼
                                            MongoDB
```

### Core Tenets

1. **Offline-First Resilience**: The client never blocks gameplay on network requests. State is saved locally first, then asynchronously queued for reconciliation.
2. **Feature-Driven Modularity**: Backend code is organized by domain modules (`auth`, `profile`, `levels`, `daily`, `achievements`, `themes`, `sync`, `leaderboard`).
3. **Zero Trust / Anti-Cheat**: All scores, completion times, star thresholds, entry fees, and reward claims are verified server-side.
4. **End-to-End Type Safety**: Data contracts are validated via TypeScript interfaces and runtime Zod schemas.

---

## 2. Technology Stack

| Component | Technology | Purpose |
|---|---|---|
| **Runtime** | Node.js (v20+ LTS) | Asynchronous event-driven JavaScript runtime |
| **Language** | TypeScript (v5+) | Strict type safety and maintainable codebase |
| **Web Framework** | Express.js | High-performance, lightweight HTTP REST framework |
| **Database** | MongoDB | Document database optimized for flexible player profiles & game states |
| **ODM** | Mongoose (v8+) | Schema definition, model validation, and indexing |
| **Validation** | Zod | Runtime request/response payload validation |
| **Authentication** | JWT + Argon2id | Secure token sessions and state-of-the-art password hashing |
| **OAuth** | Firebase Admin SDK | Social login verification (Google, Apple) |
| **Security** | Helmet, CORS, Rate-Limiter | Request sanitization, security headers, and DDoS prevention |
| **Containerization** | Docker & Docker Compose | Multi-container reproducible environments |

---

## 3. Project Directory Structure

```text
backend/
├── src/
│   ├── app.ts                          # Express application configuration & middleware setup
│   ├── server.ts                       # Server bootstrap & graceful shutdown listeners
│   │
│   ├── config/                         # Environment & database connection
│   │   ├── env.ts                      # Zod-validated environment configuration
│   │   ├── database.ts                 # Mongoose connection pooling & lifecycle hooks
│   │   └── firebase.ts                 # Firebase Admin initialization for OAuth
│   │
│   ├── core/                           # Cross-cutting foundational modules
│   │   ├── constants/                  # Game rules, economy costs, and limits
│   │   │   └── game-rules.ts
│   │   ├── errors/                     # Centralized custom error classes
│   │   │   ├── app-error.ts
│   │   │   ├── bad-request-error.ts
│   │   │   ├── unauthorized-error.ts
│   │   │   └── not-found-error.ts
│   │   ├── middlewares/                # Global Express middleware
│   │   │   ├── auth.middleware.ts      # JWT session & Bearer token extraction
│   │   │   ├── validate.middleware.ts  # Zod schema validation middleware
│   │   │   ├── error.middleware.ts     # Global exception handler & formatter
│   │   │   └── rate-limiter.ts         # Endpoint rate limiting & brute-force protection
│   │   └── utils/                      # Shared helper utilities
│   │       ├── api-response.ts         # Standard API response envelope builder
│   │       ├── jwt.ts                  # Token generation and verification
│   │       └── player-tag.ts           # Unique tag generator (e.g. #WH-9824)
│   │
│   ├── modules/                        # Domain feature modules
│   │   ├── auth/                       # Social & Guest Authentication
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.routes.ts
│   │   │   └── auth.validation.ts
│   │   │
│   │   ├── profile/                    # Player Profile, Coins, & Statistics
│   │   │   ├── profile.controller.ts
│   │   │   ├── profile.service.ts
│   │   │   ├── profile.routes.ts
│   │   │   └── profile.validation.ts
│   │   │
│   │   ├── levels/                     # Level Progression, Stars, & High Scores
│   │   │   ├── levels.controller.ts
│   │   │   ├── levels.service.ts
│   │   │   ├── levels.routes.ts
│   │   │   └── levels.validation.ts
│   │   │
│   │   ├── daily/                      # Daily Challenge & Streak Engine
│   │   │   ├── daily.controller.ts
│   │   │   ├── daily.service.ts
│   │   │   ├── daily.routes.ts
│   │   │   └── daily.validation.ts
│   │   │
│   │   ├── achievements/               # Badges & Milestones Tracker
│   │   │   ├── achievements.controller.ts
│   │   │   ├── achievements.service.ts
│   │   │   ├── achievements.routes.ts
│   │   │   └── achievements.validation.ts
│   │   │
│   │   ├── themes/                     # Theme Store & Cosmetic Inventory
│   │   │   ├── themes.controller.ts
│   │   │   ├── themes.service.ts
│   │   │   ├── themes.routes.ts
│   │   │   └── themes.validation.ts
│   │   │
│   │   ├── sync/                       # Offline Hive Batch Reconciliation
│   │   │   ├── sync.controller.ts
│   │   │   ├── sync.service.ts
│   │   │   ├── sync.routes.ts
│   │   │   └── sync.validation.ts
│   │   │
│   │   └── leaderboard/                # Global, Weekly, and Friends Ranking
│   │       ├── leaderboard.controller.ts
│   │       ├── leaderboard.service.ts
│   │       ├── leaderboard.routes.ts
│   │       └── leaderboard.validation.ts
│   │
│   └── routes.ts                       # Top-level API router mounted at /api/v1
│
├── tests/                              # Unit, integration, and e2e test suites
├── .env.example
├── Dockerfile
├── docker-compose.yml
├── package.json
└── tsconfig.json
```

---

## 4. Game Economy & Mechanics Rules

The backend enforces the following exact economy and gameplay rules:

| Category | Parameter | Backend Rule / Value | Description |
|---|---|---|---|
| **Welcome Bonus** | Initial Coin Balance | **500 🪙** | Automatically credited on player registration or guest profile creation. |
| **Hints** | Hint Cost | **5 🪙** | Server validates `profile.coins >= 5` and deducts 5 coins per requested hint. |
| **Campaign Levels** | Base Reward | **+10 🪙** | Awarded on completing a campaign level. |
| **Campaign Levels** | 3-Star Bonus | **+25 🪙** | Awarded when earning 3 stars on a level for the first time. |
| **Mystery Box** | Reward Scaling | **$20 \times 1.5^{n-1}$ 🪙** | Available every 10 levels (Levels 10, 20, 30, 40, ...):<br>• Level 10: **20 🪙**<br>• Level 20: **30 🪙**<br>• Level 30: **45 🪙**<br>• Level 40: **68 🪙** |
| **Daily Challenge** | Entry Stake | **20 🪙** | Requires 20 coins to enter. Deducted immediately upon challenge start. |
| **Daily Challenge** | 3 Stars (★★★) | **$3\times$ Stake = 60 🪙** | Full 3-star victory awards triple the entry fee (net profit: +40 🪙). |
| **Daily Challenge** | 2 Stars (★★☆) | **$2\times$ Stake = 40 🪙** | 2-star victory awards double the entry fee (net profit: +20 🪙). |
| **Daily Challenge** | 1 Star (★☆☆) | **$0\times$ = 0 🪙** | 1-star solve earns 0 coins (stake forfeited; streak still preserved). |
| **Global Level Sync** | Level Reflection | **Strictly Monotonic** | Completing level $L$ advances `currentLevel`, `highestUnlockedLevel`, and `playerLevel`. Progression never regresses when replaying earlier levels. |

---

## 5. MongoDB Collections & Mongoose Schemas

### 5.1. `users` Collection
Stores authentication credentials, device identities, and account state.

```typescript
import { Schema, model, Document } from 'mongoose';

export interface IUser extends Document {
  email?: string;
  passwordHash?: string;
  provider: 'guest' | 'google' | 'apple';
  providerId?: string;
  deviceId?: string;
  refreshToken?: string;
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema = new Schema<IUser>(
  {
    email: { type: String, unique: true, sparse: true, lowercase: true, trim: true },
    passwordHash: { type: String, select: false },
    provider: { type: String, enum: ['guest', 'google', 'apple'], default: 'guest' },
    providerId: { type: String, unique: true, sparse: true },
    deviceId: { type: String, unique: true, sparse: true },
    refreshToken: { type: String, select: false },
  },
  { timestamps: true }
);

export const UserModel = model<IUser>('User', UserSchema);
```

### 5.2. `profiles` Collection
Maintains real-time player statistics, level badges, coin balance, and streak history.

```typescript
export interface IProfile extends Document {
  userId: Schema.Types.ObjectId;
  nickname: string;
  playerTag: string; // e.g. #WH-9824
  playerTitle: string;
  playerLevel: number;
  coins: number;
  totalStars: number;
  currentLevel: number;
  highestUnlockedLevel: number;
  streak: number;
  puzzlesSolved: number;
  wordsFound: number;
  accuracyRate: number;
  bestScore: number;
  selectedTheme: string;
  hasSetUniqueUsername: boolean;
  cloudSaveEnabled: boolean;
}

const ProfileSchema = new Schema<IProfile>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true, index: true },
    nickname: { type: String, default: 'Subha WordMaster', trim: true },
    playerTag: { type: String, required: true, unique: true, index: true },
    playerTitle: { type: String, default: 'Explorer Tier II' },
    playerLevel: { type: Number, default: 1, min: 1 },
    coins: { type: Number, default: 500, min: 0 },
    totalStars: { type: Number, default: 0, min: 0 },
    currentLevel: { type: Number, default: 1, min: 1 },
    highestUnlockedLevel: { type: Number, default: 1, min: 1 },
    streak: { type: Number, default: 0, min: 0 },
    puzzlesSolved: { type: Number, default: 0, min: 0 },
    wordsFound: { type: Number, default: 0, min: 0 },
    accuracyRate: { type: Number, default: 100.0, min: 0, max: 100 },
    bestScore: { type: Number, default: 0, min: 0 },
    selectedTheme: { type: String, default: 'classic' },
    hasSetUniqueUsername: { type: Boolean, default: false },
    cloudSaveEnabled: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const ProfileModel = model<IProfile>('Profile', ProfileSchema);
```

### 5.3. `level_progress` Collection
Tracks individual level completion records, star ratings, and best completion times.

```typescript
export interface ILevelProgress extends Document {
  userId: Schema.Types.ObjectId;
  levelNumber: number;
  worldNumber: number;
  stars: number; // 1, 2, or 3
  score: number;
  bestTime: string; // MM:SS
  isCompleted: boolean;
  mysteryBoxClaimed: boolean;
}

const LevelProgressSchema = new Schema<ILevelProgress>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    levelNumber: { type: Number, required: true, index: true },
    worldNumber: { type: Number, default: 1 },
    stars: { type: Number, default: 0, min: 0, max: 3 },
    score: { type: Number, default: 0 },
    bestTime: { type: String, default: '00:00' },
    isCompleted: { type: Boolean, default: false },
    mysteryBoxClaimed: { type: Boolean, default: false },
  },
  { timestamps: true }
);

LevelProgressSchema.index({ userId: 1, levelNumber: 1 }, { unique: true });
export const LevelProgressModel = model<ILevelProgress>('LevelProgress', LevelProgressSchema);
```

### 5.4. `daily_challenges` Collection
Tracks deterministic daily challenge seeds, player entry fee deductions, and star multiplier payouts.

```typescript
export interface IDailyChallenge extends Document {
  userId: Schema.Types.ObjectId;
  dateKey: string; // YYYY-MM-DD
  enteredAt: Date;
  stakeDeducted: number; // 20
  stars: number; // 1, 2, or 3
  payoutCoins: number; // 60 (3★), 40 (2★), 0 (1★)
  score: number;
  timeSeconds: number;
  isCompleted: boolean;
}

const DailyChallengeSchema = new Schema<IDailyChallenge>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    dateKey: { type: String, required: true, index: true },
    enteredAt: { type: Date, default: Date.now },
    stakeDeducted: { type: Number, default: 20 },
    stars: { type: Number, default: 0, min: 0, max: 3 },
    payoutCoins: { type: Number, default: 0 },
    score: { type: Number, default: 0 },
    timeSeconds: { type: Number, default: 0 },
    isCompleted: { type: Boolean, default: false },
  },
  { timestamps: true }
);

DailyChallengeSchema.index({ userId: 1, dateKey: 1 }, { unique: true });
export const DailyChallengeModel = model<IDailyChallenge>('DailyChallenge', DailyChallengeSchema);
```

---

## 6. REST API Specification

Base URL: `/api/v1`  
All protected endpoints require an `Authorization: Bearer <JWT>` header.

### 6.1. Authentication (`/api/v1/auth`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/auth/register` | Register with email and password (hashed with Argon2id) | No |
| `POST` | `/auth/login` | Login with email and password | No |
| `POST` | `/auth/social` | Authenticate using Google / Apple ID Token | No |
| `POST` | `/auth/guest` | Generate or resume guest session via `deviceId` UUID | No |
| `POST` | `/auth/refresh` | Exchange refresh token for fresh access token | No |
| `POST` | `/auth/logout` | Invalidate active refresh token | Yes |

### 6.2. Player Profile (`/api/v1/profile`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/profile/me` | Retrieve player profile, stats, level, and coin balance | Yes |
| `PATCH` | `/profile/nickname` | Update unique nickname (validates format & availability) | Yes |
| `GET` | `/profile/check-nickname/:name`| Pre-check username availability | Yes |
| `POST` | `/profile/hint` | Validate balance (`>= 5`), deduct 5 coins, return remaining | Yes |

### 6.3. Levels & World Map (`/api/v1/levels`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/levels/map` | Fetch unlocked level cards, completed nodes, and active level | Yes |
| `POST` | `/levels/complete` | Validate victory, award coins (+10 base, +25 for 3★), advance level | Yes |
| `POST` | `/levels/claim-mystery-box` | Claim scaled mystery box ($20 \times 1.5^{n-1}$ coins) at milestone level | Yes |

#### Mystery Box Claim Example (`POST /api/v1/levels/claim-mystery-box`)
**Request:**
```json
{
  "levelNumber": 30
}
```
**Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "levelNumber": 30,
    "rewardCoins": 45,
    "newTotalCoins": 725,
    "claimed": true
  },
  "message": "Level 30 Mystery Box claimed: +45 coins"
}
```

### 6.4. Daily Challenge (`/api/v1/daily`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/daily/today` | Fetch today's challenge puzzle seed, date, and stake requirement | Yes |
| `POST` | `/daily/enter` | Verify `coins >= 20`, deduct 20 coins, grant challenge ticket | Yes |
| `POST` | `/daily/complete` | Validate solve, award multiplier (3★=60, 2★=40, 1★=0), increment streak | Yes |
| `GET` | `/daily/calendar` | Return weekly Monday–Sunday solve history | Yes |

#### Daily Challenge Entry (`POST /api/v1/daily/enter`)
**Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "dateKey": "2026-09-22",
    "stakeDeducted": 20,
    "remainingCoins": 480,
    "ticketId": "ticket_98df8924bce"
  },
  "message": "Challenge entered. 20 coins staked."
}
```

#### Daily Challenge Complete (`POST /api/v1/daily/complete`)
**Request:**
```json
{
  "dateKey": "2026-09-22",
  "ticketId": "ticket_98df8924bce",
  "stars": 3,
  "score": 940,
  "timeSeconds": 75,
  "foundWords": ["FOREST", "RIVER", "TRAIL", "PINE", "BREEZE"]
}
```
**Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "stars": 3,
    "multiplier": "3x",
    "payoutCoins": 60,
    "netProfitCoins": 40,
    "currentStreak": 8,
    "totalCoins": 540
  },
  "message": "3★ Master victory! 3x payout awarded (+60 coins)."
}
```

### 6.5. Offline Sync Reconciler (`/api/v1/sync`)

| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/sync/batch` | Synchronize offline level progress, coins, and solves from Hive | Yes |

---

## 7. Anti-Cheat & Server-Side Verification

To prevent client tampering (e.g., memory injection or modified client requests), the backend validates:

1. **Board Solution Replay**: When a level or daily challenge is submitted, the server generates the deterministic grid from the seed and verifies that all reported words exist in the grid along valid vectors (Horizontal, Vertical, Diagonal, and their reverses).
2. **Time Threshold Verification**: Validates that completion time is biologically plausible ($T_{\text{elapsed}} \ge N_{\text{words}} \times 1.2\text{s}$). Submissions completed in $< 2$ seconds are flagged and rejected.
3. **Coin Balance Consistency**: Coin additions and deductions are managed via MongoDB atomic transactions (`$inc: { coins: delta }`), preventing race conditions or duplicate hint requests.
4. **Daily Stake Validation**: `/daily/complete` requires an active `ticketId` generated by `/daily/enter`. Players cannot claim 3x/2x payouts without having paid the 20-coin entry stake.

---

## 8. Offline-to-Online Batch Synchronization

When a player plays offline, the Flutter client stores completed levels in Hive. Upon reconnecting, the client calls `POST /api/v1/sync/batch`:

```json
{
  "clientTimestamp": "2026-09-22T22:50:00Z",
  "pendingLevels": [
    {
      "levelNumber": 28,
      "stars": 3,
      "score": 850,
      "bestTime": "01:14"
    },
    {
      "levelNumber": 29,
      "stars": 3,
      "score": 920,
      "bestTime": "01:05"
    }
  ],
  "puzzlesSolvedDelta": 2,
  "wordsFoundDelta": 16
}
```

The synchronization service uses a **Higher-Score / Higher-Stars Wins** resolution strategy:
- If the server has a lower star rating or score for a level, it updates to the client's values.
- `highestUnlockedLevel` and `playerLevel` are updated to $\max(\text{server}, \text{client})$.
- Player statistics (`wordsFound`, `puzzlesSolved`) are incremented atomically.

---

## 9. Security & Error Handling

### Standard Response Envelope
All endpoints respond with a predictable JSON envelope:

#### Success (`200 OK`, `201 Created`)
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation completed successfully",
  "error": null
}
```

#### Error (`400 Bad Request`, `401 Unauthorized`, `403 Forbidden`, `404 Not Found`)
```json
{
  "success": false,
  "data": null,
  "message": "Insufficient coin balance",
  "error": {
    "code": "INSUFFICIENT_COINS",
    "required": 20,
    "available": 14
  }
}
```

---

## 10. Development Setup & Deployment

### 10.1. Prerequisites
- **Node.js**: v20.x or higher
- **npm**: v10.x or higher
- **MongoDB**: v6.0 or higher (or MongoDB Atlas connection string)
- **Docker** (Optional)

### 10.2. Installation & Running Locally

1. **Clone & Install Dependencies**:
   ```bash
   cd backend
   npm install
   ```

2. **Configure Environment Variables**:
   Create a `.env` file in the `backend/` directory:
   ```env
   PORT=5000
   NODE_ENV=development
   MONGODB_URI=mongodb://localhost:27017/hunt_the_word
   JWT_SECRET=super_secret_jwt_signing_key_at_least_32_characters
   JWT_EXPIRES_IN=7d
   JWT_REFRESH_SECRET=super_secret_refresh_key_at_least_32_characters
   JWT_REFRESH_EXPIRES_IN=30d
   CORS_ORIGIN=*
   ```

3. **Start Development Server** (with hot reload via `tsx` or `ts-node-dev`):
   ```bash
   npm run dev
   ```

4. **Production Build**:
   ```bash
   npm run build
   npm start
   ```

5. **Run Test Suites**:
   ```bash
   npm test
   ```

### 10.3. Docker Containerization

Run both the API and MongoDB using Docker Compose:

```bash
docker compose up --build -d
```

To view logs:
```bash
docker compose logs -f api
```
