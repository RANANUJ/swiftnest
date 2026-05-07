import 'package:flutter/material.dart';

class FileItem {
  final String name;
  final String size;
  final String dateModified;
  final IconData icon;
  final Color iconColor;
  bool isSelected;

  FileItem({
    required this.name,
    required this.size,
    required this.dateModified,
    required this.icon,
    required this.iconColor,
    this.isSelected = false,
  });
}

class FileSharingScreen extends StatefulWidget {
  const FileSharingScreen({super.key});

  @override
  State<FileSharingScreen> createState() => _FileSharingScreenState();
}

class _FileSharingScreenState extends State<FileSharingScreen> {
  late TextEditingController _searchController;
  late List<FileItem> files;
  String _selectedCategory = 'All Files';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Start with empty files list - no fake data
    files = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _selectedCount => files.where((f) => f.isSelected).length;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentCyan = Color(0xFF00BCD4);
    final backgroundColor = isDark ? Color(0xFF121A2A) : Colors.white;
    final inputFillColor =
        isDark ? Color(0xFF252F3F) : Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF1A2332) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'File Sharing',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '$_selectedCount selected',
                  style: TextStyle(
                    color: accentCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: inputFillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Color(0xFF3A4556) : Color(0xFFE0E0E0),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your secure files...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Category Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryTab(
                    label: 'All Files',
                    isSelected: _selectedCategory == 'All Files',
                    isDark: isDark,
                    accentCyan: accentCyan,
                    onTap: () => setState(() => _selectedCategory = 'All Files'),
                  ),
                  SizedBox(width: 8),
                  _buildCategoryTab(
                    label: 'Documents',
                    isSelected: _selectedCategory == 'Documents',
                    isDark: isDark,
                    accentCyan: accentCyan,
                    onTap: () => setState(() => _selectedCategory = 'Documents'),
                  ),
                  SizedBox(width: 8),
                  _buildCategoryTab(
                    label: 'Media',
                    isSelected: _selectedCategory == 'Media',
                    isDark: isDark,
                    accentCyan: accentCyan,
                    onTap: () => setState(() => _selectedCategory = 'Media'),
                  ),
                  SizedBox(width: 8),
                  _buildCategoryTab(
                    label: 'Downloads',
                    isSelected: _selectedCategory == 'Downloads',
                    isDark: isDark,
                    accentCyan: accentCyan,
                    onTap: () => setState(() => _selectedCategory = 'Downloads'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // File List
          Expanded(
            child: files.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: isDark
                              ? Colors.grey[600]
                              : Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No files selected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w600,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Select files to share',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16),
                    itemCount: files.length,
                    itemBuilder:
                        (context, index) {
                      final file =
                          files[index];
                      return _buildFileItem(
                        file: file,
                        isDark: isDark,
                        accentCyan:
                            accentCyan,
                        onTap: () {
                          setState(() =>
                              file
                                  .isSelected =
                                  !file
                                      .isSelected);
                        },
                      );
                    },
                  ),
          ),

          // Send Button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1A2332) : Colors.white,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? Color(0xFF252F3F) : Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _selectedCount > 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Sending $_selectedCount file(s) securely...')),
                        );
                        Navigator.pop(context);
                      }
                    : null,
                icon: Icon(Icons.send, size: 20),
                label: Text(
                  'Send Selected File${_selectedCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCount > 0 ? accentCyan : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(isDark, accentCyan),
    );
  }

  Widget _buildCategoryTab({
    required String label,
    required bool isSelected,
    required bool isDark,
    required Color accentCyan,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? Color(0xFF3A4556) : Color(0xFFE0E0E0),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem({
    required FileItem file,
    required bool isDark,
    required Color accentCyan,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: file.isSelected
              ? accentCyan.withValues(alpha: 0.1)
              : (isDark ? Color(0xFF252F3F) : Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file.isSelected
                ? accentCyan
                : (isDark ? Color(0xFF3A4556) : Color(0xFFE0E0E0)),
            width: file.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: file.isSelected ? accentCyan : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                  width: 2,
                ),
                color: file.isSelected ? accentCyan : Colors.transparent,
              ),
              child: file.isSelected
                  ? Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            SizedBox(width: 12),

            // File Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: file.iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                file.icon,
                color: file.iconColor,
                size: 20,
              ),
            ),

            SizedBox(width: 12),

            // File Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${file.size} • ${file.dateModified}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8),

            // Action Icon
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool isDark, Color accentCyan) {
    final items = ['Messages', 'Media', 'Vault', 'Settings'];
    final icons = [
      Icons.mail,
      Icons.image,
      Icons.lock,
      Icons.settings,
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A2332) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Color(0xFF252F3F) : Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[index],
                color: index == 2 ? accentCyan : (isDark ? Colors.grey[600] : Colors.grey[400]),
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                items[index],
                style: TextStyle(
                  fontSize: 10,
                  color: index == 2 ? accentCyan : (isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
