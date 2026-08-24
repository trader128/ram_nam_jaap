# Navamsha panchang

Navamsha is the source of civil dates for tithi vrats (Ekadashi, Purnima,
Amavasya, Pradosh, Sankashti). Weekly vrats still resolve on-device and do not
need this.

The Flutter app **never** holds `NAVAMSHA_API_KEY`. A trusted machine calls the
API once and writes `panchang/{yyyy-MM-dd}` in Firestore. Every install then
reads that shared collection.

## One-time setup

1. Keep the key in this shell only — do not paste it into the repo, chat, or
   `firebase_options.dart`.

   ```bash
   export NAVAMSHA_API_KEY='…'
   ```

   Or put the same line in `tool/navamsha/.env` (gitignored).

2. Deploy rules so clients can read `panchang` but cannot write it:

   ```bash
   firebase deploy --only firestore:rules
   ```

3. For the write step, sign in with a Google account that can edit
   `bhakti-sawarun`:

   ```bash
   gcloud auth application-default login
   cd tool/navamsha && npm install
   ```

## Run

Probe first — one Ujjain day, JSON printed, Firestore untouched:

```bash
node tool/navamsha/sync.mjs --probe
```

Then write the next 45 days:

```bash
node tool/navamsha/sync.mjs
```

`--dry-run` fetches the horizon without writing. `--days N` changes the length.

Default place is Ujjain (23.1765 N, 75.7885 E, timezone 5.5) at 6:00, Lahiri
ayanamsha. The app maps English limb names to Hindi.

## Keep it fresh

The app only reads Firestore. If nobody re-runs this script, tithi dates go
stale after the 45-day window.

**GitHub Actions (preferred)** — `.github/workflows/panchang-sync.yml` runs
every Monday at 06:00 IST, and whenever you click **Run workflow**.

Add two repository secrets (Settings → Secrets and variables → Actions):

| Secret | Value |
|---|---|
| `NAVAMSHA_API_KEY` | Navamsha dashboard key |
| `FIREBASE_SERVICE_ACCOUNT` | Full JSON of the Firebase Admin SDK key file |

From this machine:

```bash
gh secret set NAVAMSHA_API_KEY
gh secret set FIREBASE_SERVICE_ACCOUNT < "$GOOGLE_APPLICATION_CREDENTIALS"
```

`npm ci` in CI needs `tool/navamsha/package-lock.json` committed.

**This Mac** — if the laptop is on Monday morning:

```bash
# tool/navamsha/.env must contain NAVAMSHA_API_KEY and GOOGLE_APPLICATION_CREDENTIALS
chmod +x tool/navamsha/install-weekly.sh
./tool/navamsha/install-weekly.sh
```

## What the app does with it

- `PanchangRepository` reads Firestore, caches in Hive, never calls Navamsha.
- `NavamshaPanchangParser` flattens the vendor `output` blob.
- `PanchangVratMerger` clones bundled tithi templates onto matching dates
  (`ekadashi-2026-09-12`). Bundled `vrats.json` still ships **without** dates;
  the test `no tithi vrat ships with a guessed date` must stay green.
- Calendar shows tithi, nakshatra, and sunrise on the today card. Home repeats
  today's tithi on the sadhana strip.

Navamsha is **panchang only**. Kundali and chart chat go through Prokerala —
see [PROKERALA.md](PROKERALA.md). The Flutter app never holds either vendor key.

## If the probe fails

- `401` / `403` — key missing, header not `X-API-Key`, or the key is for a
  different Navamsha project.
- `422` — date/location payload rejected; the script already sends
  `StandardBirthRequest` fields from https://api.navamsha.in/docs
- Firestore write errors — ADC not logged in, or rules not deployed (the Admin
  SDK bypasses rules, but the project must exist).
