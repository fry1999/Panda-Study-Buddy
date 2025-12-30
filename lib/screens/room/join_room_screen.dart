import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/screens/home/home_screen.dart';
import 'package:panda_study_buddy/widgets/custom_button.dart';

/// Join room screen
class JoinRoomScreen extends ConsumerStatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  final List<TextEditingController> _controllers = List.generate(
    AppConstants.roomCodeLength,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    AppConstants.roomCodeLength,
    (index) => FocusNode(),
  );
  bool _isJoining = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _isCodeComplete => _code.length == AppConstants.roomCodeLength;

  Future<void> _joinRoom() async {
    if (!_isCodeComplete) return;

    setState(() => _isJoining = true);

      final authNotifier = ref.read(authProvider.notifier);
    
    // Create guest user if not already logged in
    if (!authNotifier.isLoggedIn) {
      await authNotifier.createGuestUser();
    }

    // Simulate joining room
    await Future.delayed(const Duration(seconds: 1));

    // Save partner connection (dummy partner ID for now)
    await authNotifier.setPartner('partner_001', _code);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Join Room'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
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
                    child: Stack(
                      children: [
                        // Status badge
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.forest_outlined,
                                  color: AppColors.bamboo,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'STATUS',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Waiting for code...',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Panda
                        Center(
                          child: Image.asset('assets/images/join_room_panda.jpg'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Pair with your buddy',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Code input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    AppConstants.roomCodeLength,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 44,
                        height: 50,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.grey300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.grey300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < AppConstants.roomCodeLength - 1) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            setState(() {}); // Update button state
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                // Join button
                CustomButton(
                  text: 'Join Room',
                  onPressed: _isCodeComplete ? _joinRoom : null,
                  isLoading: _isJoining,
                  icon: Icons.arrow_forward_rounded,
                ),
                
                const SizedBox(height: 16),
                
                // Create room link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Create a new room instead',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

