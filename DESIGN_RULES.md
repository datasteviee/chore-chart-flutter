# DESIGN_RULES.md

# Chore Chart Design Rules

**App:** Chore Chart — Smart Family Task Planner  
**Platform:** Flutter, iOS, Android, Tablet, Web  
**Design System:** Flutter Mix + Material 3  
**Theme:** Light Mode + Dark Mode  
**Version:** 1.0  
**Date:** April 2026

---

## 1. Design Intent

Chore Chart should feel like a friendly digital family planner: warm, organized, motivating, and easy to understand for parents, kids, teens, and occasional helpers.

The visual language must be:

- Friendly, but not childish
- Clear, but not corporate
- Playful, but not gamified to the point of distraction
- Accessible for children and older users
- Consistent across Android, iOS, tablets, and web
- Fully usable in both light and dark mode

The app should visually support the core product promise: fair household task planning with smart rotation, family-wide visibility, points, streaks, reminders, offline use, and cross-device sync.

---

## 2. Core Principles

### 2.1 Warm Clarity

Use warm surfaces, rounded cards, soft contrast, and friendly colors. The UI should reduce friction around chores, not make them feel like admin work.

### 2.2 Family-First Accessibility

Every screen must work for:

- Parents managing the week
- Children using large buttons and visual cues
- Teens checking progress and rewards
- Guests or grandparents using simple read-only flows
- Users with larger system text settings

Minimum interactive target size: **48 x 48 px**.

### 2.3 Visual Fairness

Task assignment and rotation must feel transparent. Rotation indicators, member colors, assignment history, and status chips should make it obvious why a person has a task.

### 2.4 Calm Gamification

Points, streaks, rewards, and levels should feel encouraging. Avoid casino-like visuals, aggressive animations, flashing effects, or excessive celebration.

### 2.5 Offline Confidence

Offline and sync states must be visible but calm. Users should always know whether a change is saved locally, queued, synced, or conflicted.

---

## 3. Flutter Mix Usage Rules

Chore Chart uses **Flutter Mix** as the primary design-system layer.

Mix should be used for:

- Design tokens
- Reusable component styles
- Component variants
- Responsive styling
- Interaction states
- Theme-aware styling
- Shared visual rules across native Flutter widgets

Native Flutter `ThemeData` should still be used for Material defaults, navigation, system integration, text fallback behavior, dialogs, form defaults, and platform consistency.

### 3.1 Token-First Rule

Do not hardcode colors, spacing, radii, shadows, typography, or status colors inside widgets.

Use Mix tokens for:

- Colors
- Text styles
- Spacing
- Radii
- Border widths
- Elevation/shadow values
- Component sizes
- Status colors

Good:

```dart
BoxStyler()
  .color($surface())
  .borderRadius($radiusLg())
  .padding($spaceMd());
```

Avoid:

```dart
Container(
  color: Color(0xFFFFFFFF),
  padding: EdgeInsets.all(16),
);
```

### 3.2 MixScope Rule

Provide all theme token values near the top of the app tree using `MixScope`.

Use separate token maps for light and dark mode.

Recommended structure:

```dart
MaterialApp(
  theme: ChoreMaterialTheme.light,
  darkTheme: ChoreMaterialTheme.dark,
  builder: (context, child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MixScope(
      colors: isDark ? ChoreMixTheme.darkColors : ChoreMixTheme.lightColors,
      spaces: ChoreMixTheme.spaces,
      radii: ChoreMixTheme.radii,
      textStyles: isDark ? ChoreMixTheme.darkTextStyles : ChoreMixTheme.lightTextStyles,
      child: child!,
    );
  },
);
```

### 3.3 Component Style Rule

Every reusable UI component must expose a small set of named variants instead of custom one-off styling.

Examples:

- `AssignmentCardVariant.pending`
- `AssignmentCardVariant.done`
- `AssignmentCardVariant.overdue`
- `AssignmentCardVariant.skipped`
- `AssignmentCardVariant.conflict`
- `AssignmentCardVariant.offlineQueued`

### 3.4 Variant Naming Rule

Use semantic variant names, not visual names.

Good:

```dart
variant: AssignmentCardVariant.overdue
```

Avoid:

```dart
variant: AssignmentCardVariant.red
```

### 3.5 Interaction State Rule

Mix styles must define states for interactive components:

