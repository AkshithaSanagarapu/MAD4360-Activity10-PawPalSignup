# PawPal Signup — MAD 4360 Activity 10

## Track and tasks

- Track: Graduate
- Required feature: Task A — Local Signup Coach
- Extension: Task C — Confirm & Celebrate
- App concept: PawPal, a community for people interested in pet adoption
- Student: Akshitha Sainath Sanagarapu
- Panther ID: 003027780
- Partner: [Add your partner's name, if this is a pair submission]

## App overview

PawPal has a signup form with full name, email address, password, and confirm password fields. Each field has local validation. If all values are valid and the passwords match, the app opens a welcome page that uses the entered name. The app does not create or store an account.

The signup tip feature uses the fixed `password_help` category and preset text stored in the app. It shows a brief loading state, displays a tip as plain text, and handles a missing or empty tip list with an error and Retry button. The tip button cycles through the available local tips. It does not read any form values and makes no network requests. The interface labels the text as a preset local sample, not live AI output.

## Run the app

1. Start an Android emulator or connect an Android device.
2. From this project folder, run:

   ```bash
   flutter pub get
   flutter devices
   flutter run