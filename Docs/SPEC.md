# Blip – Product & Technical Specification

**Version**: 1.0 Draft  
**Status**: Pre-Development  
**Zielplattform**: iOS 26 (iPhone first), iPadOS 26 (Prio 2), macOS Tahoe 26 (Prio 3)

---

## 1. Vision

**Blip** – eine Einmalkauf-App die Flugzeuge und Schiffe in Echtzeit auf einer Karte zeigt, Military automatisch erkennt, und keine Abos, kein Backend und keine Werbung braucht.

**Tagline**: *"See what flies. See what floats. See what hides."*

**Core Value Proposition**:
- Planes UND Ships in einer App (kein Wettbewerber macht beides)
- Military Auto-Detection mit ~15.900 bekannten Aircraft
- Unfiltered Sources (zeigt was FlightRadar24 versteckt)
- Einmalkauf 9,99€ – kein Abo, keine Ads
- Zero Backend, Zero laufende Kosten

---

## 2. Zielplattformen

| Prio | Plattform | Min. OS | Anmerkung |
|------|-----------|---------|-----------|
| 🥇 1 | **iPhone** | iOS 26 | Primary Target. Liquid Glass Design, neues MapKit |
| 🥈 2 | **iPad** | iPadOS 26 | Adaptive Layout, Sidebar-Navigation, größere Karte |
| 🥉 3 | **Mac** | macOS Tahoe 26 | Native Mac App (Catalyst oder SwiftUI nativ), Fenster-Resize |

**iOS 26 Designentscheidungen**:
- Liquid Glass Material für Toolbar, Filter-Bar, Callouts
- Tab Bar mit Scroll-Shrink-Verhalten (iOS 26 native)
- Neues MapKit: GeoToolbox/PlaceDescriptor für Place-Enrichment
- SwiftUI @IncrementalState für performante Listen (iOS 26 neu)
- Swift 6.2 Concurrency-Verbesserungen für async Multi-Source Fetching

**iPad-Anpassungen** (Prio 2):
- NavigationSplitView → Liquid Glass Sidebar mit Filtern/Favoriten
- Karte nimmt 2/3 Breite, Detail-Panel rechts
- Multitasking: Split View / Slide Over Support

**Mac-Anpassungen** (Prio 3):
- Frei skalierbares Fenster, Karte dominiert
- Menu Bar Integration
- Keyboard Shortcuts (Cmd+F Suche, Pfeiltasten Navigation)
- Touch Bar Support (falls vorhanden)

---

## 3. User & Use Cases

**Primärer User**: Technik-affiner Enthusiast ("Stefan-Persona") – neugierig, detail-orientiert, will verstehen was er sieht, hat keine Lust auf Abos.

### Vier Kernmomente

| # | Moment | Trigger | Feature | Time to Answer |
|---|--------|---------|---------|----------------|
| 1 | "Was fliegt da über mir?" | Geräusch, Blick nach oben | Point & Identify | < 3s |
| 2 | "Verfolg das mal" | Interessantes Target entdeckt | Track Mode | Sofort |
| 3 | "Was ist hier los?" | Am Flughafen, Hafen, generell neugierig | Browse & Discover | < 1s (cached) |
| 4 | "Was ist das Ungewöhnliche?" | Tieffliegendes Military, komisches Schiff | Identify & Classify | Sofort (lokal) |

---

## 4. Architektur-Prinzipien

- **Zero Backend**: Alle API-Calls direkt vom Device
- **Zero laufende Kosten**: Kein Server, kein CloudKit, kein eigener Proxy
- **BYOK (Bring Your Own Key)**: User konfiguriert optional zusätzliche API-Keys
- **Offline-First**: Favoriten, letzte Positionen, Referenz-Datenbanken lokal
- **Privacy**: Keine Telemetrie, kein Tracking, keine Accounts
- **Progressive Disclosure**: Erst zeigen, dann anreichern – nie auf langsamste Quelle warten
- **Remote Config**: API-Endpoints via signiertes GitHub JSON steuerbar – kein Store-Update nötig bei API-Änderungen. Ed25519 signiert, Fallback: Remote → Cached → Bundled.
- **Provider Protocol**: Neue Datenquellen jederzeit hinzufügbar ohne Refactoring

---

## 5. Datenquellen

### 5.1 MVP (v1.0) – Je eine Quelle pro Typ

