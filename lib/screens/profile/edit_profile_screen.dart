import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String? initialFullName;
  final String? initialUsername;
  final String? initialBio;

  const EditProfileScreen({
    Key? key,
    this.initialFullName,
    this.initialUsername,
    this.initialBio,
  }) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  int _selectedTab = 3; // Profile tab selected

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.initialFullName ?? 'Alex Sterling');
    _usernameController =
        TextEditingController(text: widget.initialUsername ?? 'asterling');
    _bioController = TextEditingController(
      text: widget.initialBio ??
          'Product Designer & Digital Architect. Building the future of secure communication at SwiftNest',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    final accentColor = const Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF252F3F) : Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // TODO: Save changes
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'Done',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Picture Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accentColor,
                              width: 4,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/avatar_edit.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Center(
                              child: Text(
                                '👤',
                                style: TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor,
                              border: Border.all(
                                color: backgroundColor,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              Icons.lock,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        // TODO: Open photo picker
                      },
                      child: Text(
                        'Change Photo',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildFormSection(
                      title: 'FULL NAME',
                      isDark: isDark,
                    ),
                    _buildTextField(
                      controller: _fullNameController,
                      hintText: 'Full Name',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),

                    // Username
                    _buildFormSection(
                      title: 'USERNAME',
                      isDark: isDark,
                    ),
                    _buildTextField(
                      controller: _usernameController,
                      hintText: '@username',
                      isDark: isDark,
                      prefixIcon: '@',
                    ),
                    const SizedBox(height: 20),

                    // Bio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFormSection(
                          title: 'BIO',
                          isDark: isDark,
                        ),
                        Text(
                          '${_bioController.text.length}/160',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    _buildTextAreaField(
                      controller: _bioController,
                      hintText: 'Bio',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'End-to-end encrypted profile details',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Save changes
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Save Changes',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(
        isDark: isDark,
        primaryColor: primaryColor,
        backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
        selectedIndex: _selectedTab,
        onTap: (index) {
          setState(() => _selectedTab = index);
        },
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required bool isDark,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    String? prefixIcon,
  }) {
    return TextField(
      controller: controller,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF252F3F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF0088CC),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        prefix: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  prefixIcon,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              )
            : null,
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      maxLines: 4,
      maxLength: 160,
      onChanged: (value) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF252F3F) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF0088CC),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        counterText: '',
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildBottomNav({
    required bool isDark,
    required Color primaryColor,
    required Color backgroundColor,
    required int selectedIndex,
    required Function(int) onTap,
  }) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.storage, 'label': 'VAULT'},
      {'icon': Icons.contacts_outlined, 'label': 'CONTACTS'},
      {'icon': Icons.security_outlined, 'label': 'SECURITY'},
      {'icon': Icons.person, 'label': 'PROFILE'},
    ];

    return Container(
      height: 65,
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    navItems[index]['icon'],
                    size: 24,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    navItems[index]['label'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
