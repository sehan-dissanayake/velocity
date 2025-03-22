import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_header.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_stats.dart';
import 'package:frontend/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:frontend/features/profile/presentation/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final String _currentDateTime = "2025-03-22 15:53:38";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!_isInitialized) {
      await Provider.of<ProfileProvider>(context, listen: false).loadProfile();
      _animationController.forward();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return _buildLoadingView();
          }

          if (profileProvider.profile == null) {
            return _buildErrorView(profileProvider.errorMessage);
          }

          final profile = profileProvider.profile!;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF101114),
                  Color(0xFF15171A),
                  Color(0xFF1A1D22),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 100.ms)
                           .slideX(begin: -0.2, end: 0, duration: 500.ms, delay: 100.ms),
                          
                          const SizedBox(width: 16),
                          
                          Text(
                            "Profile",
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 200.ms),
                           
                          const Spacer(),
                          
                          // Timestamp
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Text(
                              _currentDateTime,
                              style: GoogleFonts.montserrat(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 300.ms),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Profile header (avatar, name, email)
                    ProfileHeader(
                      profileImage: profile.profileImage,
                      name: profile.fullName,
                      email: profile.email,
                      animationController: _animationController,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Stats section
                    ProfileStats(
                      totalTrips: profile.stats.totalTrips,
                      totalDistance: profile.stats.totalDistance,
                      animationController: _animationController,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Menu items
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Settings",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 900.ms),
                           
                          const SizedBox(height: 16),
                          
                          ProfileMenuItem(
                            icon: Icons.person_outline,
                            title: "Edit Profile",
                            animationController: _animationController,
                            animationDelay: 1000,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              ).then((_) => _loadProfileData());
                            },
                          ),
                          
                          ProfileMenuItem(
                            icon: Icons.lock_outline,
                            title: "Change Password",
                            animationController: _animationController,
                            animationDelay: 1100,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          
                          ProfileMenuItem(
                            icon: Icons.notifications_outlined,
                            title: "Notifications",
                            subtitle: "Manage app notifications",
                            animationController: _animationController,
                            animationDelay: 1200,
                            onTap: () {
                              // Navigate to notifications settings
                            },
                          ),
                          
                          ProfileMenuItem(
                            icon: Icons.language_outlined,
                            title: "Language",
                            subtitle: "English (US)",
                            animationController: _animationController,
                            animationDelay: 1300,
                            onTap: () {
                              // Show language selector
                            },
                          ),
                          
                          ProfileMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: "Help & Support",
                            animationController: _animationController,
                            animationDelay: 1400,
                            onTap: () {
                              // Navigate to help center
                            },
                          ),
                          
                          ProfileMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: "About VeloCiti",
                            subtitle: "v1.0.0",
                            animationController: _animationController,
                            animationDelay: 1500,
                            onTap: () {
                              // Show about dialog
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Logout button
                          GestureDetector(
                            onTap: () => _showLogoutDialog(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Logout",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 1600.ms)
                           .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1600.ms),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // App version and copyright
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              "VeloCiti",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Version 1.0.0 | © 2025 VeloCiti",
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 500.ms, delay: 1700.ms),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF101114),
            Color(0xFF15171A),
            Color(0xFF1A1D22),
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: Colors.amber,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(String errorMessage) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF101114),
            Color(0xFF15171A),
            Color(0xFF1A1D22),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "Failed to load profile",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage.isEmpty ? "Please try again later" : errorMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitialized = false;
                  });
                  _loadProfileData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Try Again",
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D22),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
        title: Text(
          "Logout",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to logout from your account?",
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade300,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade400,
            ),
            child: Text(
              "Cancel",
              style: GoogleFonts.montserrat(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}