# Prokerala kundli and chart chat

Navamsha stays **panchang only**. Kundali, daily rashifal, and chart questions
go through Prokerala, still behind a trusted backend. The Flutter app never
holds `PROKERALA_CLIENT_ID` or `PROKERALA_CLIENT_SECRET`.

Prokerala has no live-astrologer endpoint. Chat answers are pulled from kundli,
mangal dosha, kaal sarp, sade sati, dasha, and daily prediction. The ₹299 paid
gate is wired in copy and in the function payload (`chatPriceInr`); store
billing is the remaining step.

## One-time setup

1. Create an app at https://api.prokerala.com/account/client
2. Copy client id and secret into Firebase secrets (not the repo):

   ```bash
   firebase functions:secrets:set PROKERALA_CLIENT_ID
   firebase functions:secrets:set PROKERALA_CLIENT_SECRET
   ```

3. Deploy functions (Blaze required):

   ```bash
   cd functions && npm install
   firebase deploy --only functions
   ```

Region is `asia-south1`. Callables: `drawHoroscope`, `askHoroscope`.

Local emulator: copy `functions/.env.example` to `functions/.env.local` and run
`firebase emulators:start --only functions`. Do not use `functions/.env` —
Firebase would upload those names as plain env vars and they collide with the
secrets.

## What the app does

- Calendar card opens the kundali form (date, time, Indian city).
- `drawHoroscope` calls `GET /v2/astrology/kundli` (Lahiri, `la=hi` when Hindi).
- Chart is cached in Hive and under `users/{uid}/astrology/reading`.
- Chat routes the question to the matching Prokerala path. Daily rashifal costs
  more credits (250) than a kundli (50) — only asked when the user asks today.

Birth details are **not** mixed into jap backup. They live in Hive and, after a
draw, on the user's own Firestore astrology docs.
