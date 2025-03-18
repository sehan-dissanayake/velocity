import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/features/auth/presentation/screens/second_screen.dart';
import 'package:frontend/features/auth/presentation/screens/third_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          Column(
            children: [
              const Spacer(),
              // Logo and Title
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.webp', // Your logo image
                    width: 100,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "VELOCITI",
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bottom Section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF15171A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to",
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "VeloCiti",
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Welcome to the Future of transport, this is what everyone waited for so long.",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const Spacer(),
                      // Dots and Navigation Button
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _dot(
                                  context,
                                  active: true,
                                  screen: const WelcomeScreen(),
                                ),
                                const SizedBox(width: 8),
                                _dot(context, screen: const SecondScreen()),
                                const SizedBox(width: 8),
                                _dot(context, screen: const ThirdScreen()),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SecondScreen(),
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
