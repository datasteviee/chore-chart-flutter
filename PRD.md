# Chore Chart — Smart Family Task Planner
## PRD v1.0 | Flutter + Supabase (Self‑Hosted) | April 2026

---

## 1. Executive Summary

**App Name:** Chore Chart  
**Subtitle:** Smart Family Task Planner  
**Primary Keyword:** `chore chart` (Pop 47 · Diff 39 · Opp 41 — 🎯 Sweet Spot per RespecASO v2.8.0)

Chore Chart ist eine **Cross‑Platform‑App** für Familien, die Haushaltsaufgaben fair und automatisch rotieren lässt. Im Gegensatz zu reinen iOS‑Apps (Hedgehog Care) wird Chore Chart explizit **cross‑device** gebaut — weil Familien mit Kindern heute iPhones, iPads, Samsung Tablets und Chromecast‑Laptops nutzen.

---

## 2. Problem & Opportunity

### Das Problem
- In Familien mit Kindern gibt es ständigen Streit, wer heute das Bad putzt, den Müll rausbringt oder den Tisch deckt.
- Eltern verlieren den Überblick, wer bereits was gemacht hat.
- Kinder brauchen visuelle Motivation (Sticker, Punkte, Streaks).
- **Device-Fragmentierung:** Papa hat iPhone, Mama Samsung, Kinder iPad + Fire Tablet. Eine reine iOS-App schließt das nicht ab.

### Die Chance
- Keyword `chore chart`: Pop 47, Diff 39, Opp 41 → 🎯 Sweet Spot
- Keyword `chore manager`: Pop 50, Diff 41, Opp 42 → 👍 Moderate
- **25 Konkurrenten**, aber die meisten sind veraltet, schlecht bewertet oder nur iOS/Android.
- Keine App bietet echte **smarte Rotation** mit **Altersgerechter Skalierung**.

---

## 3. Target Audience

| Persona | Gerät | Bedürfnis |
|---------|-------|-----------|
| Mama (Organisator) | iPhone | Übersicht über alle, Planung der Woche |
| Papa (Mitnutzer) | Samsung Galaxy | Push-Reminder für seine Aufgaben |
| Teen (14) | iPad | Punkte sammeln für Screen‑Time |
| Kind (8) | Samsung Kids Tablet | Einfache Visualisierung, große Buttons |
| Oma | iPhone (grosser Text) | Gelegentliche Mithilfe (einfacher Modus) |

---

## 4. ASO Strategy (Data-Driven)

### Title & Subtitle
```
Title:    Chore Chart — Family Task Planner
Subtitle: Smart household routine for families
```

### Keywords (ASO-optimiert)
```
family chore, chore manager, chore rotation, cleaning planner,
family planner, household tasks, task scheduler, chore tracker,
chore list, family organizer, kids chores, cleaning schedule,
task planner, household routine, chore chart printable
```

### Description (Auszug — für App Store / Play Store)
```
Chore Chart makes family life easier. Create rotating weekly schedules,
assign age-appropriate tasks, and keep everyone on track with smart
reminders — on iPhone, iPad, or Android.

Perfect for busy parents who want a fair, automatic way to distribute
housework without nagging.

Features:
• Rotating weekly schedules — automatically fair
• Age-appropriate tasks (3–6, 7–12, 13+ years)
• Points & streaks to motivate kids
• Widget & calendar sync (iCal / Google Calendar)
• Works offline — your family data stays private
• Cross-device: iPhone, iPad, Android phone & tablet

Try 7 days free. No ads. No credit card required.
```

---

## 5. Tech Stack

