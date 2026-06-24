# CXO Connect

A premium two-sided executive marketplace that connects vetted C-level executives and expert advisors with enterprises seeking fractional, interim, or advisory leadership.

## Overview

CXO Connect serves both sides of the marketplace:

- **Enterprises** — discover, hire, and manage vetted executive talent for strategic initiatives.
- **Expert Advisors / CXOs** — browse opportunities, manage engagements, handle contracts, track earnings, and build professional profiles.

The app includes role-based portals (Company & Expert), onboarding wizards, a marketplace for projects and advisors, a simulated AI chatbot (TARS), and full light/dark theme support.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod (StateNotifier + Provider) |
| Routing | go_router |
| Backend | Supabase (configured; currently uses mock data) |
| Theming | Custom light & dark themes |
| Platforms | Android, iOS, macOS, Web |

## Getting Started

### Prerequisites

- Flutter SDK (v3.12+)
- Dart SDK

### Run the app

```bash
flutter pub get
flutter run
```

The app runs in demo mode with realistic mock data — no backend setup required.

## Project Structure

```
lib/
├── core/           # Routing, theme, constants
├── models/         # Data models
├── services/       # Mock services and data stores
├── viewmodels/     # Riverpod providers
├── views/          # Screens and layouts
├── widgets/        # Reusable UI components
├── main.dart       # App entry point
└── theme.dart      # Color palette and theme definitions
```
