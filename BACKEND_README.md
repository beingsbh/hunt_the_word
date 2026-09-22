# Hunt the Word — Node.js Backend Specification & Architecture Guide

A scalable, modular, feature-based **Node.js (TypeScript)** backend designed specifically to accompany the **Hunt the Word** Flutter mobile application.

---

## 1. Architectural Philosophy

This backend uses a **Feature-Driven Modular Architecture** (Domain Modules). Each feature module encapsulates its own routing, controller, business service, validation schema, and data access logic.

This design directly mirrors the Flutter frontend structure:

```
Flutter (lib/features/...)      ⇄      Node.js (src/modules/...)
├── auth/                               ├── auth/
├── profile/                            ├── profile/
├── levels/                             ├── levels/
├── game/                               ├── game/
├── daily/                              ├── daily/
├── achievements/                       ├── achievements/
└── themes/                             └── themes/
```

### Key Benefits
- **Zero Tight Coupling**: Each game feature can evolve or be refactored independently.
- **Offline-First Compatibility**: Built-in support for batch sync with Flutter's local Hive storage.
- **Cheat-Resistant**: Critical metrics (star calculations, high scores, coin rewards, theme purchases) are verified server-side.
- **Type-Safety**: End-to-end data contracts using TypeScript and Zod validation schemas.

---

## 2. Directory Structure

```text
hunt-the-word-backend/
├── prisma/
│   └── schema.prisma                   # Database schemas (PostgreSQL / MySQL)
├── src/
│   ├── app.ts                          # Express app configuration & global middleware
│   ├── server.ts                       # Entrypoint & HTTP server lifecycle
│   │
│   ├── config/                         # Environment & third-party configs
│   │   ├── env.ts                      # Zod-validated environment variables
│   │   ├── database.ts                 # Prisma Client instance
│   │   └── firebase.ts                 # Firebase Admin SDK for social OAuth tokens
│   │
│   ├── core/                           # Shared cross-cutting modules
│   │   ├── constants/                  # Business & economy constants (e.g. 500 initial coins)
│   │   │   └── game-rules.constant.ts
│   │   ├── errors/                     # Standardized application error hierarchy
│   │   │   ├── app.error.ts
│   │   │   ├── bad-request.error.ts
│   │   │   ├── unauthorized.error.ts
│   │   │   └── not-found.error.ts
│   │   ├── middlewares/                # Express middleware pipeline
│   │   │   ├── auth.middleware.ts      # JWT session & guest verification
│   │   │   ├── validate.middleware.ts  # Zod schema request validation
│   │   │   ├── error.middleware.ts     # Global centralized error handler
│   │   │   └── rate-limit.middleware.ts# Anti-cheat & DDoS throttling
│   │   └── utils/                      # Common helper functions
│   │       ├── api-response.util.ts    # Standard JSON response envelope builder
│   │       ├── jwt.util.ts             # JWT signing & verification helpers
│   │       └── player-tag.util.ts      # Generates unique identifiers (e.g. #WH-9824)
│   │
│   ├── modules/                        # Game feature domains
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
│   │   ├── levels/                     # Level Progression, Stars, & Scores
│   │   │   ├── levels.controller.ts
│   │   │   ├── levels.service.ts
│   │   │   ├── levels.routes.ts
│   │   │   └── levels.validation.ts
│   │   │
│   │   ├── daily/                      # Daily Challenges & Calendar Streaks
│   │   │   ├── daily.controller.ts
│   │   │   ├── daily.service.ts
│   │   │   ├── daily.routes.ts
│   │   │   └── daily.validation.ts
│   │   │
│   │   ├── achievements/               # Badges & Milestones
│   │   │   ├── achievements.controller.ts
│   │   │   ├── achievements.service.ts
│   │   │   ├── achievements.routes.ts
│   │   │   └── achievements.validation.ts
│   │   │
│   │   ├── themes/                     # Skins, Tile Palettes, & Store
│   │   │   ├── themes.controller.ts
│   │   │   ├── themes.service.ts
│   │   │   ├── themes.routes.ts
│   │   │   └── themes.validation.ts
│   │   │
│   │   └── sync/                       # Offline-to-Online Batch Reconciler
│   │       ├── sync.controller.ts
│   │       ├── sync.service.ts
│   │       ├── sync.routes.ts
│   │       └── sync.validation.ts
│   │
│   └── routes.ts                       # Aggregator mounting all modules under /api/v1
│
├── tests/                              # Integration & unit test suites (Vitest / Jest)
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

---

## 3. Technology Stack

- **Runtime**: Node.js v20+ LTS
- **Language**: TypeScript v5+
- **HTTP Framework**: Express.js (or Fastify)
- **Database**: PostgreSQL (or MySQL)
- **ORM**: Prisma ORM
- **Schema Validation**: Zod
- **Authentication**: `jsonwebtoken` (JWT) + `firebase-admin` (Social token verification)
- **Security**: `helmet`, `cors`, `express-rate-limit`

---

## 4. API Endpoints Specification

All endpoints are versioned under `/api/v1`. Authenticated routes expect a Bearer token: `Authorization: Bearer <JWT_TOKEN>`.

### 4.1. Authentication (`/api/v1/auth`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/auth/social` | Authenticate via Google or Apple ID token | No |
| `POST` | `/auth/guest` | Create/resume guest account with device UUID | No |
| `POST` | `/auth/refresh` | Refresh expired access tokens | No |
| `POST` | `/auth/logout` | Revoke active session tokens | Yes |

