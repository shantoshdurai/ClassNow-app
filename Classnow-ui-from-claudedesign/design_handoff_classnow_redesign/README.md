# Handoff: ClassNow Redesign (Flutter)

## Overview
Two new design directions for the ClassNow student timetable app (Flutter). Target screens:
1. **Dashboard / Today** — the home screen after login
2. **Home-screen Widget** (Android, small + medium sizes)
3. **Profile / Settings**

The goal is to replace the current generic Material-purple UI with a considered, premium system that puts the *current class* front and centre.

## About the Design Files
The files in this bundle are **design references created in HTML + React/JSX** — prototypes showing the intended look, layout, and behaviour. They are **not production code to copy**. Your job is to **recreate these designs in the existing Flutter codebase** using its patterns (`app_theme.dart`, the existing `screens/` and `widgets/` structure, `google_fonts`, native Android `AppWidgetProvider` for home-screen widgets, etc.).

Two variations are provided so you can pick one — or blend them. Do not ship both.

## Fidelity
**High-fidelity.** All colors, type ramps, spacing, and radii are finalized. Recreate pixel-perfectly in Flutter.

---

## Variation A — "Paper" (editorial light)
Warm off-white paper, deep ink black, single amber accent. Fraunces serif for display headings, Inter for body, JetBrains Mono for times and codes. Timeline view (vertical spine + dots + mono times) instead of equal cards.

### Paper · Design Tokens

| Token | Value |
|---|---|
| `bg` | `#F6F2EA` |
| `paper` (surface) | `#FBF8F1` |
| `ink` (primary text) | `#15130F` |
| `ink2` (secondary) | `#3C382F` |
| `muted` | `#7D7668` |
| `faint` | `#D9D2C2` |
| `line` (hairline) | `#E7E1D2` |
| `accent` | `oklch(62% 0.18 48)` ≈ `#D97D3A` |
| `accentSoft` | `oklch(94% 0.04 48)` ≈ `#F3E9DD` |
| `accentInk` | `oklch(35% 0.12 48)` ≈ `#6E3510` |

### Paper · Typography
- **Display / hero titles**: Fraunces, 500 weight, letter-spacing -0.4 to -1.0. Sizes 24 / 28 / 44.
- **Body / UI**: Inter, 400/500/600. Sizes 12 / 14 / 16.
- **Time / mono / code**: JetBrains Mono, letter-spacing 0.4–1.8, used for class times ("10:10"), codes ("CS31"), and uppercase labels ("TODAY", "IN SESSION · 28M LEFT").

### Paper · Radii & shadows
- Cards: 18px
- Big surfaces (week strip, profile hero): 22–24px
- Bottom nav: 22px
- Soft shadow: `0 12px 24px -18px rgba(0,0,0,0.25)`

---

## Variation B — "Glass" (dark premium)
Graphite black with aurora radial gradients, glass cards with 1px white-alpha borders and backdrop-blur, Geist display. The *Now Playing* class is a glowing hero card with a live progress bar.

### Glass · Design Tokens

| Token | Value |
|---|---|
| `bg` | `#08090D` |
| `bg2` | `#0E1016` |
| `surface` | `rgba(255,255,255,0.04)` |
| `surface2` | `rgba(255,255,255,0.06)` |
| `border` | `rgba(255,255,255,0.08)` |
| `border2` | `rgba(255,255,255,0.14)` |
| `ink` | `#F4F5F7` |
| `ink2` | `#B8BAC2` |
| `muted` | `#6C6F79` |
| `accent` | `oklch(72% 0.18 230)` ≈ `#3BA9FF` |
| `accent2` | `oklch(78% 0.22 210)` ≈ `#4FD1FF` |
| `accentGlow` | `oklch(72% 0.18 230 / 0.5)` |

### Glass · Aurora background
Three radial-gradient blobs (blue, magenta, cyan) blurred 20px, plus a faint dot-grid at 9% opacity. See `lib/glass-dashboard.jsx` `Aurora()`.

### Glass · Typography
- **Display**: Geist 600, letter-spacing -0.3 to -0.8. Hero class title: 30px.
- **Body**: Inter.
- **Mono**: JetBrains Mono for times, labels, and subtle uppercase tags.

### Glass · Radii & shadows
- Cards: 18–24px.
- Now card: 24px, glow `0 24px 48px -24px accentGlow` + inset `0 0 0 1px rgba(255,255,255,0.02)`.
- Bottom nav: 22px, glass (`rgba(12,14,20,0.75)` + `backdrop-filter: blur(24px)`).

---

## Screen 1 — Dashboard / Today
**Purpose**: see what class is on now, what's next, and today's full schedule at a glance.

### Shared structure (both variants)
1. Status bar (handled by OS)
2. Header row: left = avatar + greeting (Glass) or "Today · Tuesday, 21" serif (Paper); right = search + bell (with unread dot)
3. Week strip: 6 days (Mon–Sat). Current day highlighted (ink pill on Paper, gradient glow on Glass). Weekend dimmed.
4. **Now section** — Paper: inline in timeline with a ringed dot; Glass: a full hero card with gradient progress bar and countdown.
5. Schedule — Paper: full-day timeline (spine + mono times + dots + serif titles). Glass: hero card + compact list of remaining classes.
6. Stats (Glass): Streak + Attendance chips; (Paper): 3-column stat strip (Classes / Left today / Attendance).
7. Floating bottom nav: Today · Week · Rooms · Me.

