# 🎯 Word Hunt

> A modern, progressive Word Search Puzzle Game built with Flutter, Node.js, TypeScript, and MongoDB.

**Word Hunt** is an offline-first word search puzzle game where players find hidden words in progressively challenging grids, unlock new levels and themes, earn rewards, maintain streaks, and synchronize their progress across devices.

The project is designed with a **Flutter frontend**, a **Node.js + TypeScript backend**, and **MongoDB** for cloud data persistence.

---

## ✨ Features

### 🎮 Core Gameplay

* Interactive word-search grid with responsive touch detection
* Swipe-based word selection with glowing trail
* Horizontal word detection (left-to-right & right-to-left)
* Vertical word detection (top-to-bottom & bottom-to-top)
* Diagonal word detection (all four diagonal vectors)
* Reverse word detection
* Overlapping words
* Progressive difficulty & board scaling
* Multiple grid sizes (5×5 up to 10×10+)
* Word completion animations & haptic wobble feedback
* Real-time score calculation
* Timer-based challenges & countdown timers
* 5-Coin Hint system

### 📈 Progression

* Level-based progression with auto-scrolling to active level
* World/chapter system (Verdant Forest, Ocean Sanctuary, etc.)
* Increasing difficulty & word count
* 3-Star rating system
* Player statistics & lifetime records
* Level completion tracking
* Resume unfinished games via saved seed & board state
* Daily streaks

### 🎨 Customization

* Multiple board themes (Classic, Midnight, Ocean, Forest, Candy, Cyber)
* Dark mode support
* Theme unlocking & equipment system

### 🏆 Gamification

* Coins & economy system
* Scaled Mystery Boxes (20 coins base at Level 10, increasing 1.5x every 10 levels)
* Daily Challenge with 20-coin entry stake and star multipliers (3★ = 3x, 2★ = 2x, 1★ = 0x)
* Achievements & badge milestones (36 badges)
* Daily rewards & streaks
* Level stars
* Global & friends leaderboards

### ☁️ Cloud Features

* User accounts (Guest, Google, Apple ID, Email)
* Cloud progress synchronization
* Cross-device progress
* Cloud profile & unique player tag (`#WH-XXXX`)
* Daily challenge synchronization
* Leaderboards

### 📱 Offline First

The core game works without an internet connection.

Local storage (Hive CE) is used for:

* Active game state
* Cached levels
* Player preferences & profile
* Offline progress & completed levels
* Selected theme
* Temporary game data

When an internet connection becomes available, relevant data can be synchronized with the backend.

---

# 🏗️ Architecture

Word Hunt follows an **offline-first client-server architecture**.

```text
                         WORD HUNT
                             │
              ┌──────────────┴──────────────┐
              │                             │
         Flutter App                  Node.js API
              │                             │
      ┌───────┴────────┐                    │
      │                │                    │
   Game Engine       Hive                  │
      │             Local DB               │
      │                                    │
      └────────────┐                       │
                   │                       │
                   └────── REST API ───────┘
                                           │
                                           ▼
                                       MongoDB
```

### Client Architecture

```text
UI (Widgets & Screens)
 ↓
Provider / ViewModel (GameProvider, LevelProgressProvider, PlayerProfileProvider)
 ↓
Repository / Storage Service
 ↓
 ┌──────────────┐
 │              │
Hive          REST API
                │
                ▼
           Node.js Server
```

The game engine remains independent from Flutter UI and can be tested without Flutter bindings.

---

# 🛠️ Technology Stack

## Frontend

| Technology   | Purpose                    |
| ------------ | -------------------------- |
| Flutter      | Cross-platform application |
| Dart         | Programming language       |
| Provider     | State management           |
| Hive CE      | Local persistence          |
| Material 3   | UI foundation              |
| Google Fonts | Typography (Outfit, Roboto)|

## Backend

| Technology | Purpose            |
| ---------- | ------------------ |
| Node.js    | Server runtime     |
| TypeScript | Backend language   |
| Express.js | REST API           |
| Mongoose   | MongoDB ODM        |
| Zod        | Request validation |
| JWT        | Authentication     |
| Argon2id   | Password hashing   |
| OpenAPI    | API documentation  |

## Database

**MongoDB**

Used for:

* Users
* Profiles
* Levels & Worlds
* Progress
* Themes
* Achievements
* Daily challenges
* Leaderboards

## Development & Deployment

* Git & GitHub
* Docker & Docker Compose
* GitHub Actions
* REST API
* Android Studio / VS Code / Google Antigravity

---

# 📁 Project Structure

```text
hunt_the_word/
│
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── routing/
│   │   └── widgets/
│   │
│   ├── engine/
│   │   ├── grid_coordinate.dart
│   │   ├── direction_vector.dart
│   │   ├── word_placement.dart
│   │   ├── puzzle_board.dart
│   │   ├── level_configuration.dart
│   │   ├── grid_generator.dart
│   │   └── word_validator.dart
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── levels/
│   │   ├── game/
│   │   ├── daily/
│   │   ├── themes/
│   │   ├── achievements/
│   │   ├── profile/
│   │   ├── completion/
│   │   └── settings/
│   │
│   └── main.dart
│
├── test/
│   ├── engine_test.dart
│   ├── game_provider_test.dart
│   ├── game_ui_integration_test.dart
│   ├── level_complete_dialog_test.dart
│   ├── economy_and_level_progression_test.dart
│   └── widget_test.dart
│
├── BACKEND_README.md
├── README.md
└── pubspec.yaml
```

