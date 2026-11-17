# Shapap (Tiba Hakika)

Offline-first point-of-care prototype built for Innovation Week. Pull the plug, it still works.

## What the prototype shows
- One clinician screen: who the patient is, whether the system is connected, what happened today, one action.
- Tap a past visit to see what was treated, the diagnosis and the medication.
- Offline mode: discharging with no internet saves the claim on the device and sends it when the internet returns.
- A Poisson busy-hour forecast and a logistic claim-rejection score (seeded, illustrative numbers).
- Responder view: tap a wristband to see blood type, allergy and location (the tap is simulated).
- Light and dark mode.

## What is real
- Sync: saved claims are sent to a real API (the separate `shapap-api` project), one at a time, oldest first. A claim counts as sent only after the server confirms it, so a crash or a lost connection never loses a claim, and a repeat is harmless.
- Sign-in: the API accepts claims only from a signed-in clinician. The sign-in token is kept in memory and never written to disk.
- On the API side: Argon2id password hashing, short-lived signed tokens, patient IDs encrypted at rest (AES-256-GCM), a tamper-evident audit log, rate limits, request-size limits and a CORS allow-list. It is designed with Kenya's Data Protection Act in mind. No compliance is claimed.
- It runs on one PC over plain HTTP. HTTPS comes before it is used over any network.

## What is simulated
The internet switch (a demo switch: the app does not read the real network state), the wristband tap, the patient and visit data (all fictional), and the model coefficients (seeded, not fitted).

## Roadmap (not built)
HTTPS with HSTS, refresh tokens (in progress), multi-factor sign-in, a phone install with secure token storage, a Kafka event log (the API uses SQLite for now), per-patient encryption keys, an on-prem summariser, real NFC provisioning and models fitted on real rejection data. The responder view becomes a separate app.

## Run
Start the API first (see the `shapap-api` project), then:

    flutter pub get
    flutter run -d chrome --web-port 8080

Keep port 8080: the API only allows that address. Sign in with a user created on the API side.
