import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/auth_state.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (authProvider.errorMessage.isNotEmpty)
                Text(
                  authProvider.errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    authProvider.state ==
                            AuthState
                                .loading // Changed here
                        ? null
                        : () {
                          if (_formKey.currentState!.validate()) {
                            authProvider.login(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            );
                          }
                        },
                child:
                    authProvider.state ==
                            AuthState
                                .loading // Changed here
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to Sign Up Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
