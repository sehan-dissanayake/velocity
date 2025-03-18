import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/auth_state.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:frontend/core/utils/storage_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await StorageService.init();
  runApp(const MyApp());
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
        title: 'My App',
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
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
        // Remove RouteGenerator reference until implementing it
      ),
    );
  }
}