> **Note on Initial Reward**: When a new user registers via social auth or guest mode, the backend automatically seeds their account with **500 coins** and assigns a unique `#WH-XXXX` player tag.

### 4.2. Player Profile (`/api/v1/profile`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/profile/me` | Fetch active player profile & lifetime stats | Yes |
| `PATCH`| `/profile/username` | Claim/update unique nickname & player tag | Yes |
| `PATCH`| `/profile/avatar` | Update avatar icon or profile color | Yes |
| `GET` | `/profile/check-username/:username` | Validate username uniqueness | Yes |

### 4.3. Levels & Progression (`/api/v1/levels`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/levels/progress` | Get unlocked levels, stars (1–3), and high scores | Yes |
| `POST` | `/levels/complete` | Submit level victory, verify score/time, credit coins (+25) | Yes |
| `GET` | `/levels/world/:worldId` | Get world chapter summary (e.g. World 2: Ocean Sanctuary) | Yes |

### 4.4. Daily Challenge (`/api/v1/daily`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/daily/today` | Fetch today's seed, category, and words | Yes |
| `POST` | `/daily/claim` | Record completed challenge & increment streak | Yes |
| `GET` | `/daily/calendar`| Fetch 7-day or monthly completion status | Yes |

### 4.5. Achievements & Badges (`/api/v1/achievements`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/achievements` | List all 36 badges and player completion progress | Yes |
| `POST` | `/achievements/:id/claim` | Claim unlocked achievement rewards | Yes |

### 4.6. Themes & Store (`/api/v1/themes`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/themes` | Fetch available themes, ownership status, & prices | Yes |
| `POST` | `/themes/buy` | Deduct coins and add theme to player inventory | Yes |
| `POST` | `/themes/equip` | Set active theme palette | Yes |

### 4.7. Offline Data Synchronization (`/api/v1/sync`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/sync/batch` | Upload batch level completions from Flutter Hive storage | Yes |

---

## 5. Database Schema (Prisma ORM)

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

enum AuthProvider {
  GUEST
  GOOGLE
  APPLE
  FACEBOOK
}

model User {
  id            String         @id @default(uuid())
  email         String?        @unique
  provider      AuthProvider   @default(GUEST)
  providerId    String?        @unique
  deviceId      String?        @unique
  createdAt     DateTime       @default(now())
  updatedAt     DateTime       @updatedAt

  profile       Profile?
  levelProgress LevelProgress[]
  dailyEntries  DailyHistory[]
  userBadges    UserBadge[]
  ownedThemes   UserTheme[]

  @@map("users")
}

