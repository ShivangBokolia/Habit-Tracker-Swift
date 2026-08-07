# Habit Tracker

A mobile app for tracking daily habits, with home-screen widget support for quick completion and reminders for incomplete habits.

## Language

**Habit**:
A user-defined item tracked once per day with a binary done/not-done state. Applies every day; there is no per-habit scheduling.
_Avoid_: Task, routine

**Active Habit**:
A Habit currently included in daily tracking, the widget, reminders, and streak calculation.

**Archived Habit**:
A Habit the user has removed. Its past completion history is preserved, but it no longer appears in the widget, reminders, or streak calculation.
_Avoid_: Deleted habit

**Day**:
The local midnight-to-midnight period a Habit's completion is tracked against. There is no custom rollover cutoff.

**Reminder**:
A single daily digest notification, fired at a fixed time, that alerts the user only if at least one Active Habit is still not-done for the Day.
_Avoid_: Notification (too general — Reminder is the specific domain concept)

**Streak**:
The count of consecutive Perfect Days. Only the current count is tracked; there is no all-time record.

**Perfect Day**:
A Day on which every Habit active at that Day's end was marked done. A Day with zero active Habits is excluded from the Streak calculation — it neither extends nor breaks it.
