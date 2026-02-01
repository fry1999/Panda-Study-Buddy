import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/theme/app_theme.dart';
import 'package:panda_study_buddy/providers/auth_provider.dart';
import 'package:panda_study_buddy/screens/home/home_screen.dart';

/// Login screen with Google authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildOverlay(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/backround.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // _buildWelcomeText(),
              _buildGoogleButton(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Panda Study Buddy',
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Focus better, study together',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.white.withOpacity(0.9),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleLoginWithGoogle,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textDark),
                    ),
                  )
                else ...[
                  Icon(Icons.login, size: 24, color: AppColors.textDark),
                  const SizedBox(width: 16),
                  Text(
                    'Continue with Google',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLoginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.signInWithGoogle();
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) {
        _showError('Login failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _showError('An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

