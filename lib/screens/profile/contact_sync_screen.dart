import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contact Sync Screen - Connect with friends by syncing contacts
class ContactSyncScreen extends ConsumerStatefulWidget {
  final String? fullName;
  final String? username;
  final String? bio;

  const ContactSyncScreen({
    super.key,
    this.fullName,
    this.username,
    this.bio,
  });

  @override
  ConsumerState<ContactSyncScreen> createState() => _ContactSyncScreenState();
}

class _ContactSyncScreenState extends ConsumerState<ContactSyncScreen> {
  String? _selectedProvider; // 'google', 'microsoft', 'icloud'
  bool _isSyncing = false;

  Future<void> _handleSyncContacts() async {
    if (_selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a contact provider'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      // TODO: Call backend to sync contacts
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts synced successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home after sync
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _handleSkip() {
    Navigator.of(context).pushReplacementNamed('/home');
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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.shield, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Digital Vault',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: secondaryTextColor),
            onPressed: _handleSkip,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.people,
                    size: 40,
                    color: accentColor,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'Connect with\nFriends',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                    ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Sync your contacts to find who else is on SwiftNest. Your contacts are encrypted and never stored on our servers.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: secondaryTextColor,
                    ),
              ),

              const SizedBox(height: 40),

              // Contact provider options
              Text(
                'SELECT CONTACT SOURCE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),

              const SizedBox(height: 16),

              // Gmail option
              _buildProviderOption(
                title: 'Gmail',
                icon: Icons.mail_outline,
                value: 'google',
                isSelected: _selectedProvider == 'google',
                isDark: isDark,
                primaryColor: primaryColor,
                backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
                secondaryTextColor: secondaryTextColor,
              ),

              const SizedBox(height: 12),

              // Outlook option
              _buildProviderOption(
                title: 'Outlook',
                icon: Icons.alternate_email,
                value: 'microsoft',
                isSelected: _selectedProvider == 'microsoft',
                isDark: isDark,
                primaryColor: primaryColor,
                backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
                secondaryTextColor: secondaryTextColor,
              ),

              const SizedBox(height: 12),

              // iCloud option
              _buildProviderOption(
                title: 'iCloud',
                icon: Icons.cloud_outlined,
                value: 'icloud',
                isSelected: _selectedProvider == 'icloud',
                isDark: isDark,
                primaryColor: primaryColor,
                backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
                secondaryTextColor: secondaryTextColor,
              ),

              const SizedBox(height: 40),

              // Sync button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSyncing ? null : _handleSyncContacts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                    disabledBackgroundColor:
                        accentColor.withValues(alpha: 0.5),
                  ),
                  child: _isSyncing
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
                            Icon(Icons.sync, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Sync Contacts',
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

              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: _handleSkip,
                child: Text(
                  'Maybe Later',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              const SizedBox(height: 32),

              // Privacy info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL DATA PROTECTION',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'When you sync, only hashes of contact names are sent to our servers. Your actual contact data stays encrypted on your device and never on our servers.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // User avatars
              Center(
                child: Wrap(
                  spacing: -12,
                  children: List.generate(3, (index) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: backgroundColor,
                          width: 2,
                        ),
                        color: [primaryColor, accentColor, primaryColor][index]
                            .withValues(alpha: 0.3),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: [primaryColor, accentColor, primaryColor][index],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 12),

              // Connected friends count
              Center(
                child: Text(
                  'Join thousands already connected',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11,
                      ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderOption({
    required String title,
    required IconData icon,
    required String value,
    required bool isSelected,
    required bool isDark,
    required Color primaryColor,
    required Color backgroundColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProvider = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDark ? Colors.white : const Color(0xFF1A2332),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