- Default
- Pressed
- Disabled
- Loading
- Selected
- Read-only

Hover and focus states should be defined for tablets, desktop, and web where applicable.

---

## 4. Color System

### 4.1 Brand Mood

Primary mood: warm mint, sunny yellow, soft blue, coral accents.  
The palette should communicate calm organization, family friendliness, and gentle motivation.

---

## 5. Light Mode Colors

| Token | Usage | Hex |
|---|---|---:|
| `color.primary` | Main actions, selected nav, main CTA | `#2E9D76` |
| `color.onPrimary` | Text/icons on primary | `#FFFFFF` |
| `color.primaryContainer` | Soft primary backgrounds | `#DDF6EA` |
| `color.onPrimaryContainer` | Text on primary container | `#123A2D` |
| `color.secondary` | Points, rewards, highlights | `#F3B63F` |
| `color.onSecondary` | Text/icons on secondary | `#3F2F0B` |
| `color.secondaryContainer` | Soft reward backgrounds | `#FFF1C7` |
| `color.onSecondaryContainer` | Text on reward backgrounds | `#3F2F0B` |
| `color.tertiary` | Calendar, sync, info | `#4F8FD8` |
| `color.onTertiary` | Text/icons on tertiary | `#FFFFFF` |
| `color.background` | App background | `#FFFDF7` |
| `color.onBackground` | Main text | `#25312C` |
| `color.surface` | Cards, sheets, dialogs | `#FFFFFF` |
| `color.onSurface` | Text on cards | `#25312C` |
| `color.surfaceVariant` | Secondary cards, inputs, chips | `#F4EFE7` |
| `color.onSurfaceVariant` | Muted text | `#65736E` |
| `color.outline` | Strong border | `#C8D2CC` |
| `color.outlineVariant` | Soft border | `#E1E8E3` |
| `color.error` | Error/destructive | `#D9534F` |
| `color.onError` | Text/icons on error | `#FFFFFF` |

---

## 6. Dark Mode Colors

| Token | Usage | Hex |
|---|---|---:|
| `color.primary` | Main actions, selected nav, main CTA | `#77D7B0` |
| `color.onPrimary` | Text/icons on primary | `#0D3024` |
| `color.primaryContainer` | Soft primary backgrounds | `#174D3B` |
| `color.onPrimaryContainer` | Text on primary container | `#DDF6EA` |
| `color.secondary` | Points, rewards, highlights | `#F5C96B` |
| `color.onSecondary` | Text/icons on secondary | `#3F2F0B` |
| `color.secondaryContainer` | Soft reward backgrounds | `#5A4218` |
| `color.onSecondaryContainer` | Text on reward backgrounds | `#FFF1C7` |
| `color.tertiary` | Calendar, sync, info | `#8BBDF2` |
| `color.onTertiary` | Text/icons on tertiary | `#10253D` |
| `color.background` | App background | `#101815` |
| `color.onBackground` | Main text | `#F3F8F4` |
| `color.surface` | Cards, sheets, dialogs | `#18221E` |
| `color.onSurface` | Text on cards | `#F3F8F4` |
| `color.surfaceVariant` | Secondary cards, inputs, chips | `#24322D` |
| `color.onSurfaceVariant` | Muted text | `#B9C8C0` |
| `color.outline` | Strong border | `#43524B` |
| `color.outlineVariant` | Soft border | `#2E3B36` |
| `color.error` | Error/destructive | `#FF8A8A` |
| `color.onError` | Text/icons on error | `#3D1111` |

---

## 7. Status Colors

Status colors must be consistent across cards, chips, banners, icons, and calendar indicators.

### 7.1 Light Status Tokens

| Token | Usage | Hex |
|---|---|---:|
| `status.done.bg` | Completed task background | `#DDF6EA` |
| `status.done.fg` | Completed task icon/text | `#2E9D76` |
| `status.pending.bg` | Pending task background | `#F4EFE7` |
| `status.pending.fg` | Pending task icon/text | `#65736E` |
| `status.overdue.bg` | Overdue background | `#FFE1E7` |
| `status.overdue.fg` | Overdue icon/text | `#E85D75` |
| `status.skipped.bg` | Skipped background | `#EDEDED` |
| `status.skipped.fg` | Skipped icon/text | `#6F7471` |
| `status.warning.bg` | Conflict or warning background | `#FFF1C7` |
| `status.warning.fg` | Conflict or warning text | `#9A6A11` |
| `status.offline.bg` | Offline/sync queue background | `#E4F0F6` |
| `status.offline.fg` | Offline/sync icon/text | `#4F7F99` |
| `status.premium.bg` | Premium/trial badge background | `#FFE7A3` |
| `status.premium.fg` | Premium/trial text | `#75520D` |

