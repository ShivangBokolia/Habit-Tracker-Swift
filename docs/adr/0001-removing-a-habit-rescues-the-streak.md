# Removing an incomplete Habit rescues that day's streak

A Perfect Day is evaluated from the set of Habits active at the *end* of the Day, not from a log of every state a Habit passed through during the Day. So if a user removes a Habit before the Day ends without having marked it done, that Day is judged as if the Habit was never part of the active set — the Streak is not broken.

We considered instead recording "was incomplete at some point today" per Habit, so deleting an unfinished Habit couldn't rescue the streak. We rejected this: it requires tracking historical activation state per Habit per Day just to prevent a minor form of self-gaming in what is a personal, unshared habit tracker. Simplicity won.
