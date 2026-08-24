# Privacy Policy — BHAKTi

**Last updated:** August 2026

## Short version

Chanting works entirely on your device. Nothing leaves your phone unless you
turn on **Backup & Sync** in Settings, which is off by default.

## What is stored on your device

Your jap counts, daily history, streaks, selected deity, and app preferences are
stored locally on your phone. Audio plays from assets bundled with the app.

## What is stored in the cloud (only if you turn Backup & Sync on)

If you enable Backup & Sync, the app creates an **anonymous account** — there is
no email, phone number, name, or password involved, and you are never asked to
sign in. A random identifier is generated for your device and used to store a
copy of:

- your jap counts, daily history, and streaks, per deity
- your app preferences (daily goal, language, sound and haptic settings, and
  similar)

That copy is stored with Google Firebase (Firebase Authentication and Cloud
Firestore). It exists so your practice survives losing or replacing your phone.

We do not store your name, email, phone number, contacts, or any
device advertising identifier. There is no analytics SDK, no advertising SDK,
and no third-party tracking.

## Kundali and chart chat

If you open **Kundali**, the birth date, time, and city you enter are sent to
our Firebase backend so it can call Prokerala. Those details are stored on your
phone and, after a draw, on your anonymous Firebase user document. They are not
mixed into jap backup. The Prokerala key never sits in the app.

Chart chat is answered from that kundli (dosha, dasha, daily rashifal). It is
not a live astrologer. Paid unlock (₹299) waits on store billing.

## Turning it off and deleting your data

Settings → Backup & Sync → **Delete cloud backup** removes the cloud copy and
turns sync off. Data on your phone is left untouched. Uninstalling the app
removes the local copy.

## Permissions

The published Android build requests network access only, and only so optional
backup can work. Location permissions are explicitly stripped from the release
build.

## Contact

Add your real support email here and in the store listings before publishing.