### 7.2 Dark Status Tokens

| Token | Usage | Hex |
|---|---|---:|
| `status.done.bg` | Completed task background | `#174D3B` |
| `status.done.fg` | Completed task icon/text | `#77D7B0` |
| `status.pending.bg` | Pending task background | `#24322D` |
| `status.pending.fg` | Pending task icon/text | `#B9C8C0` |
| `status.overdue.bg` | Overdue background | `#5A1E2B` |
| `status.overdue.fg` | Overdue icon/text | `#FF8FA3` |
| `status.skipped.bg` | Skipped background | `#303634` |
| `status.skipped.fg` | Skipped icon/text | `#B9C0BC` |
| `status.warning.bg` | Conflict or warning background | `#5A4218` |
| `status.warning.fg` | Conflict or warning text | `#F5C96B` |
| `status.offline.bg` | Offline/sync queue background | `#203744` |
| `status.offline.fg` | Offline/sync icon/text | `#9DB8C8` |
| `status.premium.bg` | Premium/trial badge background | `#6A4C12` |
| `status.premium.fg` | Premium/trial text | `#FFE7A3` |

---

## 8. Member Colors

Every family member can have a stable color used for avatar rings, assignment badges, calendar markers, and small ownership indicators.

Use this palette in order, with optional shuffle at family setup.

```dart
const memberColors = [
  Color(0xFF4F8FD8), // Blue
  Color(0xFFE85D75), // Coral
  Color(0xFFF3B63F), // Yellow
  Color(0xFF7C6BEA), // Purple
  Color(0xFF2E9D76), // Green
  Color(0xFFFF8A4C), // Orange
  Color(0xFF5BBEC3), // Teal
  Color(0xFFB66AD8), // Violet
];
```

Rules:

- A member color must remain stable once assigned.
- Do not use member color as the only indicator of identity.
- Always pair member color with name, initials, or avatar.
- Ensure readable contrast when placing text on member colors.

---

## 9. Typography

### 9.1 Font

Primary font: **Nunito Sans**  
Fallbacks: platform default fonts

Reason: Nunito Sans is rounded, friendly, readable, and suitable for both child-facing and parent-facing interfaces.

### 9.2 Type Scale

| Token | Usage | Size | Weight | Line Height |
|---|---|---:|---:|---:|
| `text.display` | Celebration, onboarding hero | 32 | 800 | 1.10 |
| `text.headline` | Screen titles | 28 | 800 | 1.15 |
| `text.titleLg` | Major sections | 24 | 800 | 1.20 |
| `text.titleMd` | Cards, list titles | 18 | 700 | 1.25 |
| `text.titleSm` | Compact card titles | 16 | 700 | 1.30 |
| `text.bodyLg` | Main body | 16 | 500 | 1.45 |
| `text.bodyMd` | Secondary body | 14 | 500 | 1.40 |
| `text.labelLg` | Buttons, badges | 14 | 800 | 1.20 |
| `text.labelMd` | Small chips, captions | 12 | 700 | 1.20 |
| `text.childAction` | Child mode buttons | 20 | 800 | 1.20 |

Rules:

- Respect system text scaling.
- Avoid fixed-height text containers.
- Use at least `bodyLg` for child-facing core actions.
- Use `labelMd` only for secondary labels, never for essential task information.

---

## 10. Spacing

| Token | Value | Usage |
|---|---:|---|
| `space.xxs` | 2 | Hairline gaps, compact icon spacing |
| `space.xs` | 4 | Tight internal spacing |
| `space.sm` | 8 | Small chips, icon gaps |
| `space.md` | 16 | Default card padding |
| `space.lg` | 24 | Section spacing |
| `space.xl` | 32 | Screen-level spacing |
| `space.xxl` | 48 | Hero and empty states |

Rules:

