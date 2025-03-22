import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/notifications/background_notification_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final String _currentDateTime = "2025-03-22 14:47:26";
  final String _currentUser = "ashiduDissanayake";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
    
    // Start the background service if it's not running
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationManager = Provider.of<BackgroundNotificationManager>(
        context, 
        listen: false
      );
      
      if (!notificationManager.isRunning) {
        notificationManager.startService();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Welcome header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ).animate(controller: _animationController)
                       .fadeIn(duration: 500.ms, delay: 300.ms)
                       .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        _currentUser,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate(controller: _animationController)
                       .fadeIn(duration: 500.ms, delay: 400.ms)
                       .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 400.ms),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Premium Velociti Logo and Tagline
            Center(
              child: Column(
                children: [
                  // Logo with glow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.webp',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ).animate(controller: _animationController)
                   .scale(
                     begin: const Offset(0.5, 0.5),
                     end: const Offset(1, 1),
                     duration: 800.ms,
                     curve: Curves.easeOutBack,
                   ),
                  
                  const SizedBox(height: 24),
                  
                  // Title with shader mask
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.amber, Colors.amberAccent, Colors.amber],
                        stops: [0.2, 0.5, 0.8],
                      ).createShader(bounds);
                    },
                    child: Text(
                      "VELOCITI",
                      style: GoogleFonts.montserrat(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.amber.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ).animate(controller: _animationController)
                   .fadeIn(duration: 700.ms, delay: 700.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Tagline
                  Text(
                    "THE FUTURE OF TRANSPORT",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      color: Colors.grey.shade300,
                    ),
                  ).animate(controller: _animationController)
                   .fadeIn(duration: 500.ms, delay: 900.ms)
                   .shimmer(duration: 1200.ms, delay: 1000.ms),
                ],
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Feature cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildFeatureCard(
                    icon: Icons.map_outlined,
                    title: "Interactive Maps",
                    description: "Explore transport routes with real-time updates",
                    delay: 1100,
                  ),
                  
                  _buildFeatureCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: "Scan & Go",
                    description: "Quickly scan QR tickets for seamless transport",
                    delay: 1200,
                  ),
                  
                  _buildFeatureCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Digital Wallet",
                    description: "Manage tickets and payments in one place",
                    delay: 1300,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Extra space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E2126),
            const Color(0xFF15171A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(controller: _animationController)
     .fadeIn(duration: 500.ms, delay: delay.ms)
     .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: delay.ms, curve: Curves.easeOut);
  }
}