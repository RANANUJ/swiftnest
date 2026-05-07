import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _selectedFilter = 'All Users';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    final accentColor = const Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
        ),
        title: const Text('User Management'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(isDark, 'Total Users', '1,124', primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(isDark, 'Active Now', '482', accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(isDark, 'Banned', '12', const Color(0xFFE74C3C)),
                    ),
                  ],
                ),
              ),

              // Search and Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search user by email or ID...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                    prefixIcon: Icon(Icons.search_outlined,
                        color: isDark ? Colors.grey[500] : Colors.grey[400], size: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All Users', 'Active', 'Inactive', 'Banned', 'Verified']
                        .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() => _selectedFilter = filter);
                            },
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            selectedColor: primaryColor.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: _selectedFilter == filter ? primaryColor : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              fontSize: 11,
                            ),
                          ),
                        ))
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // User List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildUserItem(isDark, 'John Stewart M.', '@john_stewart', 'john@mail.com', 'Active'),
                    _buildUserItem(isDark, 'Sarah Chao', '@sarah_chao', 'sarah@mail.com', 'Active'),
                    _buildUserItem(isDark, 'Marcus Thorne M', '@marcus', 'marcus@mail.com', 'Inactive'),
                    _buildUserItem(isDark, 'Amber Tray', '@amber_tray', 'amber@mail.com', 'Active'),
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

  Widget _buildStatBox(bool isDark, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(bool isDark, String name, String username, String email, String status) {
    final statusColor = status == 'Active' ? const Color(0xFF27AE60) : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0088CC).withOpacity(0.2),
            ),
            child: const Icon(Icons.person_outline, size: 18, color: Color(0xFF0088CC)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$username • $email',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