- Default horizontal screen padding: `16`.
- Tablet max content width: `720` for reading/detail flows.
- Dashboard/tablet split layouts may use wider grids.
- Child mode should use larger spacing than default mode.

---

## 11. Radius

| Token | Value | Usage |
|---|---:|---|
| `radius.xs` | 6 | Tiny badges |
| `radius.sm` | 10 | Small chips |
| `radius.md` | 16 | Inputs, small cards |
| `radius.lg` | 24 | Assignment cards, reward cards |
| `radius.xl` | 32 | Hero panels, onboarding cards |
| `radius.full` | 999 | Pills, avatars, circular controls |

Rules:

- Main cards use `radius.lg`.
- Buttons use `radius.md` or `radius.lg`.
- Pills and chips use `radius.full`.
- Avoid sharp rectangular cards.

---

## 12. Elevation & Shadows

The app should mostly use borders and subtle surface changes instead of heavy shadows.

| Token | Usage |
|---|---|
| `shadow.none` | Default cards, chips |
| `shadow.soft` | Elevated cards, selected day, reward highlight |
| `shadow.medium` | Modal panels, floating actions |

Rules:

- Default cards should have no strong elevation.
- Use soft shadows only to indicate hierarchy or focus.
- Dark mode shadows should be minimal; prefer surface contrast and borders.

---

## 13. Iconography

Use rounded Material icons or Material Symbols Rounded.

Recommended icon sizes:

| Size | Usage |
|---:|---|
| 16 | Small chip icons |
| 20 | Inline status icons |
| 24 | Navigation, buttons |
| 32 | Empty states, member cards |
| 48 | Child mode, onboarding |

Recommended icons:

| Feature | Icon |
|---|---|
| Tasks | `cleaning_services`, `restaurant`, `delete`, `bed` |
| Rotation | `autorenew` |
| Points | `stars` |
| Streak | `local_fire_department` |
| Rewards | `card_giftcard` |
| Family | `groups` |
| Child mode | `child_care` |
| Offline | `cloud_off` |
| Sync | `sync` |
| Calendar | `calendar_month` |
| Premium | `workspace_premium` |
| Conflict | `warning_amber` |
| Done | `check_circle` |

Rules:

- Icons must support text, not replace it for critical actions.
- Use filled/rounded icons for child-facing positive actions.
- Use warning icons sparingly.

---

## 14. Component Rules

## 14.1 AssignmentCard

Used for one scheduled task assignment.

Required elements:

- Task icon
- Task title
- Assigned member avatar/color
- Due date or day label
- Points
- Status chip
- Primary action if applicable

Variants:

- `pending`
- `done`
- `overdue`
- `skipped`
- `conflict`
- `offlineQueued`
- `readOnly`

Visual rules:

- Radius: `radius.lg`
- Padding: `space.md`
- Minimum height: `88`
- Use member color as accent, not full-card background
- Overdue cards use coral border and status chip
- Done cards use green/mint background or accent
- Offline cards use subtle blue-grey sync chip

Child mode:

- Larger title
- Larger icon
- Big `Done` action
- Avoid dense metadata

---

## 14.2 MemberAvatar

Used to identify family members.

States:

- Default
- Selected
- Inactive
- Guest
- Read-only

Rules:

- Use initials if no image exists.
- Avatar background uses assigned member color.
- Selected state adds ring/border.
- Guest/read-only avatars should look visually subdued.

---

## 14.3 MemberCard

Used in family setup, members list, and task ownership views.

Required elements:

- Avatar
- Name
- Role
- Optional age group
- Points/streak summary where relevant

Role labels:

- Parent
- Teen
- Child
- Guest

Rules:

- Do not expose sensitive account details for children.
- Child member cards should prioritize name, avatar, and progress.

---

## 14.4 PointsBadge

Used to show task value or earned points.

Rules:

- Use secondary/gold colors.
- Shape: pill.
- Icon: `stars`.
- Text examples: `+5`, `+10`, `120 pts`.

---

## 14.5 StreakBadge

Used to show current streak.

Rules:

- Use flame icon.
- Use warm orange/gold accent.
- Keep tone encouraging.
- Do not make broken streaks feel punitive.

Good copy:

- `3-day streak`
- `Keep going`
- `New best!`

Avoid:

- `You failed`
- `Streak lost`

---

## 14.6 RotationIndicator

Used to explain smart/fair task rotation.

