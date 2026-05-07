import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmptyStateNoGroupScreen extends ConsumerWidget {
  const EmptyStateNoGroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    final accentColor = const Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF252F3F) : Colors.white,
        elevation: 0,
        leading: const SizedBox(),
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.2),
              ),
              child: Icon(
                Icons.person_outline,
                size: 14,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SwiftNest',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Icon(
            Icons.more_vert,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Icon - Multiple avatars
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.15),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Avatar 1
                          Positioned(
                            left: 16,
                            top: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withOpacity(0.4),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Avatar 2
                          Positioned(
                            right: 24,
                            top: 16,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withOpacity(0.6),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Avatar 3
                          Positioned(
                            bottom: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFB366),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Vault Protected Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        border: Border.all(
                          color: accentColor.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.security_rounded,
                            size: 10,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'VAULT PROTECTED',
                            style: TextStyle(
                              color: Color(0xFF00BCD4),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Join a Collective',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Groups are private, end-to-end encrypted spaces for your team or community.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Create Group',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Secondary Link
                    GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Browse Public Collectives',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            _buildBottomNav(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252F3F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.chat_outlined, 'CHATS', isDark, false),
          _buildNavItem(Icons.group_outlined, 'GROUPS', isDark, true),
          _buildNavItem(Icons.download_outlined, 'DOWNLOADS', isDark, false),
          _buildNavItem(Icons.notifications_outlined, 'ALERTS', isDark, false),
          _buildNavItem(Icons.more_horiz, 'MORE', isDark, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isDark,
    bool isActive,
  ) {
    final primaryColor = const Color(0xFF0088CC);

    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: isActive
              ? primaryColor
              : (isDark ? Colors.grey[600] : Colors.grey[400]),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? primaryColor
                : (isDark ? Colors.grey[600] : Colors.grey[400]),
            fontSize: 8,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
