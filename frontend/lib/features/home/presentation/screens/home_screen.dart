import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/notifications/background_notification_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showTripHistory = false;
  
  // Dummy trips data for demonstration
  final List<Map<String, dynamic>> _tripHistory = [
    {
      'date': '2025-03-22',
      'time': '09:15',
      'source': 'Colombo Fort',
      'destination': 'Kandy',
      'fare': 'Rs. 150.00',
      'status': 'Completed'
    },
    {
      'date': '2025-03-20',
      'time': '14:30',
      'source': 'Kandy',
      'destination': 'Colombo Fort',
      'fare': 'Rs. 150.00',
      'status': 'Completed'
    },
    {
      'date': '2025-03-17',
      'time': '08:45',
      'source': 'Colombo Fort',
      'destination': 'Galle',
      'fare': 'Rs. 120.00',
      'status': 'Completed'
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller properly
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    // Start the animation when screen loads
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
    // Important: dispose the animation controller
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: _showTripHistory ? _buildTripHistoryView() : _buildHomeView(size),
    );
  }

  Widget _buildHomeView(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [  
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
                     
                    const SizedBox(height: 8),
                    
                    // Tagline
                    Text(
                      "Your Smart Travel Companion",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey[400],
                        letterSpacing: 1,
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 700.ms, delay: 1000.ms),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Feature buttons section
              Text(
                "Travel & Train Services",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate(controller: _animationController)
               .fadeIn(duration: 500.ms, delay: 1300.ms)
               .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 1300.ms),
              
              const SizedBox(height: 16),
              
              // Feature buttons - these are the two main feature buttons
              Row(
                children: [
                  // Live Train Insights Button
                  Expanded(
                    child: _buildFeatureButton(
                      title: "Live Train Insights",
                      subtitle: "Find your Train >",
                      icon: Icons.train_rounded,
                      onTap: () {
                        // Show dialog that we're navigating to map
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Navigating to train map view...',
                              style: GoogleFonts.montserrat(),
                            ),
                            backgroundColor: Colors.blue.shade700,
                            behavior: SnackBarBehavior.floating,
                          )
                        );
                        
                        // Navigate to map (placeholder for now)
                        // Navigator.pushNamed(context, '/train-map');
                      },
                      animationDelay: 1500,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Track Your Trips Button
                  Expanded(
                    child: _buildFeatureButton(
                      title: "Track Your   Trips",
                      subtitle: "Travel History >",
                      icon: Icons.history_rounded,
                      onTap: () {
                        // Toggle trip history view
                        setState(() {
                          _showTripHistory = true;
                        });
                      },
                      animationDelay: 1700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTripHistoryView() {
    return Column(
      children: [
        // Add SafeArea to avoid notch/status bar issues
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showTripHistory = false;
                    });
                  },
                ),
                Text(
                  "Your Trip History",
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Trip history list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tripHistory.length,
            itemBuilder: (context, index) {
              final trip = _tripHistory[index];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E2633),
                      const Color(0xFF171E28),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Trip header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.train_rounded,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "${trip['date']} • ${trip['time']}",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              trip['status'],
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Trip details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Source to destination
                          Row(
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.circle_outlined,
                                    size: 16,
                                    color: Colors.blue.shade300,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.amber.shade300,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trip['source'],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      trip['destination'],
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Fare details
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Fare",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Text(
                                  trip['fare'],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
              ).animate()
               .fadeIn(duration: 350.ms, delay: Duration(milliseconds: 100 * index))
               .slideY(begin: 0.2, end: 0, duration: 350.ms, delay: Duration(milliseconds: 100 * index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureButton({
    required String title, 
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required int animationDelay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[700]!,
              Colors.blue[900]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.orange[300],
              ),
            ),
          ],
        ),
      ).animate(controller: _animationController)
       .fadeIn(duration: 500.ms, delay: animationDelay.ms)
       .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: animationDelay.ms)
       .scale(
         begin: const Offset(0.95, 0.95),
         end: const Offset(1, 1),
         duration: 500.ms, 
         delay: animationDelay.ms,
       ),
    );
  }
}