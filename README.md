# CXO Connect - Premium Flutter Landing & Match Marketplace

A visually stunning, high-fidelity Flutter application built to represent **CXO Connect**, the premier two-sided executive marketplace. This app combines a gorgeous dark-theme landing page with an interactive project marketplace, vetted network directories, and a personal member settings dashboard.

---

## 📸 Key Design Features (Pixel-Perfect)

- **Premium Modern Dark Theme**: Built using a deeply harmonized, rich midnight blue (`#060814` & `#0B1120`) HSL scale.
- **Accented Brand Highlights**: Styled using vibrant neon teal/mint green (`#46E4A2`) gradients, high letter-spacing title tokens, and clean outline borders.
- **Typography Excellence**: Powered by Google Fonts (combining `GoogleFonts.spaceGrotesk` for premium high-tech headlines and `GoogleFonts.inter` for readable, professional copy).
- **Smooth Micro-Animations**: Buttons, checklist items, and tab navigation feature micro-feedback and scale animations.

---

## 🛠️ Interactive Features

1. **Vetted Value Card**: Replicates the central value card with ratings stars, structured checkmarks, teal-bordered quote callouts, and clean headshot image clips.
2. **Tabbed Bottom Navigation**: Fully wired bottom bars that transition between:
   - 🛡️ **Matches**: The highly detailed landing page.
   - 💼 **Projects**: Interactive search-and-filter marketplace for Fractional & Interim roles.
   - 👥 **Network**: Beautiful directory of verified executive professionals with booking requests.
   - 👤 **Profile**: Platinum member statistics dashboard and matching settings.
3. **Redirections & Flow**: Clicking "Explore Engagements" seamlessly routes the user to the **Projects** tab.
4. **Lead Forms**: Fully validated lead capture sheets for "Get Started" enterprise hiring and "Become a Member" executive applications.

---

## 📂 Code Organization

The project is structured under `/lib` according to clean architectural principles:

```
lib/
├── main.dart                 # App initialization with Riverpod Scope and Theme
├── theme.dart                # Design tokens, color palettes, and themes
├── models/
│   ├── project_model.dart    # Model for active executive projects
│   └── advisor_model.dart    # Model for vetted advisor records
├── services/
│   └── mock_service.dart     # Highly realistic corporate mock datasets
├── viewmodels/
│   └── app_state.dart        # Riverpod providers for search, filters, and tabs
├── widgets/
│   ├── custom_button.dart    # Fully configurable styled buttons
│   ├── value_prop_card.dart  # Central mockup card widget
│   ├── benefit_card.dart     # Service benefit card template
│   └── forms.dart            # Lead capture bottom-sheet dialog forms
└── views/
    ├── main_navigation_shell.dart  # bottom nav, appbar, and side drawers
    ├── landing_view.dart     # Hero, trusted logos, and landing sections
    ├── projects_view.dart    # Browse active jobs
    ├── network_view.dart     # Browse vetted executives
    └── profile_view.dart     # Member metrics dashboard
```

---

## 🚀 Quick Setup & Run Instructions

### Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.0 or higher is required, null safe).

### Installation & Run

1. Clone or navigate to the project directory:
   ```bash
   cd App-CXO
   ```

2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```

3. Run Static Code Analysis (validates compilation correctness):
   ```bash
   flutter analyze
   ```

4. Run the Unit/Widget Tests:
   ```bash
   flutter test
   ```

5. Launch the application:
   ```bash
   flutter run
   ```

---

## 💬 Core Architectural Decisions

- **State Management**: Built on `flutter_riverpod` (specifically `StateNotifier` and basic `Provider` models) to establish clean decoupling between user interactions (such as applying to a project or requesting an advisor introduction) and active widget rebuilds.
- **Responsiveness**: Reusable layout structures scale elegantly using generic media scales, flexible column/row arrangements, wraps, and constraints that match both compact phone sizes and web/desktop form-factors.
