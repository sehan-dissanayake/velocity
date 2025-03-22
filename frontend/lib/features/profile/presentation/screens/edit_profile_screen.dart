import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/profile/providers/profile_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    
    _firstNameController = TextEditingController(text: profile?.firstName ?? '');
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _emailController = TextEditingController(text: profile?.email ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<ProfileProvider>(context, listen: false).updateProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        profileImage: _profileImage,
      );
      
      if (Provider.of<ProfileProvider>(context, listen: false).updateStatus == ProfileUpdateStatus.success) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    
    if (profile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF101114),
        body: Center(
          child: Text(
            "Profile data not available",
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
        ),
      );
    }

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
                      "Edit Profile",
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 300.ms, delay: 150.ms),
                     
                    const Spacer(),
                    
                    TextButton(
                      onPressed: profileProvider.updateStatus == ProfileUpdateStatus.loading 
                        ? null 
                        : _updateProfile,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        "Save",
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ).animate(controller: _animationController)
                     .fadeIn(duration: 300.ms, delay: 200.ms),
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
                        // Profile image
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.amber, width: 2),
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                    ? Image.file(
                                        _profileImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : (profile.profileImage != null && profile.profileImage!.isNotEmpty)
                                      ? CachedNetworkImage(
                                          imageUrl: profile.profileImage!,
                                          placeholder: (context, url) => const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.amber,
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.grey.shade400,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate(controller: _animationController)
                         .fadeIn(duration: 400.ms, delay: 250.ms)
                         .scale(
                           begin: const Offset(0.8, 0.8),
                           end: const Offset(1.0, 1.0),
                           duration: 400.ms, 
                           delay: 250.ms,
                           curve: Curves.easeOutBack,
                         ),
                        
                        const SizedBox(height: 30),
                        
                        // Form fields
                        _buildTextField(
                          controller: _firstNameController, 
                          label: "First Name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                          delay: 350,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _lastNameController, 
                          label: "Last Name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Last name is required';
                            }
                            return null;
                          },
                          delay: 400,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _emailController, 
                          label: "Email",
                          icon: Icons.email_outlined,
                          readOnly: true, // Email cannot be changed
                          delay: 450,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        _buildTextField(
                          controller: _phoneController, 
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                          delay: 500,
                        ),

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

                        // Update button for small screens
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: profileProvider.updateStatus == ProfileUpdateStatus.loading
                              ? null
                              : _updateProfile,
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
                            child: profileProvider.updateStatus == ProfileUpdateStatus.loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Update Profile",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                        ).animate(controller: _animationController)
                         .fadeIn(duration: 400.ms, delay: 550.ms)
                         .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 550.ms),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? Function(String?)? validator,
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
          readOnly: readOnly,
          style: GoogleFonts.montserrat(
            color: readOnly ? Colors.grey.shade500 : Colors.white,
            fontSize: 15,
          ),
          validator: validator,
          cursorColor: Colors.amber,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.1),
            prefixIcon: Icon(
              icon,
              color: Colors.grey.shade500,
              size: 20,
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
}