### Class row content
- Title, mentor name, room, course code, start + end time.
- States: `done` (struck-through, 55% opacity), `now` (hero treatment + pulsing dot + progress %), `next` (bordered pill "Up next"), `later` (plain), `break` (divider with "Break · 15m").

See `lib/paper-dashboard.jsx` `PaperDashboard` and `lib/glass-dashboard.jsx` `GlassDashboard` for the full structure.

---

## Screen 2 — Home-screen Widget
**Purpose**: at-a-glance current/next class on the Android home screen, without opening the app.

Two sizes per variant:

### Medium widget (2x2 / 4x2)
- Status pill: pulsing dot + "IN SESSION" label + "28m left"
- Class title (serif / Geist, 20px)
- Mentor · Room · code line
- Progress bar 4–6px, gradient on Glass
- Divider + "Next · Computational Intelligence · 11:15"

### Small widget (2x2)
- Tiny status pill
- 14px bold class name
- "Rm 704 · 10:10–11:00" mono line

### Implementation notes (Android)
- Use `home_widget` Flutter plugin OR native `AppWidgetProvider` with `RemoteViews`.
- **Dynamic text + progress can't use `backdrop-filter`**; fake the glass with a semi-opaque dark RGB + a baked radial gradient PNG for the glow.
- Text: render Fraunces/Geist as PNGs if font fallbacks are ugly, OR use Android's Roboto as fallback and document that.

See `lib/widgets.jsx` for exact layout.

---

## Screen 3 — Profile / Settings
**Purpose**: see user stats, manage class reminders, theme, account.

### Content structure (both variants)
1. Top bar: back button, "PROFILE" label, settings gear / share
2. **Profile hero card**: avatar tile (initials on gradient — `AR`), name (serif/Geist display), "22CSA117 · B.Tech CSE (AI)" mono, year badge (Glass only), and a stats strip:
   - Paper: 3rd Year · 18 Day streak · 87% Attendance
   - Glass: Streak · Attendance · GPA (as three mini cards with icons)
3. **Section: Schedule** — Class reminders (toggle, "15 min before"), Auto-sync MyCamu (toggle, last synced), Default block / room map
4. **Section: Appearance** — Theme, Home widget config, In-class do-not-disturb (Glass) / Display density (Paper)
5. **Section: Account** — Edit profile, Privacy, Sign out
6. Version footer: `ClassNow · v3.2.1`

Rows: icon tile (34×34, rounded 10) + title + meta line + trailing chevron or custom toggle.

See `lib/settings.jsx` for exact structure.

---

## Interactions & Behavior
- Day strip tap → switch schedule day (no animation needed beyond default).
- Now card: progress bar updates every minute. Countdown in minutes when < 60, "1h 12m" above.
- Directions button (Paper now card) → Google Maps deep link to the block+room.
- Notes button → existing notes screen.
- Bell icon → notifications list (route already exists).
- Toggles: 200ms ease.
- Home widget: refresh every 15 min via `WorkManager` + on boot.

## State requirements
- Current time (minute-resolution) → tick via `Timer.periodic` or `StreamProvider`.
- Schedule for selected day from Firestore (existing `schedule_service`).
- User profile (name, handle, program, streak, attendance %).
- Theme: `paper` | `glass` (persisted via `shared_preferences` + `theme_provider.dart`).

## Assets
- No new image assets required. Avatars are initials-on-gradient. Icons are all stroke SVGs (see `lib/icons.jsx`) — recreate as Flutter `CustomPaint` or replace with `lucide_icons` / `phosphor_flutter`.
- Fonts: use `google_fonts`: Fraunces, Geist, Inter, JetBrains Mono.

## Files in this bundle
- `ClassNow Redesign.html` — master reference page (open in a browser after opening the folder in your editor; it pulls the lib/ files)
- `ClassNow Redesign-print.html` — standalone single-file version (inlined JSX), useful to open anywhere without a local server
- `lib/icons.jsx` — stroke icon set with definitions
- `lib/data.jsx` — mock schedule, user, day-strip data
- `lib/android-frame.jsx` — Android device bezel + status bar (ignore, visual-only)
- `lib/paper-dashboard.jsx` — **Paper dashboard + bottom nav + status bar**
- `lib/glass-dashboard.jsx` — **Glass dashboard + Aurora + bottom nav**
- `lib/settings.jsx` — **Paper + Glass settings**
- `lib/widgets.jsx` — **Paper + Glass home-screen widgets (small + medium) + homescreen backgrounds**
- `ref/` — original screenshots of the current app for before/after comparison

## Recommended approach
1. Pick a variant (my recommendation: **Glass** for "wow" factor, **Paper** if your audience skews toward calm / reading).
2. Port tokens to `app_theme.dart` as a `ThemeExtension<ClassNowTokens>`.
3. Rebuild the dashboard first — that single screen carries most of the system. Week strip, Now card, timeline.
4. Then widgets (Android-only first; iOS widgets need a separate SwiftUI target).
5. Then settings.
6. Ship both themes behind the existing `ThemeProvider` if you want light/dark toggle.