---

# 🧩 Game Engine

The Word Hunt game engine is completely independent from the Flutter UI.

### Main components

```text
GridCoordinate
       │
       ▼
DirectionVector
       │
       ▼
WordPlacement
       │
       ▼
GridGenerator
       │
       ▼
PuzzleBoard
       │
       ▼
WordValidator
```

### Supported directions

```text
→ Horizontal

↓ Vertical

↘ Diagonal Down-Right

↗ Diagonal Up-Right

← Reverse Horizontal

↑ Reverse Vertical

↖ Reverse Diagonal Up-Left

↙ Reverse Diagonal Down-Left
```

The engine supports:

* Deterministic generation using seeds
* Word overlapping
* Boundary checking
* Invalid placement detection
* Impossible configuration handling
* Random letter filling

---

# 📊 Difficulty System

Difficulty is configuration-driven:

| Level  |   Grid | Words | Difficulty |
| ------ | -----: | ----: | ---------- |
| 1–10   |    5×5 |   3–4 | Easy       |
| 11–25  |    7×7 |   5–7 | Medium     |
| 26–50  |    9×9 |  8–10 | Hard       |
| 51–100 | 10×10+ | 10–15 | Expert     |

---

# 🌍 World System

Levels are grouped into themed worlds:

```text
🌿 World 1 — Verdant Forest
   Levels 1–20

🌊 World 2 — Ocean Sanctuary
   Levels 21–40

🚀 World 3 — Space Frontier
   Levels 41–60

🏙️ World 4 — Cyber City
   Levels 61–80

🔮 World 5 — Mystic Realm
   Levels 81–100
```

---

# 💾 Offline-First Progress

Word Hunt uses Hive CE for local persistence. Active games are saved with full board recovery data:

```json
{
  "levelNumber": 27,
  "randomSeed": 823746,
  "foundWords": [
    "OCEAN",
    "WAVE"
  ],
  "score": 450,
  "elapsedTime": 92,
  "hintsUsed": 1
}
```

---

# 🏆 Rewards & Economy

| Action | Reward / Cost | Description |
|---|---|---|
| **Welcome Bonus** | **+500 🪙** | Credited on account registration |
| **Complete Level** | **+10 🪙** | Base victory reward |
| **3-Star Level** | **+25 🪙** | First-time 3★ completion |
| **Mystery Box** | **$20 \times 1.5^{n-1}$ 🪙** | Available every 10 levels (L10: 20, L20: 30, L30: 45, L40: 68...) |
| **Daily Challenge Stake** | **-20 🪙** | Entry fee to play daily challenge |
| **Daily 3-Star Win (★★★)** | **+60 🪙** | **$3\times$** stake payout (+40 profit) |
| **Daily 2-Star Win (★★☆)** | **+40 🪙** | **$2\times$** stake payout (+20 profit) |
| **Daily 1-Star Win (★☆☆)** | **+0 🪙** | Stake forfeited; streak preserved |
| **Use Hint** | **-5 🪙** | Reveals a random unrevealed word letter |

---

# 📅 Daily Challenge

Every day, the application provides a special puzzle with dynamic date generation and stake rewards:

```json
{
  "date": "2026-09-22",
  "seed": 823746,
  "difficulty": "medium",
  "stake": 20,
  "maxReward": 60
}
```

---

# 🧪 Testing

```bash
flutter analyze
flutter test
```

All 72+ test suites cover:
* Grid generation & vector checks
* Horizontal, vertical, diagonal, and reverse word validation
* Overlapping words
* Swipe drag gesture physics & wobble rejection feedback
* State persistence & Level map auto-scrolling
* 5-coin hint economy & 20-coin daily challenge stake payouts
* Dynamic 1.5x mystery box scaling

---

# 🚀 Quick Start

### Flutter Mobile App

```bash
flutter pub get
flutter run
```

### Backend API

For full backend details, Mongoose schemas, and endpoints, see [BACKEND_README.md](file:///home/beingsbh/hunt_the_word/BACKEND_README.md).

```bash
cd backend
npm install
npm run dev
```

---

# 🗺️ Development Roadmap

## Phase 1 — Foundation
* [x] Flutter project structure
* [x] Design system integration & Material 3 theme tokens
* [x] Layered architecture

## Phase 2 — Game Engine
* [x] Grid generation & direction vectors
* [x] Word placement & overlap engine
* [x] Word validation (all 8 directions)
* [x] Seeded deterministic generation
* [x] Engine unit test suite

## Phase 3 — Gameplay
* [x] GameProvider & viewmodels
* [x] Smooth swipe selection & line renderer
* [x] Dynamic score & countdown timer
* [x] Level complete victory dialog & bounce animations

## Phase 4 — Local Persistence
* [x] Hive CE integration
* [x] Active puzzle save & restore
* [x] Player profile & settings persistence
* [x] Level map auto-scroll to active quest

## Phase 5 — Backend
* [x] Node.js + TypeScript architecture specification
* [x] Express REST API design
* [x] MongoDB & Mongoose schemas
* [x] Zod validation & Argon2id auth

## Phase 6 — Gamification & Economy
* [x] 5-Coin hint economy
* [x] Scaled mystery box reward system (1.5x scaling)
* [x] Daily challenge 20-coin stake & 3x/2x/0x payouts
* [x] Achievements & badges tracker

---

# 📄 License

MIT License. See LICENSE for details.