Required elements:

- Rotation icon
- Current/next assignee context
- Small member avatars if helpful
- Short explanatory copy

Rules:

- Use primary + tertiary accents.
- Should feel transparent and trustworthy.
- Avoid roulette/casino visuals.

Good copy:

- `Rotated fairly this week`
- `Jonah gets this task next`
- `Based on the last 4 weeks`

---

## 14.7 RewardCard

Used for custom family rewards.

Required elements:

- Reward title
- Required points
- Progress
- Optional icon or illustration

Rules:

- Use warm secondary container.
- Show progress clearly.
- Avoid dark patterns around premium or rewards.

---

## 14.8 OfflineSyncBanner

Used when the app is offline or has queued changes.

States:

- Offline
- Sync queued
- Syncing
- Synced
- Conflict

Rules:

- Offline and queued states should be calm.
- Conflict state must be more visible but not alarming.
- Always explain what happens next.

Good copy:

- `Offline — changes will sync later`
- `3 changes waiting to sync`
- `Changed on another device`

---

## 14.9 ReadOnlyBanner

Used after trial expiration or for guest/read-only mode.

Rules:

- Use neutral/warning styling, not error styling.
- Explain limitations clearly.
- Premium CTA should be present but not aggressive.

Good copy:

- `Read-only mode: your family data is still visible.`
- `Start Premium to edit schedules again.`

---

## 14.10 WeekDayPill

Used in weekly schedule navigation.

States:

- Default
- Today
- Selected
- Has tasks
- Has overdue
- Completed

Rules:

- Today gets subtle primary outline.
- Selected gets primary container.
- Overdue uses small coral dot/badge.
- Completed can use small done indicator.

---

## 14.11 TaskStatusChip

Status chips should be short and visually consistent.

Labels:

- `Pending`
- `Done`
- `Skipped`
- `Overdue`
- `Changed`
- `Offline`
- `Read-only`

Rules:

- Use semantic status colors.
- Include icons only where helpful.
- Keep labels short for small screens.

---

## 15. Screen-Level Rules

## 15.1 Onboarding

Goal: explain value quickly.

Visual direction:

- Warm hero panel
- Family/task illustration or abstract card stack
- Primary CTA
- Secondary join-family action

Must communicate:

- Rotating weekly schedules
- Family-wide use
- Works across iOS and Android
- Trial/no ads positioning

---

## 15.2 Family Setup

Goal: create family and members with minimal friction.

Rules:

- Use step-based layout.
- Member color and avatar selection should feel fun.
- Invite code should be large and easy to copy/share.
- Avoid technical language around device tokens.

---

## 15.3 Week View

Goal: provide overview of household workload.

Rules:

- Show week navigation clearly.
- Group tasks by day or member depending on selected mode.
- Highlight overdue tasks without overwhelming the dashboard.
- Show rotation context when relevant.

---

## 15.4 Day View

Goal: make today actionable.

Rules:

- Prioritize today’s pending tasks.
- Child mode should simplify this screen dramatically.
- Use large cards and clear completion actions.

---

## 15.5 Task Detail

Goal: show task instructions, due date, points, assignee, and status.

Rules:

- Main action should be visually dominant.
- Secondary actions should be calm.
- Notes and conflict details should be readable but not visually dominant.

---

## 15.6 Rewards

Goal: make points meaningful.

Rules:

- Use warm gold/yellow accents.
- Use clear progress bars.
- Let parents define custom rewards without creating visual clutter.

---

## 15.7 Settings

Goal: trustworthy account, family, sync, and premium controls.

Rules:

- Use calm surfaces and grouped sections.
- Privacy and subscription information should be clear.
- Use plain language.

---

## 16. Accessibility Rules

- Maintain readable contrast in light and dark mode.
- Do not rely on color alone for status.
- Pair status colors with text and/or icons.
- Respect system font scaling.
- Minimum tap target: `48 x 48`.
- Child-facing primary actions should be at least `52 px` high.
- Avoid tiny icon-only controls for important actions.
- Avoid long dense paragraphs in child mode.
- Support both portrait and landscape on tablets.

---

## 17. Motion Rules

Animations should be short, friendly, and functional.

Recommended:

- Card completion: quick check animation
- Points earned: small badge pop
- Streak update: subtle flame animation
- Sync complete: small confirmation
- Reward unlocked: gentle celebration

