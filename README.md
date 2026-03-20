# The Journal — Mood Journal App

A privacy-first daily mood journaling app built with Flutter. No accounts, no server, no tracking — everything lives on your device.

---

## What it does

- **Daily check-in** — Log your mood in under 10 seconds using a 5-level emoji scale
- **Journal entries** — Write free-form notes tied to each mood, with auto-save
- **History & trends** — Monthly calendar view color-coded by mood score + 7-day trend chart
- **Daily reminders** — Schedule a notification at your preferred time to build the habit
- **Onboarding flow** — First-launch welcome, explainer, and reminder setup screens

---

## Tech stack

| Layer | Package |
|---|---|
| Framework | Flutter (Dart) |
| Database | `drift` (SQLite ORM) |
| State management | `flutter_riverpod` |
| Navigation | `go_router` |
| Charts | `fl_chart` |
| Notifications | `flutter_local_notifications` + `timezone` |
| UI fonts | `google_fonts` |
| Preferences | `shared_preferences` |

---

## Getting started

**Requirements**
- Flutter SDK `>=3.27.0`
- Dart SDK `>=3.6.0`
- Android SDK (for Android builds) or Xcode (for iOS builds)

**Run locally**

```bash
git clone <repo-url>
cd mood_journal

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Project structure

```
lib/
  core/
    database/       # Drift DB, DAOs, MoodEntry model
    notifications/  # NotificationService, providers
    router/         # go_router config + route constants
    theme/          # AppTheme, color palette, typography
  features/
    checkin/        # Check-in bottom sheet (mood selector + note)
    home/           # Home screen + providers (streak, recent entries)
    history/        # Calendar grid + trend chart + stats
    journal/        # Entry list (grouped by month) + full-text editor
    onboarding/     # Welcome, How It Works, Reminder Setup screens
    settings/       # Theme toggle, reminder time picker, data export
  shared/
    widgets/        # MainShell (PageView nav), reusable components
```

---

## Core principles

- **Privacy-first** — 100% local storage. No analytics, no tracking, no network calls.
- **Frictionless** — Mood check-in in under 10 seconds.
- **Calm aesthetic** — Soft warm palette, serif typography, minimal chrome.

---

## Milestones

| # | Milestone | Status |
|---|---|---|
| 1 | Foundation — project setup, SQLite DB, routing, theming | Done |
| 2 | Mood check-in — emoji selector, note field, upsert, home status | Done |
| 3 | Journal entries — full-text editor, auto-save, past entries list | Done |
| 4 | History & charts — calendar grid, trend line, streak, stats | Done |
| 5 | Reminders — daily notification, permission flow, settings toggle | Done |
| 6 | Polish & release prep — data export, app icon, accessibility, QA | In progress |

---

## Android notes

- `minSdkVersion 21` (Android 5.0+)
- Requires `SCHEDULE_EXACT_ALARM` permission for daily reminders (API 31+)
- On MIUI (Xiaomi): enable **Autostart** and set battery saver to **No restrictions** for reliable notification delivery

---

## Post-MVP ideas

- Optional cloud backup (iCloud / Google Drive)
- Mood tags and categories
- AI-generated insights using the Claude API
- Home screen widget for quick check-in
- Passcode / biometric lock
- Export to formatted PDF journal
