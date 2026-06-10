# FocusPet

FocusPet is a native macOS Pomodoro desktop companion built with SwiftUI and a small AppKit bridge. It provides a glassmorphism main dashboard, a floating desktop pet widget, bilingual UI copy, and switchable panda/cat companions.

## Features

- Native SwiftUI macOS app with adaptive light/dark glass styling.
- Pomodoro focus and break timer with circular progress ring.
- Main dashboard with sidebar navigation, task picker, pet selector, and language toggle.
- Floating pet mode using a transparent always-on-top AppKit panel.
- Panda and cat vector pets with focus, break, and celebration states.
- English and Chinese UI switching.

## Requirements

- macOS 14 or newer.
- Swift Package Manager from Apple Command Line Tools or Xcode.

## Build

```bash
swift build
```

## Run

Use the project run script so the SwiftPM executable is staged as a macOS `.app` bundle before launch:

```bash
./script/build_and_run.sh
```

Verify the app launches:

```bash
./script/build_and_run.sh --verify
```

The Codex desktop Run action is wired to the same script through `.codex/environments/environment.toml`.

## Project Structure

```text
Sources/FocusPet/
  App/        App entry point and app delegate
  Models/     Pet, timer mode, language, and sidebar enums
  Stores/     TimerStore app state and Pomodoro timer logic
  Services/   AppKit floating window controller
  Support/    Shared colors and window accessor helpers
  Views/      Dashboard, sidebar, pet, ring, and widget views
```

## Notes

- The app does not depend on remote images or web assets.
- The floating widget is intentionally handled by AppKit because SwiftUI does not directly expose all borderless always-on-top panel behavior.
- Detailed statistics, persistence, notifications, and sound effects are outside the current MVP.