Avoid:

- Excessive confetti
- Flashing effects
- Long blocking animations
- Casino-like reward loops

Timing:

- Micro interaction: `120–180 ms`
- Card transition: `180–240 ms`
- Celebration: `500–900 ms`

---

## 18. Copy & Tone Rules

Tone: friendly, calm, encouraging.

Use:

- `Done`
- `Nice work!`
- `Rotated fairly this week`
- `Changes will sync later`
- `Read-only mode`

Avoid:

- Blame
- Shame
- Harsh failure language
- Technical backend terms
- Fear-based premium prompts

---

## 19. Flutter Mix Token Skeleton

This is a suggested token structure. Exact syntax may be adapted to the installed Flutter Mix version.

```dart
import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

final $primary = ColorToken('color.primary');
final $onPrimary = ColorToken('color.onPrimary');
final $primaryContainer = ColorToken('color.primaryContainer');
final $onPrimaryContainer = ColorToken('color.onPrimaryContainer');

final $secondary = ColorToken('color.secondary');
final $secondaryContainer = ColorToken('color.secondaryContainer');

final $background = ColorToken('color.background');
final $surface = ColorToken('color.surface');
final $surfaceVariant = ColorToken('color.surfaceVariant');
final $onSurface = ColorToken('color.onSurface');
final $onSurfaceVariant = ColorToken('color.onSurfaceVariant');

final $statusDoneBg = ColorToken('status.done.bg');
final $statusDoneFg = ColorToken('status.done.fg');
final $statusOverdueBg = ColorToken('status.overdue.bg');
final $statusOverdueFg = ColorToken('status.overdue.fg');
final $statusWarningBg = ColorToken('status.warning.bg');
final $statusWarningFg = ColorToken('status.warning.fg');
final $statusOfflineBg = ColorToken('status.offline.bg');
final $statusOfflineFg = ColorToken('status.offline.fg');

final $spaceXs = SpaceToken('space.xs');
final $spaceSm = SpaceToken('space.sm');
final $spaceMd = SpaceToken('space.md');
final $spaceLg = SpaceToken('space.lg');
final $spaceXl = SpaceToken('space.xl');

final $radiusSm = RadiusToken('radius.sm');
final $radiusMd = RadiusToken('radius.md');
final $radiusLg = RadiusToken('radius.lg');
final $radiusFull = RadiusToken('radius.full');
```

---

## 20. Flutter Mix Theme Skeleton

```dart
class ChoreMixTheme {
  static final lightColors = {
    $primary: const Color(0xFF2E9D76),
    $onPrimary: Colors.white,
    $primaryContainer: const Color(0xFFDDF6EA),
    $onPrimaryContainer: const Color(0xFF123A2D),
    $secondary: const Color(0xFFF3B63F),
    $secondaryContainer: const Color(0xFFFFF1C7),
    $background: const Color(0xFFFFFDF7),
    $surface: Colors.white,
    $surfaceVariant: const Color(0xFFF4EFE7),
    $onSurface: const Color(0xFF25312C),
    $onSurfaceVariant: const Color(0xFF65736E),
    $statusDoneBg: const Color(0xFFDDF6EA),
    $statusDoneFg: const Color(0xFF2E9D76),
    $statusOverdueBg: const Color(0xFFFFE1E7),
    $statusOverdueFg: const Color(0xFFE85D75),
    $statusWarningBg: const Color(0xFFFFF1C7),
    $statusWarningFg: const Color(0xFF9A6A11),
    $statusOfflineBg: const Color(0xFFE4F0F6),
    $statusOfflineFg: const Color(0xFF4F7F99),
  };

  static final darkColors = {
    $primary: const Color(0xFF77D7B0),
    $onPrimary: const Color(0xFF0D3024),
    $primaryContainer: const Color(0xFF174D3B),
    $onPrimaryContainer: const Color(0xFFDDF6EA),
    $secondary: const Color(0xFFF5C96B),
    $secondaryContainer: const Color(0xFF5A4218),
    $background: const Color(0xFF101815),
    $surface: const Color(0xFF18221E),
    $surfaceVariant: const Color(0xFF24322D),
    $onSurface: const Color(0xFFF3F8F4),
    $onSurfaceVariant: const Color(0xFFB9C8C0),
    $statusDoneBg: const Color(0xFF174D3B),
    $statusDoneFg: const Color(0xFF77D7B0),
    $statusOverdueBg: const Color(0xFF5A1E2B),
    $statusOverdueFg: const Color(0xFFFF8FA3),
    $statusWarningBg: const Color(0xFF5A4218),
    $statusWarningFg: const Color(0xFFF5C96B),
    $statusOfflineBg: const Color(0xFF203744),
    $statusOfflineFg: const Color(0xFF9DB8C8),
  };

  static final spaces = {
    $spaceXs: 4.0,
    $spaceSm: 8.0,
    $spaceMd: 16.0,
    $spaceLg: 24.0,
    $spaceXl: 32.0,
  };

  static final radii = {
    $radiusSm: Radius.circular(10),
    $radiusMd: Radius.circular(16),
    $radiusLg: Radius.circular(24),
    $radiusFull: Radius.circular(999),
  };
}
```