| Typ | Quelle | Protokoll | Key nötig | Unfiltered |
|-----|--------|-----------|-----------|------------|
| ✈️ Flugzeuge | **adsb.lol** | REST | Nein | ✅ Ja |
| 🚢 Schiffe | **aisstream.io** | WebSocket | Ja (free) | ✅ Ja |
| 🎖️ Military DB | **plane-alert-db** | Bundled JSON | Nein | n/a |

**ADS-B Endpoints** (adsb.lol):
```
GET https://api.adsb.lol/v2/lat/{lat}/lon/{lon}/dist/{nm}
GET https://api.adsb.lol/v2/icao/{icao}
GET https://api.adsb.lol/v2/callsign/{callsign}
```

**AIS WebSocket** (aisstream.io):
```json
{
  "Apikey": "<FREE_KEY>",
  "BoundingBoxes": [[latMin, lonMin], [latMax, lonMax]],
  "FilterMessageTypes": ["PositionReport"]
}
```

### 5.2 Post-MVP – Multi-Source Fusion (v1.1+)

| Typ | Zusatzquellen | Key | Strategie |
|-----|---------------|-----|-----------|
| ✈️ | airplanes.live | Nein | Parallel-Fetch, Merge by ICAO Hex |
| ✈️ | OpenSky Network | Optional | Rate-Limited Fallback |
| ✈️ | ADS-B Exchange | BYOK ($10/mo) | Premium Unfiltered |
| 🚢 | MarineTraffic | BYOK | Premium Detail-Daten |

**Fusion-Regeln**: Position → freshest timestamp wins. Metadata → non-empty wins. Military Flag → ANY source = military. Confidence Score → Anzahl bestätigender Quellen (1-3).

### 5.3 Intelligence Layer (v1.2+)

| Quelle | Was | API | Kosten | BYOK |
|--------|-----|-----|--------|------|
| **Global Fishing Watch** | Fishing Heatmap, Dark Events, Encounters | REST | Free Key (non-commercial) | Ja |
| **EMODnet** | 67.000 Wracks, Military Areas, MPAs | WFS (OGC) | Free, kein Key | Nein |
| **IMB Piracy** | Piraterie-Vorfälle weltweit | Kein API (kuratiert) | Free | Nein |
| **UKMTO/NATO** | Maritime Security Alerts | Kein API (kuratiert) | Free | Nein |

### 5.4 Bundled Referenz-Datenbanken (lokal, kein Netzwerk)

| Datenbank | Einträge | Quelle | Update |
|-----------|----------|--------|--------|
| plane-alert-db | ~15.900 Aircraft | GitHub Open Source | App-Update oder OTA |
| ICAO Military Hex Ranges | ~50 Länder | ICAO Docs | Selten |
| Aircraft Type Designators | ~5.000 Types | ICAO Doc 8643 | Selten |
| Airline Codes | ~15.000 Airlines | Öffentliche Registries | Jährlich |
| Ship Type Codes | ~100 Types | ITU-R M.1371 | Selten |
| Squawk Code Reference | ~30 Codes | Öffentlich | Statisch |
| MMSI Navy Ranges | ~50 Länder | ITU Standard | Selten |

---

## 6. Military Intelligence

### 4-Layer Erkennung

```
Layer 1: ICAO Hex Range → Militärische Adressbereiche pro Land
Layer 2: plane-alert-db → 15.900 bekannte Military/Gov/Special Aircraft
Layer 3: Type Code → Ausschließlich militärische ICAO Types (F16, C17, E3CF)
Layer 4: API dbFlags → Flag aus ADS-B Daten (wenn vorhanden)

Ergebnis:
🔴 Confirmed Military (2+ Layer Match)
🟡 Probable Military (1 Layer Match)
⚪ Civilian
```

### Kategorien aus plane-alert-db
USAF (2.121), US Navy, USMC, Army Air Corps, Aerobatic Teams, Government, Police, Dictator Alert, PIA (getarnte Aircraft), "Zoomies" (Fighter), "Da Comrade" (Russisch/Sowjetisch), und 40+ weitere.

---

## 7. App-Architektur

### MVP (v1.0)

