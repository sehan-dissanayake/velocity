import 'package:flutter/material.dart';
import 'package:frontend/features/auth/presentation/screens/welcome_screen.dart';
import 'package:frontend/features/auth/presentation/screens/third_screen.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          Column(
            children: [
              const Spacer(),
              // Train Image
              Image.asset('assets/images/train.webp', width: 250),
              const Spacer(),
              // Bottom Section
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF15171A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "No More Tickets",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Welcome to the Future of transport, this is what everyone waited for so long.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const Spacer(),
                      // Dots & Navigation Button
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _dot(context, screen: const WelcomeScreen()),
                                const SizedBox(width: 8),
                                _dot(
                                  context,
                                  active: true,
                                  screen: const SecondScreen(),
                                ),
                                const SizedBox(width: 8),
                                _dot(context, screen: const ThirdScreen()),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ThirdScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(16),
                              backgroundColor: Colors.amber,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(
    BuildContext context, {
    bool active = false,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: active ? 30 : 12,
        height: 12,
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.grey,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
