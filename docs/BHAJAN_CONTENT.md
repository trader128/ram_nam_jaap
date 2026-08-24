# Bhajan content & audio licensing

## Read this first

**No commercial devotional recording ships in this app, and none should be added
without a written licence.** Bhajan recordings sound like folk heritage, but the
recordings themselves are almost all owned by labels — T-Series, Times Music,
Saregama, Ultra — and they enforce aggressively. The underlying compositions are
public domain; a 1998 studio recording of one is not.

This matters more than usual here. The account is already under a Guideline 5.6
Developer Code of Conduct suspension. A copyright complaint on top of that is the
kind of thing that ends a developer account rather than merely rejecting a
build.

A test enforces the bundled side of this:

```
test('no bundled bhajan ships with audio', ...)
```

If anyone drops an MP3 into the assets and wires it up, that test fails.

## What ships today

Traditional texts, all comfortably public domain, each with its author and
period recorded in the `attribution` field as the licensing basis:

| Bhajan | Attribution |
|---|---|
| Hanuman Chalisa | Tulsidas, c. 16th century |
| Vishnu Aarti (Om Jai Jagdish Hare) | Shraddharam Phillauri, 1870 |
| Ganesh Aarti (Jai Ganesh Deva) | Attributed to Surdas, 16th century |
| Lakshmi Aarti (Om Jai Lakshmi Mata) | Traditional |
| Shiva Aarti (Om Jai Shiv Omkara) | Traditional |
| Durga Aarti (Ambe Tu Hai Jagdambe Kali) | Traditional |
| Hanuman Aarti (Aarti Kije Hanuman Lala Ki) | Traditional |
| Sukhkarta Dukhharta | Samarth Ramdas, 17th century |
| Shri Ramchandra Kripalu | Tulsidas, c. 16th century |
| Shiva Panchakshara Stotra | Attributed to Adi Shankaracharya, c. 8th c. |
| Achyutam Keshavam | Traditional |
| Devi Stuti | Devi Mahatmya, traditional |

Every verse carries Devanagari plus a Roman transliteration, behind a toggle in
the app bar. That toggle is the single highest-value detail in this feature for
diaspora users, who often cannot read Devanagari but know the words by ear.

### Verify the texts before you ship

I am confident in these, and the Hanuman Chalisa verse count is asserted at 43
(40 chaupais plus three dohas). But **have a knowledgeable reader check every
text before release.** This audience knows these words by heart. A single wrong
syllable in the Chalisa will be spotted immediately and costs far more trust
than the feature earns.

## Adding audio

Audio is supplied per-track through the Firestore `bhajans` collection, never
bundled. Add `audioUrl` to the document with the matching id:

```
bhajans/hanuman-chalisa
```

```json
{ "audioUrl": "https://firebasestorage.googleapis.com/.../chalisa.m4a" }
```

Fields you omit fall back to the bundled entry, so an audio-only document is
enough — the text keeps coming from the app.

Three ways to get a recording you can actually use, cheapest first:

1. **Commission your own.** A local singer, a flat fee, and a written
   work-for-hire assignment of the recording rights. For seven tracks this is
   inexpensive and it ends the problem permanently.
2. **Creative Commons.** Some devotional recordings are CC-BY or CC0. Keep the
   licence text and the attribution on file for each one.
3. **Licence from the rights holder.** Slow and usually not worth it at this
   stage.

What is *not* an option: ripping from YouTube, pulling from another app, or
assuming "it's a bhajan, it's traditional." The composition being public domain
says nothing about the recording.

## Adding more texts

Same overlay mechanism, using the field names in
`assets/content/bhajans.json`. Categories are `chalisa`, `aarti`, `bhajan`,
`stotra`, `mantra`. Valid `deityId` values are `ram`, `krishna`, `mahadev`,
`ganesh`, `durga`, `hanuman`, and a test asserts every reference resolves
against `DeityCatalog`.

Two content rules are enforced by tests, both about not shipping something
half-finished:

- Every verse must contain Devanagari characters.
- Transliteration is all-or-nothing within a single bhajan, so the Roman toggle
  never reveals gaps mid-text.

## How this connects to the rest of the app

`bhajansForDeityProvider` links texts to deities, which is what lets the vrat
detail screen point at the text actually recited that day — Mangalvar to the
Hanuman Chalisa, Somvar to the Shiva Panchakshara Stotra. The calendar, the
bhajans, and the counter reinforce each other instead of sitting in three
separate silos.

Playback lives in `BhajanAudioService`, which owns its own `AudioPlayer`
deliberately: `SoundService` is tuned for short interruptible chant clips and one
looping ambient bed, and sharing its music player would make a bhajan and the jap
session's ambient track fight over the same channel.

Note that there is no `audio_service` dependency, so there are **no lock-screen
or background controls** — audio stops when the app is backgrounded. For a
forty-verse Chalisa people will want to lock their phone and keep listening, so
if audio becomes a real part of the product, adding `audio_service` should come
before adding more tracks.