```
┌──────────────────────────────────────┐
│            Blip v1.0                 │
├──────────┬───────────┬───────────────┤
│ Map View │ List View │ Detail View   │
│          │           │ + Track Mode  │
├──────────┴───────────┴───────────────┤
│   TargetStore (@MainActor)           │
│   (receives Deltas only from Actor)  │
├──────────────────────────────────────┤
│   TargetFusionActor (off-main)       │
│   Merge → Classify → Diff → Delta   │
├──────────────────────────────────────┤
│    PlaneProvider     │  ShipProvider │
│    (adsb.lol REST)   │  (aisstream  │
│                      │   WebSocket) │
├──────────────────────────────────────┤
│       MilitaryClassifier             │
│  (plane-alert-db + ICAO Ranges      │
│   + Type Codes, alles lokal)         │
├──────────────────────────────────────┤
│       RemoteConfig                   │
│  (GitHub JSON, 2s timeout,           │
│   bundled fallback)                  │
├──────────────────────────────────────┤
│           Local Storage              │
│  SwiftData: Favorites, History       │
│  Bundled JSON: Referenz-DBs          │
│  UserDefaults: Settings              │
│  Keychain: API Keys (BYOK)           │
└──────────────────────────────────────┘
```

**Concurrency Model**:
- `TargetStore` – @MainActor, SwiftUI-bound, empfängt nur Deltas
- `TargetFusionActor` – Swift Actor, off-main-thread, mergt Daten, klassifiziert, diffed
- `PlaneProvider` / `ShipProvider` – async Tasks, liefern Raw Data an FusionActor
- UI rendert nie die volle Liste neu, nur geänderte/neue/entfernte Targets

### Tech Stack

| Komponente | Technologie |
|-----------|-------------|
| UI Framework | SwiftUI (iOS 26, Liquid Glass) |
| Karte | MapKit (kostenlos, native, neue GeoToolbox APIs) |
| Networking REST | URLSession + async/await + Swift Concurrency |
| Networking WebSocket | URLSessionWebSocketTask |
| Persistence | SwiftData (Favoriten, History) |
| Secure Storage | Keychain (API Keys) |
| Settings | @AppStorage / UserDefaults |
| Referenz-Daten | Bundled JSON (kompiliert ins App-Bundle) |
| Iconografie | SF Symbols + Custom Assets |
| Min Deployment | iOS 26 |

---

## 8. UX Flow & Screens

### App Start Verhalten
- **Erster Start**: Karte → User Position → ✈️ Air Filter aktiv → sofort Planes zeigen
- **Folgestarts**: Letzter Tab, letzter Filter, letzte Karten-Position wiederherstellen
- **Kein Onboarding, kein Splash, kein Auswahl-Dialog** – sofort Inhalt

### Tab Bar (Liquid Glass Footer, iOS 26)

```
v1.0:
┌─────────────────────────────────────────────────┐
│  🗺️ Map    📋 List    📊 Dashboard    ⚙️ Settings │
└─────────────────────────────────────────────────┘
```

Alle vier Tabs ab v1.0 sichtbar. Dashboard zeigt Platzhalter bis Inhalt definiert ist. Tabs sind **Features**, nicht Filter.

### Filter System (auf Map + List)

```
Filter-Pills (Liquid Glass, floating über der Karte):
┌────────────────────────────────┐
│  ✈️ Air  │  🚢 Sea  │  🔀 All  │
└────────────────────────────────┘
```

- **Tap**: Wechselt Modus (Air only / Sea only / Combined)
- **Long-Press oder Pull-Down**: Context Flyout mit Subfiltern:
  - Air: Military / Civilian / All + Altitude Range
  - Sea: Cargo / Tanker / Fishing / Navy / All
  - All: Combined + Military Highlight Toggle
- **Zustand wird gespeichert**: Nächster Start = letzte Filter-Einstellung
- Default bei erstem Start: ✈️ Air

### Screen 1: 🗺️ Map (Hauptscreen)
- MapKit Vollbild, Liquid Glass Overlay-Elemente
- **Filter-Pills** (oben, Liquid Glass): Air / Sea / All mit Context Flyout
- **Locate Me** Button (unten rechts, Liquid Glass)
- Target Annotations mit Heading-Rotation
- Farbschema: Civilian Planes blau, Military rot/orange, Ships grün, Navy rot
- Tap → Callout: Key-Info + "Details" + "Track" Buttons
- Clustering bei vielen Targets, smooth Zoom-Transition
- Position-Interpolation: Targets gleiten statt zu springen

### Screen 2: 📋 List
- **Favorites Section** (oben, gepinnt): Favoriten mit Live-Status + letzte Position
- **Interesting Section**: plane-alert-db Matches in der Nähe
- **All Targets**: Sortierbar nach Distance, Altitude, Speed, Type
- **Suchfeld**: Callsign, Registration, MMSI, Ship Name
- Gleiche Filter-Pills wie Map (Air/Sea/All synchronisiert)
- Tap → Detail View