| Layer | Technology | Begründung |
|-------|------------|------------|
| **Framework** | Flutter 3.x | Single codebase für iOS, Android, Tablet, Web |
| **State Management** | Riverpod | Type-safe, testable, rebuild-optimiert |
| **Backend / Auth** | Supabase (self-hosted) | PostgREST + Auth + RLS, Kostenarm, Datenschutz |
| **Database** | PostgreSQL (Supabase) | Familien-Daten, Rotationen, Streaks |
| **Realtime** | Supabase Realtime | Live-Sync across devices |
| **Lokal-Cache** | Hive / Isar | Offline-First: Aufgaben lokal, Sync bei Netz |
| **Notifications** | flutter_local_notifications + firebase_messaging (optional) | Reminders lokal, Push cross‑device |
| **Payments** | RevenueCat (iOS) + RevenueCat (Android via Play Billing) | Ein Account, beide Plattformen |
| **Monetization** | DopaLoop-Modell: 7-Tage Trial → $4.99/Monat oder $39.99/Jahr |
| **Analytics** | PostHog (self-hosted) | Privacy-First, kein Firebase |
| **Build** | Codemagic oder GitHub Actions | iOS + Android aus einer Pipeline |
| **Code Generation** | `build_runner` + `freezed` + `json_serializable` | Boilerplate-reduziert |

---

## 6. Architecture

### 6.1 Offline-First Sync Flow

```
┌─────────────────┐
│   Child Tablet  │─── Isar (lokal) ──→ Sync Queue ──→ Supabase
│   (Android)     │                ↑            ↓
└─────────────────┘                │      Supabase Realtime
                                   │            ↓
┌─────────────────┐                │      ┌─────────────┐
│   Parent iPhone │─ Isar lokal ────┘      │  PostgreSQL │
│   (iOS)         │                        │  (Familie)  │
└─────────────────┘                        └─────────────┘
```

**Regeln:**
- Alle CRUD-Ops → zuerst lokal in Isar
- Sync-Queue → bei Netzverbindung an Supabase
- Konfliktlösung: **Last-Write-Wins mit Timestamp** (Server ist Master)
- Offline kann alles gelesen/geschrieben werden, Änderungen werden queued

### 6.2 Self-Hosted Supabase

```yaml
# docker-compose.yml (vereinfacht)
version: '3.8'
services:
  supabase-db:
    image: supabase/postgres:15.1.0.117
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data

  supabase-auth:
    image: supabase/gotrue:v2.158.1
    environment:
      GOTRUE_SITE_URL: "https://chorechart.steviee.dev"
      ...

  supabase-rest:
    image: postgrest/postgrest:v12.0.1
    depends_on:
      - supabase-db
```

> **Hinweis:** Supabase Cloud ist für Hobby‑Projekte kostenlos. Für Produktion: self-hosted auf Hetzner / DigitalOcean ab ~€6/Monat.

---

## 7. Data Model

### 7.1 Core Tables (PostgreSQL)

```sql
-- Familien (jede Familie = eine Row)
CREATE TABLE families (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL DEFAULT 'My Family',
    invite_code TEXT UNIQUE, -- z.B. "CHART-ABC123"
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Familienmitglieder (User-Accounts oder anonyme Kinder)
CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    avatar_url TEXT,
    birth_year INT, -- für Altersgerechte Tasks
    role TEXT CHECK (role IN ('parent', 'teen', 'child', 'guest')) DEFAULT 'child',
    color TEXT, -- UI-Farbe pro Mitglied
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Aufgaben-Vorlagen (pro Familie)
CREATE TABLE task_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    title TEXT NOT NULL, -- "Bad putzen"
    description TEXT,
    min_age INT DEFAULT 0, -- z.B. 7 (ab 7 Jahren)
    max_age INT DEFAULT 99,
    estimated_minutes INT,
    points INT DEFAULT 5,
    recurrence TEXT CHECK (recurrence IN ('daily', 'weekly', 'biweekly', 'monthly')) DEFAULT 'weekly',
    icon TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Geplante Aufgaben (eine Row pro Zuweisung pro Woche)
CREATE TABLE assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    template_id UUID REFERENCES task_templates(id) ON DELETE CASCADE,
    member_id UUID REFERENCES members(id) ON DELETE CASCADE,
    due_date DATE NOT NULL, -- z.B. Mo, 28.04.2026
    status TEXT CHECK (status IN ('pending', 'done', 'skipped', 'overdue')) DEFAULT 'pending',
    completed_at TIMESTAMPTZ,
    completed_by UUID REFERENCES members(id), -- falls von anderem erledigt
    notes TEXT, -- "Etwas schwierig heute"
    points_earned INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Punkte/Streaks (Gamification)
CREATE TABLE streaks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    member_id UUID REFERENCES members(id) ON DELETE CASCADE,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    total_points INT DEFAULT 0,
    last_activity_date DATE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rotation-Log (wer hat wann was rotiert bekommen)
CREATE TABLE rotation_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID REFERENCES families(id) ON DELETE CASCADE,
    template_id UUID REFERENCES task_templates(id),
    from_member_id UUID REFERENCES members(id),
    to_member_id UUID REFERENCES members(id),
    week_start DATE NOT NULL,
    reason TEXT DEFAULT 'auto_rotation',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 7.2 Row Level Security (RLS)

```sql
-- Jeder User darf nur seine eigene Familie sehen
ALTER TABLE families ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users see their own family" ON families
    FOR ALL USING (
        id IN (
            SELECT family_id FROM members
            WHERE user_id = auth.uid()
        )
    );
