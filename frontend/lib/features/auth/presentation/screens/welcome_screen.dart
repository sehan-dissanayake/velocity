import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/features/auth/presentation/screens/second_screen.dart';
import 'package:frontend/features/auth/presentation/screens/third_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000000), Color(0xFF101114)],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Logo and Title with animation
                Column(
                  children: [
                    Hero(
                          tag: 'main_image',
                          child: Image.asset(
                            'assets/images/logo.webp',
                            width: 110,
                          ),
                        )
                        .animate(controller: _animationController)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1, 1),
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 16),

                    Text(
                          "VELOCITI",
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        )
                        .animate(controller: _animationController)
                        .fadeIn(duration: 500.ms, delay: 300.ms)
                        .shimmer(
                          duration: 1200.ms,
                          delay: 800.ms,
                          color: Colors.amber.withOpacity(0.5),
                        ),
                  ],
                ),

                const Spacer(),

                // Bottom card section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF15171A), Color(0xFF1A1D22)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content area
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  "Welcome to",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                )
                                .animate(controller: _animationController)
                                .fadeIn(duration: 500.ms, delay: 300.ms)
                                .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 500.ms,
                                  delay: 300.ms,
                                  curve: Curves.easeOut,
                                ),

                            Text(
                                  "VeloCiti",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    foreground:
                                        Paint()
                                          ..shader = const LinearGradient(
                                            colors: [
                                              Colors.amber,
                                              Color(0xFFFFD54F),
                                              Colors.amberAccent,
                                            ],
                                          ).createShader(
                                            const Rect.fromLTWH(0, 0, 200, 70),
                                          ),
                                  ),
                                )
                                .animate(controller: _animationController)
                                .fadeIn(duration: 500.ms, delay: 400.ms)
                                .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 500.ms,
                                  delay: 400.ms,
                                  curve: Curves.easeOut,
                                ),

                            const SizedBox(height: 10),

                            Text(
                                  "Welcome to the Future of transport, this is what everyone waited for so long.",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey.shade300,
                                  ),
                                )
                                .animate(controller: _animationController)
                                .fadeIn(duration: 500.ms, delay: 500.ms)
                                .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 500.ms,
                                  delay: 500.ms,
                                  curve: Curves.easeOut,
                                ),

                            const SizedBox(height: 10),

                            // Animated underline
                            AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  height: 2,
                                  width: _animationController.value * 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.amber,
                                        Colors.amberAccent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                                .animate(controller: _animationController)
                                .fadeIn(duration: 500.ms, delay: 600.ms)
                                .shimmer(duration: 1800.ms, delay: 1000.ms),
                          ],
                        ),
                      ),

                      // Spacer for flexible height
                      const SizedBox(height: 60),

                      // Navigation area with dots and button
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            // Dots
                            Expanded(
                              child: Row(
                                children: [
                                  _buildDot(
                                    context,
                                    active: true,
                                    screen: const WelcomeScreen(),
                                    index: 0,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDot(
                                    context,
                                    screen: const SecondScreen(),
                                    index: 1,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildDot(
                                    context,
                                    screen: const ThirdScreen(),
                                    index: 2,
                                  ),
                                ],
                              ),
                            ),

                            // Next button
                            _buildNextButton(
                              context,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (_, animation, secondaryAnimation) =>
                                            const SecondScreen(),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOutCubic;

                                      var tween = Tween(
                                        begin: begin,
                                        end: end,
                                      ).chain(CurveTween(curve: curve));

                                      var offsetAnimation = animation.drive(
                                        tween,
                                      );

                                      return SlideTransition(
                                        position: offsetAnimation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration: const Duration(
                                      milliseconds: 500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shared dot indicator
  Widget _buildDot(
    BuildContext context, {
    bool active = false,
    required Widget screen,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) => screen,
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
            width: active ? 30 : 12,
            height: 12,
            decoration: BoxDecoration(
              gradient:
                  active
                      ? const LinearGradient(
                        colors: [Colors.amber, Colors.amberAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                      : null,
              color: active ? null : Colors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
              boxShadow:
                  active
                      ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
          )
          .animate(controller: _animationController)
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 300.ms,
            delay: (700 + (index * 100)).ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  // Shared next button
  Widget _buildNextButton(
    BuildContext context, {
    required VoidCallback onPressed,
  }) {
    return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.amber,
              elevation: 0,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.black,
              size: 24,
            ),
          ),
        )
        .animate(controller: _animationController)
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: 800.ms,
          curve: Curves.elasticOut,
        )
        .shimmer(duration: 1800.ms, delay: 1200.ms);
  }
}
