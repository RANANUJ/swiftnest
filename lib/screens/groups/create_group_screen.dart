import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create Group Screen - Create new group with name and contacts
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedAvatar;
  final List<String> _avatarEmojis = [
    '💼', '🎨', '🚀', '⚙️', '☕', '📊', '🎮', '📚', '🎵', '⚽', '🏢', '🌟',
  ];

  final List<Contact> _allContacts = [
    Contact(name: 'Elena Rodriguez', avatar: '👩', subtitle: '1:1 in message'),
    Contact(name: 'Marcus Chen', avatar: '👨', subtitle: 'Subscribed'),
    Contact(name: 'Sarah Jenkins', avatar: '👩', subtitle: '1:1 in message'),
    Contact(name: 'David Miller', avatar: '👨', subtitle: 'Subscribed'),
    Contact(name: 'Amara Okafor', avatar: '👩', subtitle: '1:1 in message'),
  ];

  final Set<String> _selectedContacts = {};

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Group'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Selection
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_selectedAvatar != null
                                ? accentColor
                                : primaryColor)
                            .withValues(alpha: 0.2),
                      ),
                      child: _selectedAvatar == null
                          ? Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: secondaryTextColor,
                            )
                          : Center(
                              child: Text(
                                _selectedAvatar!,
                                style: const TextStyle(fontSize: 48),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        _showAvatarPicker(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accentColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Add Photo',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Group Name Section
              Text(
                'GROUP NAME',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  hintText: 'Enter group name...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 32),

              // Contacts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONTACTS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                  if (_selectedContacts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'SELECTED ${_selectedContacts.length}',
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Search Contacts
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),

              const SizedBox(height: 12),

              // Contacts List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _allContacts.length,
                itemBuilder: (context, index) {
                  final contact = _allContacts[index];
                  final isSelected = _selectedContacts.contains(contact.name);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedContacts.remove(contact.name);
                          } else {
                            _selectedContacts.add(contact.name);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accentColor.withValues(alpha: 0.1)
                              : inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? accentColor
                                : primaryColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withValues(alpha: 0.2),
                              ),
                              child: Center(
                                child: Text(
                                  contact.avatar,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    contact.subtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedContacts.add(contact.name);
                                  } else {
                                    _selectedContacts.remove(contact.name);
                                  }
                                });
                              },
                              activeColor: accentColor,
                              side: BorderSide(
                                color: accentColor,
                                width: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _groupNameController.text.isEmpty ||
                          _selectedContacts.isEmpty
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Group "${_groupNameController.text}" created with ${_selectedContacts.length} members'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor:
                        accentColor.withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

  void _showAvatarPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    const accentColor = Color(0xFF00BCD4);

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _avatarEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _avatarEmojis[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedAvatar == emoji
                            ? accentColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class Contact {
  final String name;
  final String avatar;
  final String subtitle;

  Contact({
    required this.name,
    required this.avatar,
    required this.subtitle,
  });
}