```

---

## 8. Family Management & Multi-Device Licensing

### 8.1 Das Problem
- Eine Familie hat 4–6 Geräte mit verschiedenen OS.
- Jedes Gerät soll die gleichen Daten sehen.
- **ABER:** Nicht jedes Familienmitglied braucht ein eigenes Benutzerkonto (Kinder haben oft kein Google/Apple Konto).

### 8.2 Die Lösung: "Familien-Gerät-Modell"

```
┌──────────────────────────────────────────┐
│           FAMILIE "Müllers"              │
│           (Supabase: families)           │
├──────────────────────────────────────────┤
│                                          │
│  ┌──────────────┐   ┌──────────────┐   │
│  │ Mama iPhone  │   │ Papa Android │   │
│  │  auth(user)  │   │  auth(user)  │   │
│  │  premium ✓   │   │  premium ✓   │   │
│  └──────────────┘   └──────────────┘   │
│                                          │
│  ┌──────────────┐   ┌──────────────┐   │
│  │ Teen iPad    │   │ Kind Tablet  │   │
│  │  auth(user)  │   │  GERAET-KEY  │   │
│  │  premium ✓   │   │  premium ✓   │   │
│  └──────────────┘   └──────────────┘   │
│                                          │
│  ┌──────────────┐   ┌──────────────┐   │
│  │ Oma iPhone   │   │ Gast-Tablet  │   │
│  │  auth(user)  │   │  PIN-LOGIN   │   │
│  │  premium ✓   │   │  read-only   │   │
│  └──────────────┘   └──────────────┘   │
│                                          │
└──────────────────────────────────────────┘
```

### 8.3 Lizenz-Regeln (DopaLoop-Modell)

| Rolle | Authentifizierung | Lizenz |
|-------|-------------------|--------|
| **Eltern (Organisator)** | Echte Auth (OAuth/Email) | Premium-Abonnement (= Familien-Lizenz) |
| **Teenager** | Echte Auth oder anonym | Teil der Familien-Lizenz |
| **Kinder** | Anonym via "Gerät-Key" oder PIN | Teil der Familien-Lizenz (nur aktive Lizenz erforderlich) |
| **Gäste** | PIN-Login (nur lesen) | Read-Only, kein Editieren |

**Wichtig:** Premium ist **pro Familie**, nicht pro Gerät. Solange die Familie ein aktives Abo hat, können alle verbundenen Geräte alles nutzen.

### 8.4 Device Pairing Flow

```
1. Elternteil erstellt Familie → bekommt Invite-Code "CHART-ABC123"
2. Kind/Gerät: "Familie beitreten" → Code eingeben
3. Optional: Kind-Profil ohne Email erstellen (nur Name + Avatar)
4. Gerät bekommt "device_token" (anonyme UUID)
5. Supabase speichert: families <→ devices (1:N)
6. RevenueCat prüft: Hat die Familie ein aktives Abo?
   → Ja: Alle Features frei
   → Nein: Read-Only-Modus (nur ansehen, nicht erstellen/bearbeiten)
