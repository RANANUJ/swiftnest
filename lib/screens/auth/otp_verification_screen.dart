import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

/// OTP Verification Screen - Verify with 6-digit code via email or phone
/// After verification, navigates to create profile (signup) or home (login)
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? phone;
  final String type; // 'signup' or 'login'

  const OtpVerificationScreen({
    super.key,
    this.email,
    this.phone,
    required this.type,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isResendAvailable = false;
  int _resendCountdown = 0;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _isResendAvailable = false;
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _isResendAvailable = true;
          } else {
            _startResendTimer();
          }
        });
      }
    });
  }

  void _handleOtpInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    if (index == 5 && value.isNotEmpty) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final emailToVerify = widget.email;
      
      if (emailToVerify == null || emailToVerify.isEmpty) {
        throw Exception('Email is required for OTP verification');
      }

      // Call verify OTP provider
      final verifyOtpNotifier = ref.read(verifyOtpProvider.notifier);
      await verifyOtpNotifier.verifyOtp(
        email: emailToVerify,
        code: otp,
      );

      // Check the result
      final verifyState = ref.read(verifyOtpProvider);
      
      // Handle the result
      bool success = false;
      String? errorMsg;
      
      verifyState.when(
        data: (response) {
          success = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✓ Verified! Email confirmed'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        loading: () {
          // Should not happen here since we awaited
        },
        error: (error, stack) {
          errorMsg = error.toString();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Verification failed: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      // Navigate if successful
      if (success && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // For signup: go to create profile
            if (widget.type == 'signup') {
              context.go('/create-profile');
            } else {
              // For login: go to home
              context.go('/home');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (!_isResendAvailable) return;

    try {
      final emailToResend = widget.email;
      
      if (emailToResend == null || emailToResend.isEmpty) {
        throw Exception('Email is required to resend OTP');
      }

      // Call send OTP to resend
      final sendOtpNotifier = ref.read(sendOtpProvider.notifier);
      await sendOtpNotifier.sendOtp(email: emailToResend);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Code sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getMaskedIdentifier() {
    if (widget.email != null) {
      final parts = widget.email!.split('@');
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    } else if (widget.phone != null) {
      return '***${widget.phone!.substring(widget.phone!.length - 4)}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    const accentColor = Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    final inputFillColor =
        isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5);
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A2332).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppConfig.appName,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 40,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verification Code',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                    ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Enter the 6-digit code sent to your ${widget.email != null ? 'email' : 'phone number'}.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
              ),

              const SizedBox(height: 8),

              // Masked identifier
              Text(
                _getMaskedIdentifier(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 40),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    height: 60,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      enabled: !_isVerifying,
                      onChanged: (value) => _handleOtpInput(value, index),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        counterText: '',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
                  ),
                  child: _isVerifying
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:  AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Verify & Continue',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                  ),
                  if (_isResendAvailable)
                    GestureDetector(
                      onTap: _handleResendCode,
                      child: Text(
                        'Resend',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  else
                    Text(
                      'Resend (${_resendCountdown}s)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Encryption banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'End-to-end encryption enabled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
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
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';

/// OTP Verification Screen - Verify with 6-digit code via email or phone
/// After verification, navigates to create profile (signup) or home (login)
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? phone;
  final String type; // 'signup' or 'login'

  const OtpVerificationScreen({
    super.key,
    this.email,
    this.phone,
    required this.type,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isResendAvailable = false;
  int _resendCountdown = 0;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _isResendAvailable = false;
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _isResendAvailable = true;
          } else {
            _startResendTimer();
          }
        });
      }
    });
  }

  void _handleOtpInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    if (index == 5 && value.isNotEmpty) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final emailToVerify = widget.email;
      
      if (emailToVerify == null || emailToVerify.isEmpty) {
        throw Exception('Email is required for OTP verification');
      }

      // Call verify OTP provider
      final verifyOtpNotifier = ref.read(verifyOtpProvider.notifier);
      await verifyOtpNotifier.verifyOtp(
        email: emailToVerify,
        code: otp,
      );

      // Read the verification response
      final verifyState = ref.read(verifyOtpProvider);
      
      final shouldContinue = await verifyState.whenData((response) async {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Verified! Welcome ${response.user.name}'),
              backgroundColor: Colors.green,
            ),
          );
          return true;
        }
        return false;
      }).catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Verification failed: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      });

      // Navigate after successful verification
      if (shouldContinue == true && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // For signup: go to create profile
            if (widget.type == 'signup') {
              context.go('/create-profile');
            } else {
              // For login: go to home
              context.go('/home');
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (!_isResendAvailable) return;

    try {
      final emailToResend = widget.email;
      
      if (emailToResend == null || emailToResend.isEmpty) {
        throw Exception('Email is required to resend OTP');
      }

      // Call send OTP to resend
      final sendOtpNotifier = ref.read(sendOtpProvider.notifier);
      await sendOtpNotifier.sendOtp(email: emailToResend);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Code sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Clear fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getMaskedIdentifier() {
    if (widget.email != null) {
      final parts = widget.email!.split('@');
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    } else if (widget.phone != null) {
      return '***${widget.phone!.substring(widget.phone!.length - 4)}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    const accentColor = Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    final inputFillColor =
        isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5);
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A2332).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppConfig.appName,
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 40,
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verification Code',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                    ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Enter the 6-digit code sent to your ${widget.email != null ? 'email' : 'phone number'}.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
              ),

              const SizedBox(height: 8),

              // Masked identifier
              Text(
                _getMaskedIdentifier(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),

              const SizedBox(height: 40),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    height: 60,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      enabled: !_isVerifying,
                      onChanged: (value) => _handleOtpInput(value, index),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        counterText: '',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Verify button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
                  ),
                  child: _isVerifying
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Verify & Continue',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                  ),
                  if (_isResendAvailable)
                    GestureDetector(
                      onTap: _handleResendCode,
                      child: Text(
                        'Resend',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  else
                    Text(
                      'Resend (${_resendCountdown}s)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Encryption banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'End-to-end encryption enabled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
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
}
