# Vrat & panchang content

## How the Calendar screen gets its data

Content loads in two layers:

1. **Bundled** — `assets/content/vrats.json`, shipped in the app. Always
   available, works offline, and is the floor the screen can never fall below.
2. **Cloud overlay** — the Firestore `vrats` collection, merged over the bundled
   copy by document id. Cached in Hive after the first fetch, so it works
   offline from the second launch onward.

The overlay exists for one reason: **panchang dates cannot be computed and must
not be guessed.** Correcting a date should not require an app update, a Play
review, and a user updating.

## What ships with dates and what does not

| Kind | Date source | Trustworthy today? |
|---|---|---|
| `weekly` | Computed from `weekday` (1=Mon … 7=Sun) | Yes — always correct |
| `tithi` | Requires a `date` you supply | No date shipped |
| `festival` | Requires a `date` you supply | No date shipped |

The seven weekly vrats — Somvar through Ravivar — are complete with katha, vidhi,
and muhurat in both languages, and resolve locally. That means the Calendar
screen is useful on day one without any panchang data at all.

The tithi vrats (Ekadashi, Purnima, Amavasya, Pradosh, Sankashti Chaturthi) ship
with their katha and vidhi but **deliberately no dates**. They appear under
"Vrats & observances" without a date rather than with a wrong one. A test
enforces this:

```
test('no tithi vrat ships with a guessed date', ...)
```

If you ever hardcode a tithi date into the bundled asset, that test fails on
purpose. Dates belong in Firestore.

## Adding dates

Create one document per occurrence in the `vrats` collection. The document id
is what ties an occurrence to its content, so use a dated id for occurrences:

```
vrats/ekadashi-2026-09-12
```

```json
{
  "kind": "tithi",
  "date": "2026-09-12",
  "nameEn": "Parivartini Ekadashi",
  "nameHi": "परिवर्तिनी एकादशी",
  "deityId": "krishna",
  "summaryEn": "Ekadashi of the bright fortnight of Bhadrapada.",
  "summaryHi": "भाद्रपद शुक्ल पक्ष की एकादशी।"
}
```

Merging happens per id, and fields you omit fall back to the bundled entry with
that exact id. So there are two patterns:

- **Reuse the base id** (`vrats/ekadashi` with just a `date` added) to inherit
  the bundled katha, vidhi, and muhurat. Good for the next occurrence only,
  since one id holds one date.
- **Use a dated id** (`vrats/ekadashi-2026-09-12`) to list many occurrences.
  These do not inherit, so include the katha and vidhi you want shown.

Field names match `assets/content/vrats.json` exactly. Valid `deityId` values
are `ram`, `krishna`, `mahadev`, `ganesh`, `durga`, `hanuman`; a test asserts
every reference resolves against `DeityCatalog`.

Rules already allow this: `vrats` is public-read and client-write-denied, so add
documents from the Firebase console or a trusted backend, never from the app.

## Sourcing the dates

This is the accuracy risk flagged in the plan, and it is a real one — a single
wrong muhurat or vrat date undoes the "daily home screen" positioning the whole
product rests on. Two options:

- **Manual, from a published panchang.** Cheap, and fine for a first pass. One
  year of Ekadashi, Purnima, Amavasya, Pradosh, and Sankashti is roughly 100
  documents.
- **Navamsha** — the live path. A local sync script calls
  `POST /api/v1/astrology/panchang` with the key on a trusted machine and writes
  `panchang/{yyyy-MM-dd}`. The app derives dated tithi vrats from that cache
  plus the bundled templates. See `docs/NAVAMSHA.md`. The key must never ship
  in the app bundle.

Until the sync has run, the screen stands on the weekly vrats, which is honest
and still useful.

## The prasadam stub

`PrasadamInterestCard` records taps and nothing else — no cart, no fulfilment.
The count lives in Hive under `prasadam_interest_taps` and rides along in the
synced settings snapshot, so with Backup & Sync on it appears per user in
`users/{uid}.settings`, readable from the Firestore console.

That is the demand signal the plan asks for before committing to any logistics.
Watch it before building a commerce line, not after.
