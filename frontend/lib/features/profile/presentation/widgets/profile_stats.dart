import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileStats extends StatelessWidget {
  final int totalTrips;
  final double totalDistance;
  final AnimationController animationController;

  const ProfileStats({
    Key? key,
    required this.totalTrips,
    required this.totalDistance,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [const Color(0xFF232529), const Color(0xFF1C1E22)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats title
                Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Your Stats",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                    .animate(controller: animationController)
                    .fadeIn(duration: 500.ms, delay: 800.ms),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  children: [
                    // Total trips
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.train_rounded,
                        value: totalTrips.toString(),
                        label: "Total Trips",
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D5BCA), Color(0xFF4365BF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        delay: 850,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Distance traveled
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.route_rounded,
                        value: "${totalDistance.toStringAsFixed(1)} km",
                        label: "Distance",
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA15E25), Color(0xFFB86D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        delay: 900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Last login
                Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey.shade500,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Last Login: 2025-03-22 15:47:38 UTC",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    )
                    .animate(controller: animationController)
                    .fadeIn(duration: 500.ms, delay: 950.ms),
              ],
            ),
          ),
        )
        .animate(controller: animationController)
        .fadeIn(duration: 500.ms, delay: 800.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 800.ms);
  }

  // In the build method, you could add these safeguards:

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Gradient gradient,
    required int delay,
  }) {
    // Make sure value is not null or invalid
    String displayValue = value;
    if (value.contains("null") || value.isEmpty) {
      displayValue = "0";
    }

    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 12),
              Text(
                displayValue,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        )
        .animate(controller: animationController)
        .fadeIn(duration: 500.ms, delay: delay.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          delay: delay.ms,
        );
  }
}
