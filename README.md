# Shapap (Tiba Hakika)

Offline-first point-of-care prototype built for Innovation Week. Pull the plug, it still works.

## What the prototype shows
- One clinician screen: who the patient is, whether the system is connected, what happened today, one action.
- Tap a past visit to see what was treated, the diagnosis and the medication.
- Offline mode: discharging with no internet saves the claim on the device and sends it when the internet returns.
- A Poisson busy-hour forecast and a logistic claim-rejection score (seeded, illustrative numbers).
- Responder view: tap a wristband to see blood type, allergy and location (the tap is simulated).
- Light and dark mode.

## What is simulated
The internet switch, the sync (a 2-second timer), the wristband tap, the patient and visit data (all fictional), and the model coefficients (seeded, not fitted).

## Roadmap (not built)
FastAPI sync service, Kafka event log, per-patient encryption, login and role-based access (discharge is clinician-only), audit log, on-prem summariser, real NFC provisioning, models fitted on real rejection data. The responder view becomes a separate app.

## Run
    flutter pub get
    flutter run -d chrome --web-port 8080