### Screen 3: Detail (Modal/Push)
- Header: Type-Icon + Callsign/Name + Type-Bezeichnung
- **"Last seen" Badge**: Timestamp mit Farbcodierung (grün < 15s, gelb < 60s, rot > 60s)
- **Info-Grid**: Altitude, Speed, Heading, Squawk (Plane) / Course, SOG, Nav Status (Ship)
- **Military Explainability** (wenn classified): Box zeigt welche Layer gematched haben (✅/❌ pro Layer: Hex Range, plane-alert-db, Type Code, API Flag). Dazu Operator, Category, Tags, Wikipedia-Link.
- **Squawk Decoder**: Spezialcodes erklärt (7700, 7600, 7500)
- Trail-Karte: Letzte Positionen als Pfad
- Track Button: Karte folgt diesem Target
- "Open on Web" Link (z.B. ADSBx Globe)
- Favorit ⭐ Toggle

### Screen 4: ⚙️ Settings
- **Sources**: Status pro Quelle (🟢 Online / 🔴 Error / ⏳ Rate Limited)
- **BYOK**: API-Key Eingabefelder (vorbereitet für v1.1+ Quellen). Beim Key-Eintrag: Link zu Source Terms + User bestätigt Nutzungsbedingungen.
- **Display**: Units (metric/imperial/nautical), Altitude ft/m, Map Style
- **Refresh**: Intervall (1s/3s/5s/10s/30s)
- **About**: Version, Attributions, Lizenzen, **Disclaimer** ("Data provided as-is from publicly broadcast ADS-B and AIS signals. No guarantee of accuracy or completeness.")
- **Debug** (versteckt, für Power-User): Performance Metrics, Source Response Times

### Screen 5: 📊 Dashboard (v1.0: Platzhalter, Inhalt TBD)
- Screen existiert ab v1.0 – sauberes UI, kein leerer Screen
- v1.0 zeigt: Blip-Logo, kurze Teaser-Message ("Dashboard coming soon – stats, insights & more"), evtl. Link zu Feedback/Feature Requests
- Inhalt wird nach v1.0 Launch definiert basierend auf echtem User-Verhalten
- Mögliche Kandidaten: Favoriten-Übersicht, Live-Stats, Interesting Nearby, Activity History

---

## 9. Performance-Architektur

### Progressive Disclosure
```
T+0ms:    Cache anzeigen (letzte bekannte Positionen)
T+0ms:    Primary Sources fetchen (async, parallel)
T+<500ms: Erste Ergebnisse auf Karte
T+1-2s:   Enrichment (Military Classification, lokal)
T+2s+:    Secondary Sources (v1.1+, nur wenn Primary fertig)
```

**Regel**: Nie auf langsamste Quelle warten. Erste Daten sofort zeigen.

### Adaptive Fetch
- **Debounce** bei Karten-Pan: 300ms warten ob User noch scrollt
- **Zoom-abhängiger Radius**: Zoom 0-6 kein Live-Fetch, Zoom 7+ adaptiv 10-100nm
- **Adaptive Refresh-Rate**: Schneller bei wenigen Targets, langsamer bei Idle/Low Battery/Cellular
- **Source Timeout**: 2s Primary, 3s Secondary – bei Timeout → überspringen, nicht blocken

### Map Rendering
- Max 500 Annotations gleichzeitig (Military + Favoriten priorisiert)
- MapKit Native Clustering (Planes clustern mit Planes, Ships mit Ships)
- Heading-Rotation via CATransform3D (GPU, kein Image-Rerender)
- Position-Interpolation zwischen Updates (Speed + Heading basiert)
- **Data Age Styling**: Fresh (< 15s) volle Opacity → Aging (15-60s) leicht transparent → Stale (60-300s) deutlich transparent + gestrichelter Rand → Expired (> 300s) entfernt
- **Global Source Status**: Toolbar-Indikator 🟢 Live / 🟡 Delayed / 🔴 Offline

### Memory & Battery
- Max 2.000 Targets in-memory, Stale (>60s) werden transparent, Expired (>300s) entfernt
- Background: Alles pausieren, null Batterieverbrauch
- Foreground-Return: Cache → sofort zeigen, dann Live-Fetch
- Bei Memory Warning: Stale purgen, Clustering aggressiver, Refresh langsamer

