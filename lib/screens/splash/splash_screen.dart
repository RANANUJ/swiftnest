import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

/// Splash Screen - Professional Login/Onboarding Screen
/// - Matches SwiftNest branding exactly
/// - Checks authentication status
/// - Shows loading animation with progress bar
/// - Routes to appropriate next screen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScale;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Logo scale animation
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Progress animation
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    // Check auth status after animation
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      if (!mounted) return;

      // If onboarding not completed, show onboarding screen
      if (!onboardingCompleted) {
        Navigator.of(context).pushReplacementNamed('/onboarding');
        return;
      }

      final authService = ref.read(authServiceProvider);
      final isLoggedIn = await authService.isTokenValid();

      if (!mounted) return;

      // Route based on auth status
      if (isLoggedIn) {
        // Go to home screen
        // Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Go to login screen
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      // Go to login on error
      // Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC); // SwiftNest teal blue
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    final secondaryTextColor = isDark 
        ? Colors.white.withValues(alpha: 0.6) 
        : const Color(0xFF1A2332).withValues(alpha: 0.6);
    const accentColor = Color(0xFF00BCD4); // Cyan accent

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top spacer to push content down
            Expanded(
              flex: 2,
              child: Container(),
            ),

            // Main content
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Shield Logo with animation
                  ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.security,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name - SwiftNest
                  Text(
                    AppConfig.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'FAST · PRIVATE · RELIABLE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Progress bar container
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        // Linear progress indicator
                        AnimatedBuilder(
                          animation: _progressValue,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: _progressValue.value,
                                minHeight: 2,
                                backgroundColor: secondaryTextColor.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  accentColor,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Status text
                        Text(
                          'Military-grade encryption active',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section with icons
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lock icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: primaryColor,
                          ),
                        ),

                        const SizedBox(width: 24),

                        // People icon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            Icons.people_outline,
                            size: 18,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
