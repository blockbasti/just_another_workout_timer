# Codebase Analysis: Just Another Workout Timer

## Executive Summary

Flutter-based workout timer app with interval training functionality. Currently **works only in foreground** - timer stops when app is backgrounded or screen locks. No background service or notification implementation exists.

**Core Issue:** Uses `Timer.periodic()` which is lifecycle-dependent and stops when app is minimized.

---

## Architecture Overview

### Technology Stack
- **Framework:** Flutter 3.35.7 / Dart 3.9.2
- **State Management:** Provider pattern with ChangeNotifier
- **UI:** Material Design 3 with Dynamic Color support
- **Platforms:** Android/iOS (focus on Android for background work)

### Project Structure
```
lib/
├── layouts/           # UI screens (home, builder, runner, settings)
├── utils/            # Core business logic and helpers
├── l10n/             # Localization (6 languages)
├── generated/        # Auto-generated code (translations, JSON serialization)
└── main.dart         # App entry point
```

---

## Timer Implementation Deep Dive

### Current Implementation (`lib/utils/timetable.dart`)

**Core Class:** `Timetable extends ChangeNotifier`

**Timer Mechanism:**
```dart
// Single periodic timer, 1-second intervals
_timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  _timerTick();
});
```

**Event Scheduling System:**
- Pre-computes ALL events for entire workout in `buildTimetable()`
- Stores events in `SplayTreeMap<int, Function>` keyed by second
- Events include: TTS announcements, sounds, UI updates, progress tracking

**State Properties:**
- `currentSecond` - Elapsed time tracker
- `currentSet` / `currentExercise` / `currentReps` - Position in workout
- `remainingSeconds` - Time left in current exercise
- `workoutDone` - Completion flag

**Lifecycle:**
1. `buildTimetable()` - Initialize event schedule
2. `timerStart()` - Create Timer.periodic
3. `_timerTick()` - Execute scheduled events each second
4. `timerStop()` - Cancel timer
5. `notifyListeners()` - Update UI via Provider

### Why It Fails in Background

**Problem:** Flutter's `Timer.periodic()` is tied to the app's lifecycle:
- **App minimized** → Timer pauses
- **Screen locks** → Timer stops
- **Memory cleanup** → Timer destroyed

**No Existing Mitigation:**
- No foreground service
- No WorkManager tasks
- No isolates for background execution
- No system notifications
- Wakelock only prevents screen sleep while app is visible

---

## Data Model Structure

### Hierarchy
```
Workout
├── title: String
├── sets: List<Set>
├── version: int
└── position: int
    │
    └── Set
        ├── id: String (UUID)
        ├── repetitions: int
        └── exercises: List<Exercise>
            │
            └── Exercise
                ├── id: String (UUID)
                ├── name: String
                └── duration: int (seconds)
```

### Serialization
- JSON-based with `json_annotation` + code generation
- Files stored: `getExternalStorageDirectory()/workouts/`
- Versioned schema with migration support

---

## Audio & Feedback Systems

### Text-to-Speech (`flutter_tts` package)
- **Helper:** `lib/utils/tts_helper.dart`
- Announces: Exercise names, countdowns, progress milestones
- Configurable: Engine, voice, language
- **Limitation:** Foreground only

### Sound Effects (`soundpool` package)
- **Helper:** `lib/utils/sound_helper.dart`
- Assets: `beep_low.wav`, `beep_high.wav`, `tick.wav`
- Usage: Interval transitions, countdown cues, halfway notifications
- Loaded at app startup in `main.dart`

### Wakelock (`wakelock_plus`)
- Keeps screen on during workout (optional)
- Enabled in `WorkoutPageState.initState()`
- **Does NOT enable background execution**

---

## State Management Details

### Provider Pattern Implementation

**Provider Setup:**
```dart
ChangeNotifierProvider(
  create: (context) => Timetable(context, workout),
  child: Consumer<Timetable>(
    builder: (context, timetable, child) => WorkoutPageContent(...)
  ),
)
```