### Layer Loading (v1.2+)
| Layer | Laden wenn | Cache |
|-------|-----------|-------|
| ADS-B Planes | Immer | 60s in-memory |
| AIS Ships | Immer | Stream, 120s stale |
| Military Badge | Sofort (lokal) | Bundled DB |
| GFW Fishing | Zoom ≤ 8 | 1h Disk |
| EMODnet Wracks | Zoom ≥ 10 | 24h Disk |
| Piracy Incidents | App-Start | Bundled + Update |

---

## 10. Offline-Modus

| Verfügbar | Nicht verfügbar |
|-----------|-----------------|
| Letzte gecachte Positionen (als "stale") | Live-Positionen |
| Alle Favoriten mit letzter Position | GFW Heatmaps |
| plane-alert-db (Military Classification) | Neue Security Alerts |
| Aircraft/Ship Type Datenbanken | |
| Suche in lokaler DB | |
| EMODnet Wracks (wenn vorher geladen) | |

---

## 11. Monetarisierung

| Modell | Preis | Inhalt |
|--------|-------|--------|
| **Einmalkauf** | 9,99 € | Vollversion, alle Features |
| **Updates v1.x** | Kostenlos | Bugfixes, neue Quellen, neue Layer |
| **v2.0** (optional) | Paid Upgrade oder Free | Nach Scope |

Kein In-App-Purchase, kein Abo, keine Werbung.

**App Store USPs**:
- "No subscriptions. No ads. Buy once, track forever."
- "Multi-source data – see what single-source apps miss."
- "Military & government aircraft detection built in."
- "Planes AND ships in one app."

---

## 12. Feature Roadmap

### v1.0 – Core (MVP)
- [x] MapKit Karte mit Flugzeug- und Schiffs-Icons (iOS 26, Liquid Glass)
- [x] Remote Config (signiertes GitHub JSON, Ed25519, Fallback-Kette: Remote → Cached → Bundled)
- [x] Actor-basierte Fusion Engine (TargetFusionActor, Delta-Updates)
- [x] Conservative Merge Rules (nur bei sicherer ID mergen, sonst separate Targets)
- [x] adsb.lol als Plane Source
- [x] aisstream.io als Ship Source (smart WebSocket Lifecycle)
- [x] MilitaryClassifier (4-Layer, lokal)
- [x] Military Explainability (✅/❌ pro Detection Layer im Detail View)
- [x] Filter: All / Planes / Ships / Military
- [x] Detail View mit Military-Erweiterung + "Open on Web" Link
- [x] Data Age UI (Opacity-Fading, "Last seen" Timestamp, Global Source Status)
- [x] Squawk Decoder
- [x] Track Mode (Karte folgt Target)
- [x] Trail auf Karte
- [x] Favoriten (SwiftData)
- [x] List View mit Suche
- [x] Settings mit BYOK-Vorbereitung (inkl. Terms Acceptance)
- [x] Offline-Cache
- [x] Disclaimer ("Data as-is")
- [x] iPhone-optimiert, iPad-/Mac-ready via SwiftUI

### v1.1 – Multi-Source
- [ ] airplanes.live als zweite Plane-Quelle (parallel)
- [ ] OpenSky Network als dritte Quelle
- [ ] Fusion Engine Multi-Source (Merge by ICAO/MMSI, Confidence Score)
- [ ] Source Status Dashboard in Settings
- [ ] ADS-B Exchange BYOK
- [ ] plane-alert-db OTA-Update (BackgroundAssets, GitHub fetch)

### v1.2 – Intelligence Layer
- [ ] Global Fishing Watch Integration (BYOK)
- [ ] Fishing Activity Heatmap
- [ ] AIS Dark Events ("Transponder aus!")
- [ ] Vessel Encounters
- [ ] EMODnet Wracks (67.000+, WFS API)
- [ ] EMODnet Military Exercise Areas
- [ ] Marine Protected Areas
- [ ] **NOTAMs / Sperrgebiete (ED-R/TRA)** – korreliert mit Military Activity

### v1.3 – Security & Weather Layer
- [ ] Piraterie-Vorfälle (kuratierte DB)
- [ ] UKMTO/NATO Security Alerts
- [ ] High Risk Area Overlays
- [ ] Navy/Coast Guard Vessel Erkennung (MMSI Ranges)
- [ ] **METAR/Aviation Weather** (avwx.rest) – Wind, Sicht, Bedingungen am Flughafen

### v2.0 – Advanced
- [ ] AR View (Kamera + Overlay)
- [ ] Historical Playback
- [ ] Widgets (iPhone, iPad, Mac)
- [ ] Apple Watch Companion
- [ ] Vessel Density Heatmaps
- [ ] SAR Satellite Detections (GFW)

