import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ongoing Call Screen - Show active call interface
class OngoingCallScreen extends ConsumerStatefulWidget {
  final String? callerName;
  final String? callerAvatar;
  final String? callType;

  const OngoingCallScreen({
    super.key,
    this.callerName,
    this.callerAvatar,
    this.callType,
  });

  @override
  ConsumerState<OngoingCallScreen> createState() => _OngoingCallScreenState();
}

class _OngoingCallScreenState extends ConsumerState<OngoingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  int _seconds = 252; // 04:12
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(hours: 1),
      vsync: this,
    )..forward();

    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _seconds++;
        });
        _startTimer();
      }
    });
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    const accentColor = Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A2332).withValues(alpha: 0.6);
    final inputFillColor =
        isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'END-TO-END ENCRYPTED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Call options opened')),
                      );
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Caller Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Text(
                    widget.callerAvatar ?? '👤',
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Caller Name
              Text(
                widget.callerName ?? 'Unknown',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(height: 12),

              // Call Duration Timer
              Text(
                _formatDuration(_seconds),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
              ),

              const SizedBox(height: 8),

              // Call Status
              Text(
                'SwiftNest Private Vault',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Control Buttons Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Top row - MUTE, KEYPAD, SPEAKER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute Button
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: 'MUTE',
                          isActive: _isMuted,
                          onTap: () {
                            setState(() => _isMuted = !_isMuted);
                          },
                          backgroundColor: inputFillColor,
                          accentColor: accentColor,
                          isDark: isDark,
                        ),

                        // Keypad Button
                        _buildControlButton(
                          icon: Icons.dialpad,
                          label: 'KEYPAD',
                          isActive: false,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Keypad opened')),
                            );
                          },
                          backgroundColor: inputFillColor,
                          accentColor: accentColor,
                          isDark: isDark,
                        ),

                        // Speaker Button
                        _buildControlButton(
                          icon: _isSpeakerOn
                              ? Icons.volume_off
                              : Icons.volume_up,
                          label: 'SPEAKER',
                          isActive: _isSpeakerOn,
                          onTap: () {
                            setState(() => _isSpeakerOn = !_isSpeakerOn);
                          },
                          backgroundColor: inputFillColor,
                          accentColor: accentColor,
                          isDark: isDark,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Bottom row - END button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Call with ${widget.callerName} ended')),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFE74C3C),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE74C3C)
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_disabled,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'END',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? accentColor.withValues(alpha: 0.3)
                  : accentColor.withValues(alpha: 0.15),
              border: Border.all(
                color: isActive
                    ? accentColor.withValues(alpha: 0.5)
                    : accentColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
