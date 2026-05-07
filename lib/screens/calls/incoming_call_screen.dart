import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Incoming Call Screen - Handle incoming calls
class IncomingCallScreen extends ConsumerStatefulWidget {
  final String? callerName;
  final String? callerAvatar;
  final String? callType;

  const IncomingCallScreen({
    super.key,
    this.callerName,
    this.callerAvatar,
    this.callType,
  });

  @override
  ConsumerState<IncomingCallScreen> createState() =>
      _IncomingCallScreenState();
}

class _IncomingCallScreenState extends ConsumerState<IncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentColor = Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A2332).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              // Header info
              Column(
                children: [
                  Text(
                    'SWIFTNEST AUDIO CALL',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'YES IM NOT ENCRYPTED',
                    style: TextStyle(
                      fontSize: 12,
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Caller Avatar with pulse animation
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse ring animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.3).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Static ring
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                  // Avatar
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.2),
                    ),
                    child: Center(
                      child: Text(
                        widget.callerAvatar ?? '👤',
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Caller info
              Column(
                children: [
                  Text(
                    widget.callerName ?? 'Unknown Caller',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Encrypted Connection',
                    style: TextStyle(
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline Button
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Call from ${widget.callerName} declined')),
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE74C3C),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE74C3C)
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.phone_disabled,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),

                  // Accept Button
                  GestureDetector(
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        GoRouter.of(context).pushNamed(
                          'ongoing-call',
                          extra: {
                            'callerName': widget.callerName,
                            'callerAvatar': widget.callerAvatar,
                            'callType': widget.callType,
                          },
                        );
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Additional info
              Text(
                'Your calls are end-to-end encrypted',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
