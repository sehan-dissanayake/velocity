import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/utils/auth_state.dart';
import 'package:frontend/features/auth/provider/auth_provider.dart';
import 'package:frontend/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late String _currentDateTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
    
    // Set current date and time
    _currentDateTime = "2025-03-22 13:55:34"; // Using the provided timestamp
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents resizing when keyboard appears
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
                colors: [
                  Color(0xFF000000),
                  Color(0xFF101114),
                  Color(0xFF15171A),
                ],
              ),
            ),
          ),

          // Subtle pattern overlay
          Opacity(
            opacity: 0.03,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.webp'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.1,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: bottomPadding > 0 ? bottomPadding : 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Back button
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

                    const SizedBox(height: 24),

                    // Sign Up header
                    Text(
                      "Create Account",
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 500.ms, delay: 200.ms)
                     .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      "Fill in your details to get started",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 500.ms, delay: 300.ms)
                     .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms),

                    const SizedBox(height: 24),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First & Last name row
                          Row(
                            children: [
                              // First name
                              Expanded(
                                child: _buildAnimatedField(
                                  label: "First Name",
                                  controller: _firstNameController,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'First name required';
                                    }
                                    return null;
                                  },
                                  delay: 400,
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Last name
                              Expanded(
                                child: _buildAnimatedField(
                                  label: "Last Name",
                                  controller: _lastNameController,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Last name required';
                                    }
                                    return null;
                                  },
                                  delay: 500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Email field
                          _buildAnimatedField(
                            label: "Email",
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            delay: 600,
                          ),

                          const SizedBox(height: 20),

                          // Phone field
                          _buildAnimatedField(
                            label: "Phone Number",
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                            delay: 700,
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          _buildAnimatedField(
                            label: "Password",
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            delay: 800,
                          ),

                          const SizedBox(height: 20),

                          // Confirm Password field
                          _buildAnimatedField(
                            label: "Confirm Password",
                            controller: _confirmPasswordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirmPassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            delay: 850,
                          ),

                          const SizedBox(height: 16),

                          // Password requirements
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Password requirements:",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildRequirementRow("At least 6 characters", _passwordController.text.length >= 6),
                                _buildRequirementRow(
                                  "Contains a number", 
                                  RegExp(r'[0-9]').hasMatch(_passwordController.text)
                                ),
                                _buildRequirementRow(
                                  "Contains a special character", 
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)
                                ),
                                _buildRequirementRow(
                                  "Passwords match", 
                                  _passwordController.text.isNotEmpty && 
                                  _passwordController.text == _confirmPasswordController.text
                                ),
                              ],
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 900.ms),

                          // Error message
                          if (authProvider.errorMessage.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage,
                                      style: GoogleFonts.montserrat(
                                        color: Colors.red.shade300,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 300.ms).shake(),

                          const SizedBox(height: 24),

                          // Terms and conditions
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: true,
                                  onChanged: (value) {},
                                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                                    if (states.contains(MaterialState.selected)) {
                                      return Colors.amber;
                                    }
                                    return Colors.grey.withOpacity(0.2);
                                  }),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: "I agree to the ",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.grey.shade400,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Terms of Service",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(text: " and "),
                                      TextSpan(
                                        text: "Privacy Policy",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 1000.ms),

                          const SizedBox(height: 24),

                          // Sign Up button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authProvider.state == AuthState.loading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_passwordController.text != _confirmPasswordController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Passwords do not match',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          backgroundColor: Colors.red.shade700,
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                      return;
                                    }
                                  
                                    await authProvider.signUp(
                                      firstName: _firstNameController.text.trim(),
                                      lastName: _lastNameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                                    if (authProvider.state == AuthState.authenticated) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HomeScreen(),
                                        ),
                                      );
                                    }
                                  }
                                },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                disabledBackgroundColor: Colors.amber.withOpacity(0.3),
                                disabledForegroundColor: Colors.black45,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: authProvider.state == AuthState.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Create Account",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 1100.ms)
                           .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1100.ms),

                          const SizedBox(height: 20),

                          // Login link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Login",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 1200.ms),

                          // Date and time stamp
                          const SizedBox(height: 20),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _currentDateTime,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "UTC",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade700,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 1300.ms),

                          // User login display
                          const SizedBox(height: 8),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.amber.withOpacity(0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "ashiduDissanayake",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.amber.withOpacity(0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ).animate(controller: _animationController)
                           .fadeIn(duration: 500.ms, delay: 1350.ms),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    required int delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade300,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 15,
          ),
          onChanged: (value) {
            // Trigger a rebuild to update password requirement indicators
            if (label == "Password" || label == "Confirm Password") {
              setState(() {});
            }
          },
          validator: validator,
          cursorColor: Colors.amber,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            prefixIcon: Icon(
              prefixIcon,
              color: Colors.grey.shade500,
              size: 20,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.amber, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            errorStyle: GoogleFonts.montserrat(
              color: Colors.red.shade400,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ).animate(controller: _animationController)
     .fadeIn(duration: 500.ms, delay: delay.ms)
     .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: delay.ms);
  }

  Widget _buildRequirementRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            color: isValid ? Colors.green : Colors.grey.shade500,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.montserrat(
              color: isValid ? Colors.green.shade300 : Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}