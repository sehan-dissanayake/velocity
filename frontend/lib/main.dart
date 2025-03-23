import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/auth/presentation/screens/welcome_screen.dart';
import 'package:frontend/features/notifications/presentation/screens/notification_screens.dart';
import 'package:frontend/features/wallet/providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/auth_state.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/core/utils/storage_service.dart';
import 'package:frontend/features/core/presentation/screens/main_navigation_screen.dart';
import 'package:frontend/core/services/notification_service.dart';
import 'package:frontend/core/services/background_socket_handler.dart';
import 'package:frontend/features/notifications/background_notification_manager.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await dotenv.load();
  await StorageService.init();

  // Initialize notification service
  await NotificationService().init();

  // Initialize background service
  await BackgroundSocketHandler().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BackgroundNotificationManager()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => WalletProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            authProvider.initialize(); // Call initialize here
            return authProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Velociti',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/notifications': (context) => const NotificationsScreen(),
          // Add other routes here
        },
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.state == AuthState.error) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${authProvider.errorMessage}'),
                      ElevatedButton(
                        onPressed: () => authProvider.initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (authProvider.state == AuthState.loading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (authProvider.state == AuthState.authenticated) {
              return const MainNavigationScreen();
            }
            return const WelcomeScreen();
          },
        ),
        // Remove RouteGenerator reference until implementing it
      ),
    );
  }
}
