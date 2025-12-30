import 'package:flutter/material.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/screens/auth/login_screen.dart';
import 'package:panda_study_buddy/screens/room/create_room_screen.dart';
import 'package:panda_study_buddy/screens/room/join_room_screen.dart';
import 'package:panda_study_buddy/widgets/custom_button.dart';

/// Welcome screen - first screen users see
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Main panda image
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 270,
                    maxHeight: MediaQuery.of(context).size.height * 0.35, // 35% of the screen height
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFB4FFC7),
                        ),
                        child: Center(
                          child: Image.asset('assets/images/welcome_panda.jpg',
                            width: 800,
                            height: 800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Panda Study Buddy',
                  style: AppTextStyles.displayLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Tagline
                Text(
                  'Study together, feed your\npanda, and grow your forest.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Create Study Room button
                CustomButton(
                  text: 'Create Study Room',
                  icon: Icons.home_rounded,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateRoomScreen(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Join with Code button
                CustomButton(
                  text: 'Join with Code',
                  icon: Icons.qr_code_rounded,
                  isPrimary: false,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JoinRoomScreen(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMedium,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Log In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

