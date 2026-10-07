# OpenAlert — IoT-Based Door Opening Detection System with Instant Mobile Alert

## Unsaon pag-run (sa VS Code)
1. `npx create-expo-app OpenAlertApp --template blank`
2. I-copy ang `App.js`, `config.js`, `screens/`, `hooks/` sulod sa `OpenAlertApp` (i-replace ang App.js)
3. Sa VS Code terminal: `npx expo install expo-notifications`
4. `npx expo start` → i-scan ang QR gamit ang **Expo Go** app sa imong phone
5. Naka `DEMO_MODE = true` sa `config.js`, pwede na i-test: pislita ang **Test alert** sa Home.

## Pag-connect sa ESP32 (para sa IoT team)
Sa `config.js`: ibutang ang IP sa ESP32, ug himo `DEMO_MODE = false`.
Ang ESP32 kinahanglan mo-serve og HTTP (same WiFi sa phone):
- `GET /status`  → `{"door":"open"}` or `{"door":"closed"}`
- `GET /silence` → patyon ang buzzer

## Folder structure
- `App.js` — tabs / navigation
- `config.js` — IP, demo mode, colors
- `hooks/useDoorSensor.js` — logic (polling, log, notification)
- `screens/` — Home ug Activity UI
