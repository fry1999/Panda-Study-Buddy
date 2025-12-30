import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/screens/home/home_screen.dart';
import 'package:panda_study_buddy/widgets/custom_button.dart';

/// Create room screen
class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  bool _isCreating = false;
  String? _roomCode;

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);

    final authNotifier = ref.read(authProvider.notifier);
    
    // Create guest user if not already logged in
    if (!authNotifier.isLoggedIn) {
      await authNotifier.createGuestUser();
    }

    // Generate 6-digit room code
    final random = Random();
    final code = (100000 + random.nextInt(900000)).toString();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Save room code to user
    await authNotifier.setPartner(null, code);

    setState(() {
      _roomCode = code;
      _isCreating = false;
    });
  }

  void _continueToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              
              // Panda illustration
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5E9),
                      Color(0xFFF1F8F4),
                    ],
                  ),
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
                  child: Center(
                    child: Image.asset(
                      'assets/images/create_room_panda.jpg',
                      width: 280,
                      height: 280,
                    )
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              if (_roomCode == null) ...[
                // Title
                Text(
                  'Create Your Study Room',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Start a new study session and invite your study buddy to join!',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                // Room created
                Text(
                  'Room Created!',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Share this code with your study buddy:',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Room code display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _roomCode!,
                    style: AppTextStyles.displayLarge.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Button
              if (_roomCode == null)
                CustomButton(
                  text: 'Create Room',
                  onPressed: _createRoom,
                  isLoading: _isCreating,
                  icon: Icons.add_circle_outline,
                )
              else
                CustomButton(
                  text: 'Continue',
                  onPressed: _continueToHome,
                  icon: Icons.arrow_forward_rounded,
                ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

