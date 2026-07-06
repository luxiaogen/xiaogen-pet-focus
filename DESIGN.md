---
name: FocusPet Cozy Companion Glass
version: alpha
description: Warm, playful glassmorphism design system for a native macOS Pomodoro companion featuring animated pets. Balances focused calm with joyful celebration moments. Bilingual (EN/ZH) friendly.

colors:
  # Semantic surfaces (glass layers)
  surface: "#F8F6F2"
  surface-dim: "#F0EDE6"
  surface-bright: "#FFFBF6"
  surface-container-lowest: "#FFFFFF"
  surface-container-low: "#F7F4EE"
  surface-container: "#F1EDE5"
  surface-container-high: "#EAE6DE"
  surface-container-highest: "#E3DFD6"
  on-surface: "#2C2924"
  on-surface-variant: "#5C5650"
  outline: "rgba(0,0,0,0.12)"
  outline-variant: "rgba(0,0,0,0.06)"

  # Primary action / focus accent (tomato)
  primary: "#E85A3C"
  on-primary: "#FFFFFF"
  primary-container: "#FAD9CF"
  on-primary-container: "#3D1F18"

  # Secondary / break accent (sage green)
  secondary: "#6E8B5C"
  on-secondary: "#FFFFFF"
  secondary-container: "#D9E8D1"
  on-secondary-container: "#2E3C26"

  # Tertiary / celebration (gold)
  tertiary: "#C9A227"
  on-tertiary: "#2C2414"
  tertiary-container: "#F5E8B8"
  on-tertiary-container: "#3F3214"

  # Legacy warm neutrals (still used for backgrounds)
  focus-cream: "#FFF5E3"
  focus-mist: "#DBE3D1"
  focus-blush: "#FAD1C2"
  focus-ink: "#2E2A23"

typography:
  display-lg:
    fontFamily: system
    fontSize: 76px
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: system
    fontSize: 28px
    fontWeight: 700
    lineHeight: 1.15
  headline-md:
    fontFamily: system
    fontSize: 21px
    fontWeight: 700
    lineHeight: 1.2
  title-lg:
    fontFamily: system
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.25
  body-lg:
    fontFamily: system
    fontSize: 15px
    fontWeight: 500
    lineHeight: 1.4
  body-md:
    fontFamily: system
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.35
  label-md:
    fontFamily: system
    fontSize: 12px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 0.01em
  label-sm:
    fontFamily: system
    fontSize: 11px
    fontWeight: 600
    lineHeight: 1.1

rounded:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 22px
  full: 9999px

spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 18px
  xl: 24px
  xxl: 32px
  page: 32px
  card-padding: 22px
  card-gap: 18px
  section: 24px

components:
  glass-card:
    backgroundColor: "{colors.surface-container-low}"
    rounded: "{rounded.xl}"
    padding: "{spacing.card-padding}"
    # Realized on macOS via material + gradient overlays + 1.2px border
  glass-card-elevated:
    backgroundColor: "{colors.surface-container}"
    rounded: "{rounded.xl}"
    padding: "{spacing.card-padding}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-md}"
    rounded: "{rounded.lg}"
    padding: "14px 28px"
    height: 44px
  button-secondary:
    backgroundColor: "{colors.surface-container-high}"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-md}"
    rounded: "{rounded.lg}"
    padding: "12px 18px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.on-surface}"
    typography: "{typography.label-md}"
    rounded: "{rounded.lg}"
    padding: "10px 16px"
  tab-item:
    rounded: "{rounded.md}"
    padding: "10px 12px"
  pet-container:
    rounded: "{rounded.full}"
    # soft ring + subtle shadow defined in elevation
  progress-ring:
    # thickness and gradient handled in code using primary/secondary colors
  queue-row:
    rounded: "{rounded.md}"
    padding: "7px 10px"
  stat-tile:
    backgroundColor: "{colors.surface-container-low}"
    rounded: "{rounded.lg}"
    padding: "{spacing.lg}"
  soft-panel:
    backgroundColor: "rgba(255,255,255,0.06)"
    rounded: "{rounded.md}"
    padding: 12px
---

## Overview

FocusPet is a native macOS Pomodoro companion that pairs deep-focus timing with a delightful, living pet widget. The design system evokes **warmth, calm focus, and gentle celebration**.

The personality is:
- Cozy and approachable (soft rounded forms, warm neutrals, pet companions).
- Quietly professional during focus (clean glass surfaces, high legibility, minimal chrome).
- Joyful on completion (gold accents, confetti, upbeat micro-interactions).

Glassmorphism is the core surface language: frosted, layered panels that sit lightly over a soft cream-to-mist gradient background. Depth comes from material, subtle tonal shifts, and very soft ambient shadows rather than heavy drop shadows.

