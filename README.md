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

## Screens

### Public Screens
| Screen | Route | Description |
|---|---|---|
| Home Landing Page | `/` | Hero with headline, auto-scroll marquee, 3D carousel, membership benefits, contact section, TARS chatbot |
| About | `/about` | Platform overview |
| Privacy Policy | `/privacy-policy` | Legal & privacy information |
| Terms of Service | `/terms-of-service` | Terms & conditions |

### Onboarding & Authentication
| Screen | Route | Description |
|---|---|---|
| Join Company | `/join-company` | 4-step wizard: Basic Details → Company Info → Online Presence → Account Setup |
| Join Expert | `/join-expert` | 4-step wizard: Basic Profile → Experience → Validation → Agreement |
| Sign In | `/signin` | Unified login with OTP/magic link, numeric OTP grid, demo bypass |

### Company Portal
| Screen | Route | Description |
|---|---|---|
| Company Dashboard | `/company-dashboard` | Engagement metrics, milestones, requirements overview, quick actions |
| My Requirements | `/requirements` | Posted requirements management |
| Post Requirement | `/requirements/create` | 4-step wizard to create new engagement requirements |
| Find Experts | `/experts` | Filterable expert catalog with grid/list toggle and 3-expert comparison tray |
| Expert Profile | `/experts/:expertId` | Detailed profile with About, Experience, Case Studies, Rate tabs |
| Payments & Escrow | `/payments` | KPI summary bar, deposit form, escrow accounts, transaction history, invoices |
| Analytics | `/analytics` | 8-tab analytics hub: Overview, Hiring, Talent Pool, Engagement, Financial, Performance, Pipeline, Reports |
| Messages | `/messages` | Chat with emoji picker, file attachments, 2-step sync scheduler modal |
| Scheduled Meetings | `/meetings` | Upcoming/past meetings with join and cancel actions |
| Engagement Workspace | `/engagements/:engagementId` | Project summary, milestone timelines, PMO activity feed |
| Settings | `/company-settings` | Company account settings |

### Expert Portal
| Screen | Route | Description |
|---|---|---|
| Expert Dashboard | `/expert-dashboard` | Schedule, matched opportunities, active engagements, earnings, profile strength |
| Opportunities | `/expert-opportunities` | Browse and apply for matched roles with filters |
| My Engagements | `/expert-engagements` | Active engagements, milestones, earnings summary |
| Contracts | `/expert-contracts` | Contract management with signature flow |
| Earnings | `/expert-earnings` | Lifetime earnings, withdrawals, invoices, transactions |
| Profile Builder | `/expert-profile` | Interactive tabs, profile strength ring, add experience/education/case studies |
| Messages | `/messages` | Shared messaging hub |
| Meetings | `/meetings` | Shared meetings calendar |
| Settings | `/expert-settings` | Expert account settings |

## Getting Started

### Prerequisites

- Flutter SDK (v3.12+)
- Dart SDK

### Run the app

```bash
flutter pub get
flutter run
```

The app runs in demo mode with realistic mock data — no backend setup required. Use `demo@cxo.com` to bypass authentication.

## Project Structure

```
lib/
├── core/
│   └── routing/       # GoRouter configuration with role-based redirects
├── models/            # Data models (Company, Expert, Engagement, Milestone, etc.)
├── services/          # Mock services and data stores
├── viewmodels/        # Riverpod providers for state management
├── views/             # All screen views
│   ├── landing_view.dart
│   ├── company_onboarding_view.dart
│   ├── expert_onboarding_view.dart
│   ├── portal_views.dart         # All dashboard & portal views (~9200 lines)
│   ├── shell_layouts.dart        # Sidebar navigation layouts
│   ├── projects_view.dart        # Projects marketplace
│   ├── network_view.dart         # Expert network directory
│   ├── profile_view.dart         # Expert profile view
│   └── main_navigation_shell.dart # Main navigation shell
├── widgets/           # Reusable UI components
├── main.dart          # App entry point
└── theme.dart         # Color palette and theme definitions
```
