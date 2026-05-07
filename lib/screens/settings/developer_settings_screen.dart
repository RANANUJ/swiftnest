import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// Developer Settings Screen - Change backend URL and debug options
class DeveloperSettingsScreen extends StatefulWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  State<DeveloperSettingsScreen> createState() => _DeveloperSettingsScreenState();
}

class _DeveloperSettingsScreenState extends State<DeveloperSettingsScreen> {
  late TextEditingController _backendUrlController;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController(text: AppConfig.apiBaseUrl);
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  void _saveBackendUrl() {
    final newUrl = _backendUrlController.text.trim();
    
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!newUrl.startsWith('http://') && !newUrl.startsWith('https://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL must start with http:// or https://'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    AppConfig.setApiBaseUrl(newUrl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Backend URL updated to: $newUrl'),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _resetToDefault() {
    _backendUrlController.text = 'http://192.168.0.122:3000';
    AppConfig.setApiBaseUrl('http://192.168.0.122:3000');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to default backend'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Developer Settings',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Developer Options',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These settings are for development only. Use with caution.',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Current Backend URL
              Text(
                'Current Backend URL',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  AppConfig.apiBaseUrl,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Backend URL Input
              Text(
                'New Backend URL',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _backendUrlController,
                decoration: InputDecoration(
                  hintText: 'e.g., http://192.168.0.122:3000',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  prefixIcon: Icon(Icons.link, color: primaryColor),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: primaryColor),
              ),

              const SizedBox(height: 24),

              // Quick presets
              Text(
                'Quick Presets',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
              ),

              const SizedBox(height: 12),

              // Localhost preset
              ElevatedButton.icon(
                onPressed: () {
                  _backendUrlController.text = 'http://localhost:3000';
                },
                icon: const Icon(Icons.computer),
                label: const Text('Localhost (Dev PC)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                ),
              ),

              const SizedBox(height: 12),

              // Custom IP preset
              ElevatedButton.icon(
                onPressed: () {
                  _backendUrlController.text = 'http://192.168.0.122:3000';
                },
                icon: const Icon(Icons.router),
                label: const Text('Your PC IP (192.168.0.122)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                ),
              ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveBackendUrl,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Backend URL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Reset button
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _resetToDefault,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset to Default'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Configure Backend URL:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Find your PC\'s IP: Run "ipconfig" on Windows',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2. Note the IPv4 Address (e.g., 192.168.0.122)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '3. Make sure phone and PC are on same WiFi',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4. Enter URL: http://YOUR_PC_IP:3000',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
