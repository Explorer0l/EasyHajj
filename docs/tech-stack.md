## EasyHajj Technology Recommendations

### 1. Functional Pillars and Technical Requirements

| UI Section | Capabilities | Technical Implications |
|------------|--------------|------------------------|
| Onboarding (login, permissions) | Google + phone (SMS) auth, skip flow, privacy consent, notification/location toggle screens | Firebase Auth (Google + phone), custom privacy/cookie consent, secure token storage (Keychain/Keystore), runtime permission handling |
| Today dashboard | Next prayer countdown, daily verse, quick links to dua/motivation/community/calendar | Background updates, accurate prayer-time math, offline cache, push refresh, animated gradients |
| Prayer schedule | Daily schedule with alarm toggles per prayer, vertical timeline indicator | Local notifications with precise scheduling, timezone/daylight handling, persistent toggles in storage, background service to refresh times |
| Calendar | Hijri/Gregorian calendar with events | Dual-calendar support, custom calendar component, remote-configurable events |
| Motivation & Community feeds | Cards with images, favorites, share, search, community prayer requests | CMS/back-office or headless CMS, optional moderation queue, share sheet integration, local favorites DB |
| Dua categories | Offline browsing of categorized duas | Embedded rich text/markdown, internationalization, search indexing |
| Settings | Profile, prayer time calc, Quran, dua, Islamic calendar, geolocation | Modular settings store, data sync, location accuracy toggle |
| Location prompt | Basic GPS resolution for city-based prayer times | Geocoder service, fallback manual city picker, caching |

Cross-cutting needs:
- Multilingual UI (at least Russian + Arabic/English) with RTL support.
- Offline-first data for prayer times, dua content, and cached feeds.
- Secure storage of auth tokens and user preferences.
- Accessibility (font scaling) and theming consistent with mockups.

### 2. Core Client Stack Recommendation

**Why Flutter (Dart)**
- Single codebase with pixel-perfect control for the gradient-heavy UI.
- Mature internationalization (i18n) including RTL via `flutter_localizations`.
- High-performance animations (Hero, CustomPainter) for timeline gradients.
- Background services via `android_alarm_manager_plus`, `workmanager`, and `flutter_background_fetch`.
- Large ecosystem for prayer/Qibla plugins; strong testing story (unit, widget, integration).

**Architecture & Tooling**
- State management: `Riverpod` or `Bloc` layered over a clean architecture (Presentation → Application → Domain → Data). Riverpod gives compile-time safety and testability.
- Navigation: `go_router` or `auto_route` for nested flows (onboarding vs main tabs).
- Theming: `ThemeExtension` for gradient palettes, dynamic type scales.
- Offline storage: `Hive` or `isar` for lightweight structured data (prayer schedules, cached articles).
- Networking: `Dio` + interceptors for auth refresh, retry, logging.
- Localization: `intl` with ARB files + `flutter_gen`.
- Testing: `flutter_test`, `integration_test`, golden tests (`golden_toolkit`) for UI fidelity.

**Comparison Snapshot**

| Aspect | Flutter | React Native | Native (Kotlin/Swift) |
|--------|---------|--------------|-----------------------|
| UI fidelity vs mockups | Excellent (single render engine) | Depends on bridging; styling duplication per platform | Excellent but double effort |
| Dev speed | Fast with hot-reload, single team | JS tooling complexity, need native modules | Slow (two teams) |
| Background tasks/notifications | Plugins + platform channels | Requires native modules, sometimes unstable | Native-level control |
| Localization & RTL | Built-in | Achievable but more manual | Built-in but duplicated |
| Team skill need | Dart/Flutter only | JS + native knowledge | Two native teams |

Conclusion: Flutter best balances visual fidelity, productivity, and platform parity for EasyHajj.

### 3. Backend and Data Services

| Option | Pros | Cons | Use-case fit |
|--------|------|------|--------------|
| **Firebase (Firestore + Auth + Cloud Functions)** | Turnkey auth (Google/Facebook/phone/email), real-time DB, Cloud Messaging, Remote Config, Hosting for CMS portal | Vendor lock-in, Firestore pricing for high read/write, need EU data compliance planning | Ideal MVP; quick to ship onboarding/auth, push notifications, dynamic content |
| **Supabase (Postgres + Edge Functions)** | SQL + row-level security, self-hostable, good auth providers, GraphQL via pg_graphql | Phone auth beta, fewer turnkey notification services, smaller ecosystem | Good if you need SQL/analytics flexibility and want open-source/self-host control |
| **Custom backend (NestJS, Django, etc.)** | Full control over business logic, custom prayer algorithms, self-managed deployment | Longer time-to-market, need DevOps, build auth/notifications orchestration | For later stage when rules/content workflows become complex |

Recommended strategy:
1. Start with **Firebase** for Auth (Google + phone per MVP), Firestore for content (motivation, community posts, dua catalog), Storage for images, Cloud Functions for moderation tasks, and Cloud Messaging for notifications.
2. Mirror critical collections to `SQLite/isar` on device for offline-first UI.
3. If you later require advanced reporting or on-prem hosting, transition content feeds to Supabase/Postgres while keeping Firebase Cloud Messaging for pushes.

Prayer times data:
- Use `aladhan.com` API or `PrayTimes` library for calculations, but cache results per location/day in Firestore + device storage. Provide manual calibration factors (Madhhab, high-latitude adjustments).

### 4. Supporting Integrations & DevOps

- **Prayer time/Qibla**: `adhan` (Dart package) or `prayers_times` for calculations; `flutter_qiblah` for compass with magnetometer fallback.
- **Geolocation**: `geolocator` for GPS + `geocoding` for reverse lookup; fallback manual city picker backed by Firestore collection.
- **Notifications**: `firebase_messaging` for push + `flutter_local_notifications` for scheduled alarms and reminder toggles.
- **Analytics & Crash Reporting**: `Firebase Analytics`, `Crashlytics`; consider `Sentry` for advanced monitoring.
- **Content Management**: Lightweight headless CMS (e.g., `Strapi` or `Sanity`) plugged into Cloud Functions to push curated motivation/community content.
- **Security & Privacy**: Use Firebase App Check, Firestore security rules per user, encrypted storage (`flutter_secure_storage`) for tokens, GDPR-compliant consent screens.
- **CI/CD**: GitHub Actions or Codemagic for automated builds/tests; fastlane scripts for store deployment; Firebase App Distribution/TestFlight for QA builds.
- **QA & Testing**: Snapshot tests with `golden_toolkit`, integration tests on real devices via `Firebase Test Lab`.
- **Localization workflow**: Crowdin or Lokalise integrations to manage ARB files and guarantee consistent Russian/Arabic/English translations.

These choices give EasyHajj a modern, maintainable stack that matches the provided mockups, ensures reliable prayer-time logic, and keeps the team productive across Android and iOS.

