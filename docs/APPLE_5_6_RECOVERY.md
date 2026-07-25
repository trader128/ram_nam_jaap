# Apple Guideline 5.6 — What it means & how to recover

## What Apple told you

**Guideline 5.6 (Developer Code of Conduct) — Review Suspended** is one of the strongest outcomes in App Review. It means:

- This **App Store record** (bundle ID `com.ramnamjap.ramNamJap`) is **not eligible for resubmission** right now.
- **Uploading a new build** to the same app will likely get an **automated rejection** without human review.
- **Replying in Resolution Center** on that listing is unlikely to help for this specific message.
- Submitting **many similar apps** quickly can risk **Apple Developer Program** termination.

This is usually about **overall quality and trust**, not a single typo: unfinished feel, weak first impression, iPad layout issues, generic assets, minimal functionality, or a pattern of low-quality submissions from the account.

## What you should **not** do

1. **Do not** upload another build to the suspended app “just to try.”
2. **Do not** create five clone apps with the same feature set and different names.
3. **Do not** rely on AI-generated TTS chants / stock art without clear polish and attribution (reviewers notice).

## What you **can** do

### Option A — Ship on Google Play first (recommended short term)

You already have Play-oriented assets. Polish there, gather ratings, then return to iOS with a **stronger** product story.

### Option B — New iOS app later (after a real upgrade)

If you return to iOS, treat it as a **new product**, not a reskin:

| Area | Bar Apple expects |
|------|-------------------|
| **First 60 seconds** | Welcome → clear tap-to-count coach → working jap session |
| **Audio** | Natural chant or professionally recorded audio (not robotic TTS) |
| **Visuals** | Consistent deity art, no stretched phone UI on tablet |
| **Depth** | Goals, history, insights must feel complete, not empty shells |
| **Metadata** | Screenshots match actual UI; privacy URL with real contact email |
| **Devices** | Only claim devices you test (this repo is now **iPhone-only** in Xcode) |

Use a **new bundle ID** and **new App Store listing** only after the app clearly exceeds “simple counter” quality. Consider a distinct name if the old listing is burned.

### Option C — Apple Developer Support (low odds)

You can ask whether the **account** or **only this app** is blocked, via [Contact Us](https://developer.apple.com/contact/). Do not argue; ask what must change before any future submission.

## Changes already made in this repo (quality pass)

- iPhone-only target (`TARGETED_DEVICE_FAMILY = 1`) — avoids broken iPad layouts in review.
- Adaptive width on tab screens for large phones / future sizing.
- Welcome + **first jap coach overlay** for reviewers.
- **About** screen (features, privacy, content credits).
- English / Hindi for core flows; on-device daily guidance (no cloud “AI”).
- Performance: image precache and sized decoding.

## Before any future iOS submit checklist

- [ ] Real **support email** in privacy policy (replace placeholder in `docs/PRIVACY.md`).
- [ ] Host privacy policy at a **public HTTPS URL** in App Store Connect.
- [ ] **App Review notes**: “Tap Begin Jap → Got it → tap screen to count; offline, no login.”
- [ ] Record a **30s review video** on a physical iPhone.
- [ ] Test **Release** build (`flutter build ipa`), not debug.
- [ ] Replace chant audio if it still sounds like system TTS.
- [ ] New screenshots showing welcome, jap session, insights with sample data filled.

## Version

Track store readiness in release notes; bump `pubspec.yaml` version for each store upload attempt.