model Profile {
  id                    String   @id @default(uuid())
  userId                String   @unique
  user                  User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  nickname              String   @default("Subha WordMaster")
  playerTag             String   @unique // e.g. #WH-9824
  playerTitle           String   @default("Explorer Tier II")
  playerLevel           Int      @default(1)
  coins                 Int      @default(500) // Initial balance
  totalStars            Int      @default(0)
  currentLevel          Int      @default(1)
  highestUnlockedLevel  Int      @default(1)
  streak                Int      @default(0)
  puzzlesSolved         Int      @default(0)
  wordsFound            Int      @default(0)
  accuracyRate          Float    @default(100.0)
  bestScore             Int      @default(0)
  hasSetUniqueUsername  Boolean  @default(false)

  createdAt             DateTime @default(now())
  updatedAt             DateTime @updatedAt

  @@map("profiles")
}

model LevelProgress {
  id          String   @id @default(uuid())
  userId      String
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  levelNumber Int
  worldNumber Int      @default(1)
  stars       Int      @default(0) // 1 to 3
  score       Int      @default(0)
  bestTime    String   @default("00:00")
  isCompleted Boolean  @default(false)
  updatedAt   DateTime @updatedAt

  @@unique([userId, levelNumber])
  @@map("level_progress")
}

model DailyHistory {
  id          String   @id @default(uuid())
  userId      String
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  dateString  String   // Format: YYYY-MM-DD
  isCompleted Boolean  @default(true)
  score       Int      @default(0)
  timeTaken   String
  createdAt   DateTime @default(now())

  @@unique([userId, dateString])
  @@map("daily_history")
}

model UserBadge {
  id          String   @id @default(uuid())
  userId      String
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  badgeKey    String   // e.g. "FIRST_WORD", "WORD_STREAK"
  isClaimed   Boolean  @default(false)
  unlockedAt  DateTime @default(now())

  @@unique([userId, badgeKey])
  @@map("user_badges")
}

model UserTheme {
  id          String   @id @default(uuid())
  userId      String
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  themeKey    String   // e.g. "ocean_depths", "autumn_amber"
  isEquipped  Boolean  @default(false)
  purchasedAt DateTime @default(now())

  @@unique([userId, themeKey])
  @@map("user_themes")
}
```

---

## 6. Standard API Response Structure

Every response returned to the Flutter application conforms to this schema:

### Success Response (`200 OK`, `201 Created`)
```json
{
  "success": true,
  "data": {
    "levelNumber": 28,
    "stars": 3,
    "score": 850,
    "coinsEarned": 25,
    "totalCoins": 525
  },
  "message": "Level completed successfully",
  "error": null
}
```

### Error Response (`400 Bad Request`, `401 Unauthorized`, `409 Conflict`)
```json
{
  "success": false,
  "data": null,
  "message": "Username already taken",
  "error": {
    "code": "USERNAME_TAKEN",
    "details": ["The username 'Subha' is already registered. Please choose another."]
  }
}
```

---

## 7. Quick Start Guide

### 1. Initialize Project & Dependencies
```bash
mkdir hunt-the-word-backend && cd hunt-the-word-backend
npm init -y
npm install express cors helmet dotenv jsonwebtoken zod @prisma/client firebase-admin express-rate-limit
npm install -D typescript @types/node @types/express @types/cors @types/jsonwebtoken ts-node-dev prisma
```

### 2. Configure TypeScript (`tsconfig.json`)
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "rootDir": "./src",
    "outDir": "./dist",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"]
}
```

### 3. Setup Environment (`.env`)
```env
PORT=3000
NODE_ENV=development
DATABASE_URL="postgresql://postgres:password@localhost:5432/hunt_the_word?schema=public"
JWT_SECRET="your-super-secret-jwt-key"
JWT_EXPIRES_IN="7d"
INITIAL_COINS=500
LEVEL_REWARD_COINS=25
```

### 4. Initialize Database
```bash
npx prisma init
npx prisma migrate dev --name init
```

### 5. Run in Development
```bash
npm run dev
```
