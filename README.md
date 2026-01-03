# Panda Study Buddy 🐼📚

A beautiful Flutter study companion app with couple mode, Pomodoro timer, panda mascot states, bamboo rewards, and daily tracking.

## Features

### Core Features
- **Pomodoro Timer**: 25-minute focus sessions with 5-minute breaks
- **Panda Companion**: Your study buddy that changes states based on your study habits
- **Bamboo Rewards**: Earn bamboo shoots for each completed session
- **Daily Tracking**: Track your focus time, sessions, and streaks
- **Couple Mode**: Study together with a partner and track combined progress

### Panda States
- **Happy**: Completed at least one session today
- **Studying**: Currently in a focus session
- **Resting**: Daily goal achieved
- **Hungry**: No sessions today (after noon)
- **Neutral**: Default state

### Screens
1. **Welcome Screen**: Landing page with create/join room options
2. **Login/Signup**: Placeholder authentication
3. **Deep Focus**: Main timer screen with circular progress
4. **Success**: Session completion celebration
5. **Break**: Recharge screen with wellness tips
6. **Home**: Bottom navigation hub
7. **Calendar**: Study history and sessions
8. **Profile**: User stats and settings
9. **Recap**: Daily summary with partner stats

## Tech Stack

- **Framework**: Flutter (latest stable)
- **State Management**: Riverpod 2.x
- **Local Storage**: Hive (NoSQL database)
- **Architecture**: Clean Architecture with Repository pattern

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/          # App theme, colors, text styles
│   ├── constants/      # App constants and enums
│   └── utils/          # Utility functions
├── models/             # Data models with Hive adapters
├── repositories/       # Data access layer
├── providers/          # Riverpod state management
├── screens/            # UI screens
└── widgets/            # Reusable custom widgets
```

## Getting Started

### Prerequisites
- Flutter SDK (3.6.1 or higher)
- Dart SDK
- iOS Simulator / Android Emulator / Physical Device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Panda-Study-Buddy
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

5. Upload app
```bash
flutter build appbundle --release
```

## Usage

### First Time Setup
1. Launch the app
2. Choose to "Create Study Room" or "Join with Code"
3. Optional: Login or signup (placeholder authentication)

### Starting a Study Session
1. Navigate to the Home screen
2. Tap "Start Session" to begin a 25-minute focus session
3. The timer will count down with a visual progress ring
4. Complete the session to earn bamboo rewards

### Couple Mode
- Create a room and share the 6-digit code with your partner
- Join a room using your partner's code
- Track combined focus time and support each other

## Features Implementation Status

### ✅ Completed
- [x] Project setup with dependencies
- [x] Theme and design system
- [x] Data models with Hive
- [x] Repository layer
- [x] Riverpod providers (timer, session, stats, auth)
- [x] Custom widgets (CircularTimer, BambooCounter, etc.)
- [x] All main screens
- [x] Bottom navigation
- [x] Basic authentication flow
- [x] Room creation and joining
- [x] Daily stats tracking

### 🚧 Placeholder / To Be Implemented
- [ ] Real authentication (currently local storage only)
- [ ] Firebase integration for real-time sync
- [ ] Actual partner real-time status updates
- [ ] Push notifications
- [ ] Calendar heatmap visualization
- [ ] Forest growth visualization
- [ ] Achievements and badges
- [ ] Background music / white noise
- [ ] Export study data

## Architecture Notes

### State Management
The app uses Riverpod for state management with clear separation:
- **Providers**: Expose state and actions
- **Notifiers**: Handle business logic
- **Repositories**: Abstract data persistence

### Data Flow
```
UI → Provider → Notifier → Repository → Hive
```

### Timer Implementation
- Uses `Timer.periodic` for countdown
- Tracks start time for accuracy
- Persists state to survive app restarts
- Auto-completes and navigates to success screen

### Panda State Logic
Computed based on:
- Current timer state
- Today's session count
- Time of day
- Daily goal completion

## Future Enhancements

### Backend Integration
- Replace Hive with Firebase Firestore for cloud sync
- Implement Firebase Auth for real authentication
- Use Firebase Realtime Database for partner status
- Add Cloud Functions for room management
- Implement FCM for notifications

### Additional Features
- Calendar with contribution graph style heatmap
- Forest visualization (trees grow as you study)
- Study goals and custom durations
- Compete with friends via leaderboards
- Video call during study sessions (WebRTC)
- Chat messages between partners
- Achievements and level system

## Testing

Run tests:
```bash
flutter test
```

Run analyzer:
```bash
flutter analyze
```

## Design Philosophy

- **Calm & Focus-Friendly**: Minimal distractions, soothing colors
- **Delightful Interactions**: Cute panda mascot, bamboo rewards
- **Social Accountability**: Study with a partner
- **Habit Building**: Streaks and daily goals

## Credits

Created as a beautiful, production-ready Flutter study app with clean architecture and best practices.

## License

This project is for educational and personal use.
