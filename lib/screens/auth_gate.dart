import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/screens/auth/login_screen.dart';
import 'package:panda_study_buddy/screens/home/home_screen.dart';
import 'package:panda_study_buddy/screens/welcome_screen.dart';

/// AuthGate - Smart routing based on authentication and room status
/// 
/// Routing logic according to USER_FLOW.md:
/// 1. Not logged in → LoginScreen
/// 2. Logged in + has room → HomeScreen (skip welcome)
/// 3. Logged in + no room → WelcomeScreen (to create/join)
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Wait for auth provider to complete initialization
    final authNotifier = ref.read(authProvider.notifier);
    
    // Poll until auth is initialized (with timeout)
    final startTime = DateTime.now();
    while (!authNotifier.isInitialized && 
           DateTime.now().difference(startTime).inSeconds < 5) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    
    // Show loading while initializing
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Panda loading animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/welcome_panda.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Panda Study Buddy...',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Routing logic based on auth state and room status
    if (user == null) {
      // Case 1: Not logged in → LoginScreen
      return const LoginScreen();
    } else {
      // Case 2: Logged in + has room → HomeScreen (skip welcome)
      return const HomeScreen();
    } 
    //else {
    //   // Case 3: Logged in + no room → WelcomeScreen (to create/join)
    //   return const WelcomeScreen();
    // }
  }
}