**Notification Flow:**
```
Timetable._timerTick()
  → Update state properties
  → notifyListeners()
  → Consumer rebuilds UI
  → WorkoutPageContent updates
```

### Settings Management
- **Package:** `prefs` + `pref`
- **Wrapper:** `lib/utils/pref_service_shared.dart`
- **Persistence:** SharedPreferences

**Key Settings:**
- `theme` - System/Light/Dark
- `wakelock` - Screen wake during workout
- `sound` - Output mode (none/tts/beep)
- `tts_*` - Voice configuration
- `halftime` - Mid-exercise notification
- `ticks` - Second-by-second audio

---

## Key Files Reference

| File | Purpose | Critical for Background Fix |
|------|---------|------------------------------|
| `lib/utils/timetable.dart` | **Core timer logic** | ✅ YES - Needs background service integration |
| `lib/layouts/workout_runner.dart` | Workout execution UI | ✅ YES - Connects to notifications |
| `lib/main.dart` | App initialization | ⚠️ MAYBE - Service initialization |
| `lib/utils/tts_helper.dart` | Text-to-speech | ⚠️ MAYBE - Background TTS considerations |
| `lib/utils/sound_helper.dart` | Audio playback | ⚠️ MAYBE - Background audio |
| `lib/utils/workout.dart` | Data models | ⬜ NO - Just data structures |
| `lib/utils/storage_helper.dart` | File I/O | ⬜ NO - Not involved in timer |
| `android/app/src/main/AndroidManifest.xml` | Android config | ✅ YES - Needs permissions & service declaration |
| `android/app/src/main/kotlin/.../MainActivity.kt` | Android entry | ✅ YES - May need method channel for service |

---

## Dependencies Relevant to Background Work

**Currently Installed:**
- `provider: ^6.1.2` - State management (keep)
- `flutter_tts: ^4.0.2` - TTS (may need background handling)
- `soundpool: ^2.4.1` - Audio (may need background handling)
- `wakelock_plus: ^1.2.5` - Screen wake (insufficient for background)

**Will Need to Add:**
- `flutter_local_notifications` - System notifications
- `flutter_foreground_task` or `android_alarm_manager_plus` - Background service
- Or use native Android Foreground Service via method channels

---

## Android Platform Configuration

### Current State (`android/AndroidManifest.xml`)

