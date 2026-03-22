import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_config.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services here:
  // - Drift database
  // - Secure storage
  // - Socket.IO
  // - Local notifications
  // - etc.
  
  runApp(
    const ProviderScope(
      child: SwiftNestApp(),
    ),
  );
}

class SwiftNestApp extends ConsumerWidget {
  const SwiftNestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to trigger router refresh when auth changes
    final authState = ref.watch(authStateProvider);
    
    // Create router with current auth state
    final router = AppRouter.createRouter(authState);

    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
