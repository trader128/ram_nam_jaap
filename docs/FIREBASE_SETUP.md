# Firebase setup — BHAKTi Phase 0

## Status

| Step | State |
|---|---|
| Firebase project created | Done — `bhakti-sawarun` |
| Android app registered | Done — `com.ramnamjap.ram_nam_jap` |
| iOS app registered | Done — `com.ram1.ramNamJap` |
| Config files generated | Done — `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` |
| Gradle google-services plugin | Done — added by `flutterfire configure` |
| **Firestore database created** | **Pending — console action required** |
| **Anonymous auth enabled** | **Pending — console action required** |
| Security rules deployed | Pending — blocked on the database existing |

Console: https://console.firebase.google.com/project/bhakti-sawarun/overview

## Application identifiers — do not change these

| Platform | Identifier |
|---|---|
| Android | `com.ramnamjap.ram_nam_jap` |
| iOS | `com.ram1.ramNamJap` |

The app was renamed to BHAKTi in August 2026, but these two strings deliberately
did not change. The Android one is the live Play Store identity and cannot be
changed on a published app without starting a brand-new listing and abandoning
the existing installs. If you ever re-run `flutterfire configure`, use these
values, not anything derived from the new name.

## Remaining step 1 — create the Firestore database

The Cloud Firestore API is not enabled on a new project, and it cannot be
enabled from the Firebase CLI, so this one is a console click:

1. Open https://console.firebase.google.com/project/bhakti-sawarun/firestore
2. **Create database**
3. Location: **asia-south1 (Mumbai)** — lowest latency for Indian users, and the
   location is permanent once chosen
4. Start in **production mode**. The rules in this repo replace the defaults in
   step 3 below.

## Remaining step 2 — enable Anonymous authentication

Auth providers have no CLI either:

1. Open https://console.firebase.google.com/project/bhakti-sawarun/authentication/providers
2. **Anonymous** → enable

Anonymous is the only provider the app needs. It exists so backup works without
a login wall; phone or Google sign-in can be linked onto the same uid later with
`linkWithCredential`, keeping the user's history.

## Remaining step 3 — deploy the security rules

Once the database exists:

```bash
firebase deploy --only firestore:rules
```

`.firebaserc` already points at `bhakti-sawarun`, so no `--project` flag is
needed. Do not skip this: the console's test-mode default lets any authenticated
user read every document, and with anonymous auth that means anyone at all.
`firestore.rules` restricts each device to its own `users/{uid}` document.

## Verify

```bash
flutter run
```

In the app: Settings → Backup & Sync → turn **Cloud backup** on. The status line
should move to "Last synced just now", and a `users/{uid}` document should appear
in the Firestore console containing `japaStats` and `settings`.

Then confirm the offline guarantee still holds: turn on airplane mode and chant.
Counting must continue normally, with sync retrying silently on reconnect.

## Data model

```
users/{uid}
  schemaVersion: 1
  updatedAt: ISO-8601 string
  settings: { <hive key>: <value> }        // synced preferences only
  japaStats: {
    <deityId>: {
      todayCount, todayDate, lifetimeCount,
      currentStreak, longestStreak, lastActiveDate,
      dailyRecords: { "yyyy-MM-dd": count }
    }
  }
```

`vrats/{vratId}`, `bhajans/{bhajanId}`, `chatSessions/{sessionId}` and
`orders/{orderId}` from the plan do not exist yet; rules for the first two are
already in place as read-only.

## Design notes worth keeping

**Hive stays the source of truth.** Every jap is written locally first and the UI
only ever reads local storage. Firestore is a backup, not the read path, so no
network condition can slow down or block chanting. This is deliberate and should
survive future refactors — the Firestore SDK keeps its own on-device cache, so
removing Hive would not remove local storage, it would only move it somewhere we
control less and pay per write for.

**Counters merge, they do not overwrite.** `SyncSnapshot.mergeWith` takes the
maximum of monotonic values (lifetime count, longest streak, per-day history)
rather than letting the most recent write win, so a stale device coming back
online can never erase japs. Today's count is only compared when both sides refer
to the same calendar day. Preferences are last-write-wins, since a stale toggle
is recoverable and a lost count is not. See `test/sync_snapshot_test.dart`.

**Backup is opt-in.** Default off, no login wall, anonymous only.

**Taps never trigger network work.** Sync runs after first frame, on app resume,
at session end, and on settings changes, with a five-second debounce.

## A note on the committed config files

`google-services.json`, `GoogleService-Info.plist` and `firebase_options.dart`
contain project identifiers and API keys that Firebase treats as public — they
identify the project, they do not authorise access. Access is controlled by the
Firestore rules. Since anonymous sign-in is open by design, assume anyone can
create an anonymous account in this project, and rely on the rules to keep each
account confined to its own document. That is why step 3 is not optional.

## Play Console follow-up

Backup changes the **Data safety** declaration. Once it ships you are collecting,
in Google's terms, "App activity — other user-generated content" tied to a
randomly generated user ID. Declare:

- Data is transferred off device: **yes**
- Collection is **optional** (user can turn it off)
- Data is encrypted in transit: **yes**
- Users can request deletion: **yes** — point at Settings → Backup & Sync →
  Delete cloud backup

`docs/PRIVACY.md` matches this and needs to be published at the URL in the
listing.

## Later phases

AstroKerala calls should go through a backend proxy rather than the client, as
the plan specifies, so the API key is never shipped in the app bundle.