---

## 13. Qualitätskriterien (Release Gate v1.0)

| Kriterium | Ziel |
|-----------|------|
| Time to first target | < 1s (warm) / < 3s (cold) |
| Map frame rate | > 55 fps mit 200 Targets |
| Crash rate | 0 in 100 Testsessions |
| Military detection recall | > 90% auf plane-alert-db |
| Battery drain | < 10%/h aktive Nutzung |
| Offline | App startet, zeigt Cache, kein Crash |
| Accessibility | VoiceOver alle Screens |
| App Size | < 50MB inkl. bundled DBs |

---

## 14. Build-Plan

```
Phase 1 – Fundament (Woche 1-2)
├── Xcode 26 Projekt, SwiftUI, iOS 26 Target
├── Provider Protocol definieren
├── Target Model (unified Plane + Ship)
├── adsb.lol REST Client (async/await)
└── Flugzeuge auf MapKit rendern (Liquid Glass Overlay)

Phase 2 – Ships & Unified (Woche 3-4)
├── aisstream.io WebSocket Client
├── Schiffe auf Karte
├── Unified TargetStore (Planes + Ships)
├── Filter-Bar (All / Planes / Ships / Military)
└── Target Callout mit Key-Info

Phase 3 – Military Intelligence (Woche 5-6)
├── plane-alert-db Import + Lookup Engine
├── ICAO Military Hex Range Checker
├── MilitaryClassifier (4 Layers)
├── Military Farbcodierung + "Interesting" Badge
└── Squawk Decoder

Phase 4 – Detail & Polish (Woche 7-8)
├── Detail View (komplett, mit Military Section)
├── List View mit Suche
├── Track Mode (Karte folgt Target)
├── Trail-Rendering auf Karte
└── Position-Interpolation (smooth movement)

Phase 5 – Infra & Quality (Woche 9-10)
├── Settings Screen + BYOK Vorbereitung
├── Favoriten (SwiftData)
├── Caching + Offline Mode
├── Adaptive Refresh + Performance Tuning
├── iPad Layout (NavigationSplitView)
└── Mac Anpassungen (Fenster, Keyboard Shortcuts)

Phase 6 – Release (Woche 11-12)
├── App Store Screenshots (iPhone, iPad, Mac)
├── App Store Beschreibung + Keywords
├── App Icon (Liquid Glass, layered)
├── TestFlight Beta
├── Bug Fixing
├── Attributions + Legal (ODbL, plane-alert-db, etc.)
└── Submit to App Store
```

---

## 15. Lizenz & Legal

| Quelle | Lizenz | Pflicht |
|--------|--------|---------|
| adsb.lol | ODbL | Attribution in App |
| airplanes.live | Community | Attribution |
| OpenSky Network | CC-BY-SA | Attribution |
| aisstream.io | Free | Attribution |
| plane-alert-db | Open Source | Attribution |
| EMODnet | EU Open Data | Attribution |
| Global Fishing Watch | Non-commercial | BYOK (User holt eigenen Key) |
| ICAO Doc 8643 | Öffentlich | – |
| MapKit | Apple | Apple Developer Agreement |

Alle Attributions werden in Settings > About > Attributions aufgelistet.

---

## 16. Risiken

| Risiko | Impact | Wahrscheinlichkeit | Mitigation |
|--------|--------|---------------------|------------|
| adsb.lol ändert API-Pfade | Hoch | Mittel | **Remote Config** – Endpoints via GitHub JSON steuerbar ohne Store-Update |
| adsb.lol führt Rate Limits ein | Hoch | Mittel | Provider Protocol → Switch zu airplanes.live |
| aisstream.io wird kostenpflichtig | Hoch | Niedrig | BYOK Pattern, AISHub als Alternative |
| Apple lehnt App ab | Mittel | Niedrig | Alle Quellen legitimate Open Data |
| plane-alert-db wird eingestellt | Mittel | Niedrig | Fork + lokale Kopie, Community-Projekt |
| Battery Drain zu hoch | Mittel | Mittel | Adaptive Refresh, aggressive Hintergrund-Pause |
| iOS 26 MapKit Breaking Changes | Niedrig | Niedrig | Beta-Testing, WWDC-Docs |
| Zu viele Features → Scope Creep | Hoch | Hoch | Strikter MVP-Cut, Roadmap-Disziplin |
