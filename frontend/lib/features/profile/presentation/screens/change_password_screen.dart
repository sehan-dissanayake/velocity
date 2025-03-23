import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<ProfileProvider>(context, listen: false).updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      
      if (Provider.of<ProfileProvider>(context, listen: false).passwordStatus == PasswordUpdateStatus.success) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password updated successfully',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF101114),
      body: Container(
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
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
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
                     .fadeIn(duration: 300.ms, delay: 100.ms)
                     .slideX(begin: -0.2, end: 0, duration: 300.ms, delay: 100.ms),
                    
                    const SizedBox(width: 16),
                    
                    Text(
                      "Change Password",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 300.ms, delay: 150.ms),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ).animate(controller: _animationController)
                         .fadeIn(duration: 400.ms, delay: 200.ms)
                         .scale(
                           begin: const Offset(0.8, 0.8),
                           end: const Offset(1.0, 1.0),
                           duration: 400.ms, 
                           delay: 200.ms,
                           curve: Curves.easeOutBack,
                         ),
                        
                        const SizedBox(height: 24),
                        
                        // Description
                        Text(
                          "Enter your current password and choose a new password. Strong passwords are at least 8 characters long and include letters, numbers, and special characters.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ).animate(controller: _animationController)
                         .fadeIn(duration: 400.ms, delay: 300.ms),
                        
                        const SizedBox(height: 30),
                        
                        // Current password
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: "Current Password",
                          obscureText: _obscureCurrentPassword,
                          toggleObscure: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Current password is required';
                            }
                            return null;
                          },
                          delay: 400,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // New password
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: "New Password",
                          obscureText: _obscureNewPassword,
                          toggleObscure: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'New password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          delay: 500,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Confirm password
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: "Confirm New Password",
                          obscureText: _obscureConfirmPassword,
                          toggleObscure: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          delay: 600,
                        ),
                        
                        // Password requirements
                        const SizedBox(height: 20),
                        
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Password must:",
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildRequirementRow(
                                "Be at least 6 characters long",
                                _newPasswordController.text.length >= 6,
                              ),
                              _buildRequirementRow(
                                "Include at least one number",
                                RegExp(r'[0-9]').hasMatch(_newPasswordController.text),
                              ),
                              _buildRequirementRow(
                                "Include at least one special character",
                                RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_newPasswordController.text),
                              ),
                              _buildRequirementRow(
                                "Passwords match",
                                _newPasswordController.text.isNotEmpty && 
                                _newPasswordController.text == _confirmPasswordController.text,
                              ),
                            ],
                          ),
                        ).animate(controller: _animationController)
                         .fadeIn(duration: 400.ms, delay: 700.ms),

                        // Error message
                        if (profileProvider.errorMessage.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
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
                                    profileProvider.errorMessage,
                                    style: GoogleFonts.montserrat(
                                      color: Colors.red.shade300,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).shake(),
                        
                        const SizedBox(height: 30),
                        
                        // Update button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: profileProvider.passwordStatus == PasswordUpdateStatus.loading
                                ? null
                                : _updatePassword,
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
                            child: profileProvider.passwordStatus == PasswordUpdateStatus.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Update Password",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ).animate(controller: _animationController)
                         .fadeIn(duration: 400.ms, delay: 800.ms)
                         .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 800.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscure,
    required String? Function(String?) validator,
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
          obscureText: obscureText,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 15,
          ),
          validator: validator,
          cursorColor: Colors.amber,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.grey.shade500,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey.shade500,
              ),
              onPressed: toggleObscure,
            ),
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
     .fadeIn(duration: 400.ms, delay: delay.ms)
     .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: delay.ms);
  }

  Widget _buildRequirementRow(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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