---

## 21. AssignmentCard Mix Style Example

```dart
enum AssignmentCardVariant {
  pending,
  done,
  overdue,
  skipped,
  conflict,
  offlineQueued,
  readOnly,
}

final assignmentCardStyle = Style(
  BoxStyler()
    .color($surface())
    .borderRadius($radiusLg())
    .padding($spaceMd())
    .border(
      color: $surfaceVariant(),
      width: 1,
    ),

  Variant(AssignmentCardVariant.done)(
    BoxStyler()
      .color($statusDoneBg())
      .border(color: $statusDoneFg(), width: 1),
  ),

  Variant(AssignmentCardVariant.overdue)(
    BoxStyler()
      .color($statusOverdueBg())
      .border(color: $statusOverdueFg(), width: 1.5),
  ),

  Variant(AssignmentCardVariant.conflict)(
    BoxStyler()
      .color($statusWarningBg())
      .border(color: $statusWarningFg(), width: 1.5),
  ),

  Variant(AssignmentCardVariant.offlineQueued)(
    BoxStyler()
      .color($statusOfflineBg())
      .border(color: $statusOfflineFg(), width: 1),
  ),
);
```

---

## 22. Native Flutter ThemeData Rule

Even with Flutter Mix, keep a native Material theme for platform components.

ThemeData should define:

- `ColorScheme`
- `TextTheme`
- `AppBarTheme`
- `NavigationBarThemeData`
- `InputDecorationTheme`
- `DialogTheme`
- `BottomSheetThemeData`
- `SnackBarThemeData`

Mix should define:

- Product component styling
- Variants
- Status states
- Responsive composition
- Token-driven design primitives

---

## 23. File & Code Organization

Recommended structure:

```txt
lib/
  core/
    theme/
      chore_material_theme.dart
      chore_mix_tokens.dart
      chore_mix_theme.dart
      chore_status_tokens.dart
      chore_member_colors.dart
  widgets/
    design_system/
      assignment_card.dart
      member_avatar.dart
      points_badge.dart
      streak_badge.dart
      reward_card.dart
      rotation_indicator.dart
      offline_sync_banner.dart
      read_only_banner.dart
```

Rules:

- Tokens live in `core/theme`.
- Reusable styled components live in `widgets/design_system`.
- Feature-specific widgets can compose design-system components.
- Do not duplicate colors or spacing in feature folders.

---

## 24. Quality Checklist

Before merging a UI component, check:

- [ ] Uses Mix tokens instead of hardcoded values
- [ ] Supports light and dark mode
- [ ] Has required semantic variants
- [ ] Has disabled/read-only state if interactive
- [ ] Works with large text
- [ ] Has minimum 48 px touch target
- [ ] Does not rely on color alone
- [ ] Works on narrow phone screens
- [ ] Works on tablet layouts
- [ ] Uses friendly, non-punitive copy
- [ ] Handles offline/sync/conflict state where relevant
- [ ] Avoids platform-specific visual assumptions

---

## 25. Final Direction

Chore Chart should look calm, warm, and trustworthy. Mint green communicates progress and order. Gold supports points and rewards. Blue supports planning and sync. Coral marks overdue or urgent items without feeling harsh.

The design system should be implemented token-first with Flutter Mix, while Material 3 remains the platform foundation. Every visual rule should make the app easier for a real mixed-device family to understand and use.
