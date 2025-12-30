import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/models/daily_stats.dart';
import 'package:panda_study_buddy/models/study_session.dart';
import 'package:panda_study_buddy/models/user.dart';
import 'package:panda_study_buddy/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(StudySessionAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(DailyStatsAdapter());
  
  // Open Hive boxes
  await Hive.openBox<StudySession>('sessions');
  await Hive.openBox<User>('users');
  await Hive.openBox<DailyStats>('stats');
  await Hive.openBox('app_data'); // General app data box
  
  runApp(
    const ProviderScope(
      child: PandaStudyBuddyApp(),
    ),
  );
}

class PandaStudyBuddyApp extends StatelessWidget {
  const PandaStudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda Study Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
