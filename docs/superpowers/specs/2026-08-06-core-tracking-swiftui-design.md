# Core Habit Tracking — SwiftUI Rewrite (v1)

## Context

This is a from-scratch native iOS rewrite of the Habit Tracker, previously built in React Native/Expo (`recipe-parser` repo, misnamed directory — actual project is a habit tracker). The RN app is left as-is; this is a brand new repo, not a migration in place.

`CONTEXT.md` and `docs/adr/0001-removing-a-habit-rescues-the-streak.md` are carried over unchanged as the domain source of truth. `ADR 0002` (MMKV + App Group storage) was **not** carried over — it's an implementation decision tied to the RN/MMKV stack and doesn't apply once we're on SwiftData. A new ADR for storage may be written later if the widget work (deferred, see Non-goals) needs an App Group container.

## Scope

v1 covers **core tracking only**: add a habit, mark done/not-done for today, archive (remove) a habit, view current streak. Reminders and the home-screen widget are explicitly out of scope for v1 and will be separate follow-on specs once this core is solid.

## Platform

- iOS 18+, Swift, SwiftUI
- `@Observable` view model + MVVM — no external architecture framework
- SwiftData for persistence, default (non-App-Group) container

## Domain model (SwiftData)

Direct port of the existing `HabitStore` (`src/habit-store/habit-store.ts`) and `day.ts` from the RN app:

- `DayKey`: a `"yyyy-MM-dd"` string computed from `Calendar.current` local date components (year/month/day of the device's local timezone). No custom rollover cutoff — local midnight boundary only, matching `CONTEXT.md`'s "Day" definition.
- `Habit` (`@Model`): `id: UUID`, `name: String`, `status: HabitStatus` (`active` / `archived` enum), `createdDay: String` (DayKey), `archivedDay: String?` (DayKey)
- `Completion` (`@Model`): `habitId: UUID`, `day: String` (DayKey), `done: Bool` — one row per habit per day that's been explicitly toggled (absence of a row means not-done, mirroring the RN store's `Map` default)

## Core operations

Ported 1:1 from `HabitStore`:

- `addHabit(name:)` — creates an active `Habit` with `createdDay = today`
- `toggleDone(habitId:)` — flips today's `Completion.done` for the habit (creates the row if absent)
- `archiveHabit(id:)` — sets `status = .archived`, `archivedDay = today`; history (past `Completion` rows) is preserved, never deleted
- `activeHabits` — habits where `status == .active`
- `streak` — walk backward day-by-day from today while every habit "active on that day" (created on or before that day, and either never archived or archived after that day) has `done == true` for that day. A day with zero active-on-that-day habits is skipped without breaking or extending the count. Stop at the first non-perfect day or when passing the earliest habit's `createdDay`.
  - This is a direct port of `getStreak`/`#habitsActiveOnDay`, including the semantics behind ADR 0001: because "active on day" is evaluated from current `archivedDay` state rather than a historical per-day log, archiving an incomplete habit before day's end rescues that day's streak, same as today.
  - Recommendation (accepted): compute this as a plain O(days since earliest habit) scan on read, not a cached/incremental value. This matches the original implementation and is appropriate for a personal, single-user app — no need for the added complexity of cache invalidation.

## UI (v1)

Single screen, SwiftUI port of `HomeScreen.tsx`:

- Title + streak indicator (🔥 count)
- Add-habit row: text field + add button, trims whitespace, no-op on empty
- List of active habits, each row:
  - Tap toggles done/not-done (checkbox-style, strikethrough + dimmed name when done)
  - Remove action triggers a confirmation alert ("Remove '<name>'? Its history will be kept.") before archiving
- `@Observable` view model wraps a `ModelContext`-backed store, exposing `activeHabits`, `streak`, `addHabit`, `archiveHabit`, `toggleDone` — same surface as `use-habit-store.ts`

## Non-goals for v1

- No reminder notifications (was `src/reminder/*` in the RN app)
- No home-screen widget, no App Group container
- No settings, theming, or onboarding beyond what's described above

## Testing

- Unit tests for the store: add/toggle/archive behavior, and streak edge cases (empty state, zero-active-habit days, archive-rescues-streak per ADR 0001) — mirroring `habit-store.test.ts`
- Unit tests for `DayKey` computation and comparison — mirroring the coverage implied by `day.ts`
- Tests run against an in-memory `ModelContainer`, no on-disk state