The interface is fully bilingual (English / Chinese) and must feel equally natural in both languages. Pet illustrations and sprites are first-class citizens — charming but never distracting from the timer or tasks.

Two themes exist:
- Warm Orange (default tomato/sage/gold focus palette)
- Forest Green (calmer mint-forest variant)

## Colors

The palette is built around three purposeful accents on a warm, low-contrast neutral foundation:

- **Primary (focus tomato)**: Drives the main timer ring, primary actions, and active states. Energetic but not aggressive.
- **Secondary (break sage)**: Calming counterpoint for break mode and secondary actions.
- **Tertiary (celebration gold)**: Used sparingly for completion states, milestones, and delight moments.

Glass surfaces use a narrow range of warm off-whites and creams with low-opacity overlays to produce the frosted effect. Text is high-contrast warm ink for readability on glass.

Semantic surface/container roles follow the DESIGN.md convention so future extensions (more themes, dark mode explorations) stay consistent.

## Typography

System fonts with the rounded design variant are used throughout for friendliness.

- Large timer display uses bold weight and tight tracking for instant readability at a glance.
- Headlines are bold and rounded to establish hierarchy without shouting.
- Body and labels stay medium weight for calm density on a desktop dashboard.
- All text respects the bilingual nature; Chinese benefits from the same generous line heights as English.

## Layout & Spacing

An 8 px (with 4 px micro) spacing scale provides rhythm.

- Desktop dashboard uses generous outer page padding (32 px) and card gaps (18–24 px) so the interface breathes.
- Content is grouped in soft glass cards with 22 px internal padding.
- Two-column layout on wide screens; graceful collapse to stacked scrolling on narrower windows.
- Bottom tab bar is compact but touch-friendly with clear active states.

Negative space is intentional — the pet and timer should feel like calm objects in a quiet room.

## Elevation & Depth

Depth is created through **layered glass** rather than dark shadows:

- Base window: soft cream/mist gradient + window material.
- Standard cards: regularMaterial + warm tint overlay + 1.2 px gradient border + very soft 8–12 px shadow.
- Elevated / focused elements: slightly higher material or stronger tint + slightly larger shadow.
- The floating pet widget uses a minimal, borderless, always-on-top panel with its own subtle glass treatment.

All glass elements maintain a light top-left “shine” gradient to reinforce the crystalline quality.

## Shapes

Soft, friendly rounded corners mirror the organic feeling of the pets.

- Cards and major containers: xl (22 px)
- Buttons and queue rows: lg (16 px)
- Smaller controls and tabs: md (12 px)
- Pet rings and floating widget: full / near-full circles
- Micro elements: sm (8 px)

No hard rectangles or sharp 0-radius shapes in the main interface.

## Components

### Glass Cards & Panels
Use `glass-card` and `glass-card-elevated` tokens. Always combine with the appleGlassSurface modifier (or equivalent) that applies material, warm-tinted gradient overlay, border, and soft shadow.

### Buttons
- Primary: solid accent color, white text, generous horizontal padding.
- Ghost / secondary: low-opacity or container backgrounds.
- All buttons have consistent press scale (0.97–0.98) and 150–200 ms ease animations.
- Quick duration chips and mode pills follow the same language at smaller scale.

### Timer & Progress
The circular progress ring uses the current mode’s accent (primary/secondary/gold) with a soft white highlight on the leading edge. The large editable timer display is the single most important piece of typography.

### Pet Containers
Pet artwork lives inside a soft circular glass frame with a thin colored ring that matches the current Pomodoro mode. Hover and tap states add gentle scale + burst particles without breaking the calm.

### Lists & Queues
Task rows use soft container backgrounds, clear selection states (colored background + check), and drag affordances. Hover reveals delete on custom tasks only.

### Tabs (Bottom Navigation)
Pill-shaped items with icon + short label. Active state uses the current accent color at low opacity fill + solid text/icon color.

## Do's and Don'ts

**Do**
- Keep the pet delightful but secondary to the timer and tasks.
- Use the three accent colors strictly according to mode (focus tomato, break sage, celebration gold).
- Maintain generous breathing room around the big timer and the pet.
- Support both languages equally — test label lengths.
- Let glass layers feel light; avoid heavy borders or dark overlays.
- Use the exact spacing and radius tokens from this file.

**Don't**
- Introduce new hard-coded pixel values for padding, radius, or gaps.
- Use sharp corners or heavy drop shadows outside the defined glass recipe.
- Make the pet animation so busy that it competes with focus.
- Add extra chrome (dividers, heavy lines) between cards unless explicitly defined in a component.
- Change the fundamental bottom-tab navigation pattern without updating this DESIGN.md.
- Let celebration gold leak into focus or break states.

This DESIGN.md is the source of truth. When in doubt, read the prose first, then the tokens.