**Permissions:** Minimal (just basic Flutter)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**Services:** None defined (only Flutter's MainActivity)

**Build Config (`android/app/build.gradle`):**
- Min SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Kotlin support enabled

### What's Missing for Background Execution

**Permissions Needed:**
```xml
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/> <!-- Android 13+ -->
```

**Service Declaration:**
```xml
<service
    android:name=".WorkoutTimerService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="false"/>
```

---

## Localization Support

**Languages:** English (default), German, French, Italian, Russian, Turkish

**Implementation:**
- `intl` package with `.arb` files in `lib/l10n/`
- Generated `S` class for translation access
- Automatic locale detection

**Note:** Notification text must also be localized

---

## Navigation & UI Flow

```
HomePage (workout list)
├── FloatingActionButton → BuilderPage (create workout)
├── Workout tile tap → WorkoutPage (execute with Timetable)
├── AppBar actions → Export/Import
└── Settings icon → SettingsPage

WorkoutPage (during execution)
├── Provider<Timetable> wraps entire page
├── WorkoutPageContent consumes Timetable state
├── Play/Pause button → timerStart() / timerStop()
├── Skip buttons → skipForward() / skipBackward()
└── Reset button → resetWorkout()
```

**Critical for Background:**
- WorkoutPage must handle app lifecycle events
- Need to persist timer state when backgrounded
- Must restore state when foregrounded

---

## Testing Observations

**Test Structure:** None found (no `/test` directory)

**Manual Testing Checklist for Background Fix:**
1. ✅ Timer continues when app minimized
2. ✅ Timer continues when screen locks
3. ✅ Notification shows current exercise + time
4. ✅ Notification pause/play works
5. ✅ TTS announcements work in background
6. ✅ Sound effects play in background
7. ✅ App state syncs when foregrounded
8. ✅ Notification dismisses when workout completes
9. ✅ Battery impact is reasonable
10. ✅ Handles phone calls / other interruptions

---

## Implementation Plan for Background Execution

### Approach 1: Flutter Plugin (Recommended)

**Use `flutter_local_notifications` + `android_alarm_manager_plus` or `workmanager`**

**Pros:**
- Pure Dart/Flutter code (mostly)
- Well-maintained packages
- Cross-platform potential

**Cons:**
- May have limitations on newer Android versions
- Plugin overhead

### Approach 2: Native Android Foreground Service

**Custom implementation via Method Channels**

**Pros:**
- Full control over Android service lifecycle
- Better performance
- Direct access to Android APIs

**Cons:**
- Requires Kotlin/Java code
- Android-only
- More complex implementation

### Recommended: Hybrid Approach

1. **Use `flutter_local_notifications`** for notification UI (media-style controls)
2. **Use `flutter_foreground_task`** or native service for background execution
3. **Keep Timetable logic** but make it background-aware
4. **Add state persistence** (save current second, exercise on background)
5. **Restore state** when foregrounded

---

## State Persistence Strategy

**What to Save (SharedPreferences or temp file):**
```dart
{
  "workoutInProgress": bool,
  "workoutId": String,
  "currentSecond": int,
  "isPaused": bool,
  "startTimestamp": int, // For drift correction
}
```

**When to Save:**
- On app background (lifecycle event)
- Every N seconds (periodic checkpoint)
- On pause/resume

**When to Restore:**
- On app foreground
- On service start (if killed)

---

## Notification Design (Spotify-Style)

### Required Information Display
1. **Title:** Current exercise name
2. **Text:** Remaining time (e.g., "0:35 remaining")
3. **Subtext:** Current set / total sets (e.g., "Set 2/4, Rep 3/5")

### Required Actions
1. **Play/Pause** - Toggle timer
2. **Skip Forward** - Next exercise
3. *Optional:* Skip Backward, Stop Workout

### Notification Style
- `MediaStyle` or `DecoratedMediaCustomViewStyle`
- Persistent notification (non-dismissible during workout)
- Updates every second for countdown

---

## Critical Code Locations for Modification

### 1. `lib/utils/timetable.dart`
**Changes Needed:**
- Add background service awareness
- Persist state on background
- Sync state on foreground resume
- Handle service callbacks for pause/play

### 2. `lib/layouts/workout_runner.dart`
**Changes Needed:**
- Listen to app lifecycle changes
- Trigger notification creation
- Handle notification action callbacks
- Update UI from background state

### 3. New File: `lib/utils/background_service.dart`
**Purpose:**
- Initialize foreground service
- Create/update notifications
- Handle action button callbacks
- Communicate with Timetable

### 4. `android/app/src/main/AndroidManifest.xml`
**Changes:**
- Add permissions
- Declare foreground service

### 5. `pubspec.yaml`
**Add Dependencies:**
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  flutter_foreground_task: ^8.0.0 # or custom native
```

---

## Potential Challenges & Mitigations

| Challenge | Impact | Mitigation |
|-----------|--------|------------|
| Android 12+ strict background limits | High | Use foreground service (required) |
| Battery optimization killing service | Medium | Request battery optimization exemption |
| Notification every second = battery drain | Medium | Update only when value changes |
| TTS in background may be throttled | Low | Test on multiple Android versions |
| Audio focus conflicts | Low | Request audio focus properly |
| Timer drift over long workouts | Low | Use timestamp-based correction |
| State sync issues on rapid background/foreground | Low | Use mutex/lock for state updates |

---

## Success Criteria

✅ **Functional Requirements:**
1. Timer continues running when app is backgrounded
2. Notification appears with current exercise details
3. Notification updates in real-time (remaining time)
4. Pause/Play button in notification works
5. TTS and sounds continue in background
6. App UI syncs when foregrounded
7. Workout completes successfully in background

✅ **Non-Functional Requirements:**
1. Battery usage < 5% per hour
2. No timer drift > 2 seconds per hour
3. Notification updates with < 500ms lag
4. App remains responsive when foregrounding
5. No crashes or ANRs (Application Not Responding)

---

## Current Package Dependencies

**State & UI:**
- `provider: ^6.1.2`
- `dynamic_color: ^1.7.0`
- `scrollable_positioned_list: ^0.3.8`
- `numberpicker: ^2.1.2`
- `fluttertoast: ^8.2.5`
- `flutter_phoenix: ^1.1.1`

**Audio & Feedback:**
- `flutter_tts: ^4.0.2`
- `soundpool: ^2.4.1`
- `wakelock_plus: ^1.2.5`

**Storage & Files:**
- `prefs: ^2.2.1`
- `pref: ^2.8.0`
- `path_provider: ^2.1.3`
- `flutter_file_dialog: ^3.0.2`
- `share_plus: ^9.0.0`

**Utilities:**
- `uuid: ^4.4.0`
- `intl: ^0.19.0`
- `json_annotation: ^4.9.0`

**Dev Dependencies:**
- `build_runner: ^2.4.11`
- `json_serializable: ^6.8.0`
- `flutter_launcher_icons: ^0.13.1`
- `flutter_native_splash: ^2.4.0`

---

## Next Steps for Implementation

1. ✅ **Analysis Complete** (this document)
2. ⬜ **Add Dependencies** (`flutter_local_notifications`, foreground service package)
3. ⬜ **Update Android Manifest** (permissions, service declaration)
4. ⬜ **Create Background Service** (new utility class)
5. ⬜ **Modify Timetable** (background awareness, state persistence)
6. ⬜ **Update WorkoutPage** (lifecycle handling, notification integration)
7. ⬜ **Implement Notification** (media-style with controls)
8. ⬜ **Test Thoroughly** (background, foreground, edge cases)
9. ⬜ **Optimize Battery** (reduce update frequency if needed)
10. ⬜ **Handle Permissions** (runtime requests for Android 13+)

---

## References

- **Flutter Background Execution:** https://docs.flutter.dev/platform-integration/android/background-processes
- **Android Foreground Services:** https://developer.android.com/develop/background-work/services/foreground-services
- **Flutter Local Notifications:** https://pub.dev/packages/flutter_local_notifications
- **Flutter Foreground Task:** https://pub.dev/packages/flutter_foreground_task
- **Android 14 Changes:** https://developer.android.com/about/versions/14/changes/fgs-types-required

---

## Future Tasks & Improvements

### Build Process Automation
**Issue:** Code generation (translations and OSS licenses) must be run manually before builds
**Required commands:**
```bash
flutter pub run intl_utils:generate
flutter pub run flutter_oss_licenses:generate.dart
```

**Solution Options:**
1. Add pre-build hook to run code generation automatically
2. Update CI/CD pipeline to include generation step
3. Create wrapper build script that runs generation first
4. Consider switching to Flutter's built-in code generation if possible

**Priority:** Medium - currently manageable but could cause build failures if forgotten

### Dependency Replacement
**Package:** `soundpool` (discontinued)
**Current usage:** Playing beep sounds and tick audio during workouts
**Replacement candidates:** `audioplayers`, `just_audio`
**Priority:** Medium - works for now but will become problematic with future Android SDK updates

---

*Last Updated: 2026-01-07*
*Analyzed by: Claude (Sonnet 4.5)*