```

### 8.5 API: Lizenz-Check

```dart
// Flutter: Prüfe ob Familie Premium hat
Future<bool> hasFamilyPremium(String familyId) async {
  final response = await supabase
      .from('family_subscriptions')
      .select('*')
      .eq('family_id', familyId)
      .gt('expires_at', DateTime.now().toIso8601String())
      .maybeSingle();
  return response != null;
}
```

---

## 9. Core Features

### 9.1 Weekly Rotation Engine

```dart
class RotationEngine {
  List<Assignment> generateWeek({
    required List<Member> members,
    required List<TaskTemplate> templates,
    required DateTime weekStart,
    required RotationRule rule,
  }) {
    // Regeln:
    // 1. Jedes Template = einmal pro Woche
    // 2. Fairness: Wer hat in den letzten 4 Wochen am wenigsten gemacht?
    // 3. Altersfilter: Nur Member innerhalb min_age/max_age
    // 4. Rotation: Nie zwei gleiche Aufgaben hintereinander
    // Ausgabe: Liste von Assignments für die Woche
  }
}
```

### 9.2 Gamification

| Feature | Mechanik |
|---------|----------|
| **Punkte** | Jede Aufgabe = Punkte (5-20 je nach Schwierigkeit) |
| **Streaks** | 7 Tage hintereinander = Streak-Bonus |
| **Stufen** | "Putz-Anfänger" → "Haushalts-Held" → "Chore-Champion" |
| **Belohnungen** | Eltern können eigene Belohnungen definieren (z.B. "30 Min Screen-Time") |

### 9.3 Offline-First UX

| Szenario | Verhalten |
|----------|-----------|
| Kein Internet | Alle Daten aus Isar gelesen/bearbeitet. Änderungen werden queue'd. |
| Internet zurück | Auto-Sync (oder expliziter "Sync now"-Button). Konflikte werden gelöst. |
| Konflikt | Last-Write-Wins + visuelle Markierung "⚠️ geändert" |

---

## 10. RevenueCat Configuration

```json
{
  "products": [
    {
      "identifier": "chorechart_monthly_499",
      "type": "subscription",
      "price": 4.99,
      "currency": "USD",
      "trial_period": "P7D"
    },
    {
      "identifier": "chorechart_yearly_3999",
      "type": "subscription",
      "price": 39.99,
      "currency": "USD",
      "trial_period": "P7D"
    },
    {
      "identifier": "chorechart_lifetime_7999",
      "type": "non_consumable",
      "price": 79.99,
      "currency": "USD"
    }
  ],
  "entitlements": {
    "premium_family": {
      "products": ["chorechart_monthly_499", "chorechart_yearly_3999", "chorechart_lifetime_7999"],
      "features": ["unlimited_members", "rotation_engine", "calendar_sync", "widgets", "offline_sync"]
    }
  }
}
```

**Wichtig:** RevenueCat `customer_id` = `family_id` (nicht `user_id`). So ist die Lizenz familien-weit gültig.

---

## 11. Project Structure

```
chore-chart-flutter/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart                 # MaterialApp + RiverpodScope
│   ├── core/
│   │   ├── constants.dart
│   │   ├── theme.dart
│   │   ├── router.dart           # GoRouter
│   │   ├── exceptions.dart
│   │   └── utils/
│   ├── data/
│   │   ├── models/               # Freezed + json_serializable
│   │   ├── repositories/         # Supabase + Isar
│   │   ├── providers/            # Riverpod
│   │   └── sync/
│   │       ├── sync_service.dart
│   │       └── conflict_resolver.dart
│   ├── domain/
│   │   ├── rotation_engine.dart
│   │   ├── gamification/
│   │   │   ├── streak_calculator.dart
│   │   │   └── points_engine.dart
│   │   └── entitlement_manager.dart  # RevenueCat wrapper
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── invite_screen.dart
│   │   │   └── widgets/
│   │   ├── family/
│   │   │   ├── screens/
│   │   │   │   ├── family_setup_screen.dart
│   │   │   │   └── members_screen.dart
│   │   │   └── widgets/
│   │   │       └── member_card.dart
│   │   ├── chores/
│   │   │   ├── screens/
│   │   │   │   ├── week_view.dart
│   │   │   │   ├── day_view.dart
│   │   │   │   └── task_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── assignment_card.dart
│   │   │       └── rotation_indicator.dart
│   │   ├── rewards/
│   │   │   └── screens/
│   │   │       └── rewards_screen.dart
│   │   └── settings/
│   │       └── screens/
│   │           └── settings_screen.dart
│   └── widgets/                  # Gemeinsame Widgets
├── supabase/
│   ├── migrations/               # SQL-Migrationen
│   ├── functions/                # Edge Functions (optional)
│   └── docker-compose.yml        # Self-hosted Setup
├── test/
│   ├── unit/
│   └── integration/
├── pubspec.yaml
├── Makefile                     # build_runner, deploy, etc.
└── README.md
```

---

## 12. Roadmap

| Phase | Milestone | Timeline |
|-------|-----------|----------|
| **P0** | Projekt-Setup (Flutter + Supabase local + CI) | Woche 1 |
| **P1** | Auth + Familien-Creation + Invite-Codes | Woche 1 |
| **P2** | Task-Templates + Assignment-Creation (manuell) | Woche 2 |
| **P3** | Rotation Engine + Weekly-View | Woche 2 |
| **P4** | Gamification (Points + Streaks) | Woche 3 |
| **P5** | Offline-Sync + Isar-Integration | Woche 3 |
| **P6** | RevenueCat + In-App-Purchases | Woche 4 |
| **P7** | Widgets + Notifications + Calendar Sync | Woche 4 |
| **P8** | Beta (TestFlight + Play Console Internal) | Woche 5 |
| **P9** | Store-Launch (App Store + Play Store) | Woche 6–8 |

---

## 13. Monetarisierung (DopaLoop Premium-Tool)

| Preis | Was man bekommt |
|-------|-----------------|
| **Gratis Trial** | 7 Tage voll funktionsfähig |
| **Trial abgelaufen** | Read-Only: Alle Daten sichtbar, aber nicht bearbeitbar. Kein "Roulette" mehr. |
| **$4.99/Monat** | Unbegrenzte Familienmitglieder, Rotation Engine, Offline-Sync, Widgets, Calendar Sync |
| **$39.99/Jahr** | Gleicher Inhalt, 33% Ersparnis |
| **$79.99 Lifetime** | Einmal, für immer (Early Adopter-Angebot) |

---

## 14. Privacy & Legal

- **Keine Telemetrie** ohne Einwilligung
- **Supabase self-hosted** = keine Daten bei Dritten
- **RevenueCat** nur für Transaktions-ID, kein Tracking
- **PostHog** (self-hosted) optional für Feature-Nutzung
- **Impressum** inklusive nach DSGVO
- **Keine personenbezogenen Daten** von Kindern gesammelt (nur Vorname + Avatar-Farbe)

---

## 15. Appendix: RespecASO Validation

| Keyword | Popularity | Difficulty | Opportunity | Insight |
|---------|-----------|-----------|-------------|---------|
| `chore chart` | 47 | 39 Moderate | 41 | 🎯 Sweet Spot |
| `chore manager` | 50 | 41 Moderate | 42 | 👍 Moderate |
| `family planner` | 45 | 61 Hard | 29 | 👍 Moderate |
| `chore rotation` | 20 | 29 Easy | 21 | 🚫 Avoid |
| `task rotation` | 15 | 18 Easy | 16 | 🚫 Avoid |
| `household tasks` | 12 | 20 Easy | 14 | 🔍 Low Volume |

> **Learning:** Das ursprüngliche "Chore Roulette"-Konzept mit `chore rotation` (Pop 20) war zu nischig. Der Fokus auf `chore chart` + `chore manager` maximiert das Suchvolumen bei moderate Difficulty.

---

*PRD erstellt am 27. April 2026 | RespecASO v2.8.0 | Flutter 3.x | Supabase self-hosted*
