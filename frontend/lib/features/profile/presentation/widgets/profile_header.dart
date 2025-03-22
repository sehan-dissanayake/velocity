import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileHeader extends StatelessWidget {
  final String? profileImage;
  final String name;
  final String email;
  final AnimationController animationController;

  const ProfileHeader({
    Key? key,
    required this.profileImage,
    required this.name,
    required this.email,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactLayout = screenWidth < 360;

    if (useCompactLayout) {
      return _buildCompactHeader();
    } else {
      return _buildRegularHeader();
    }
  }

  Widget _buildRegularHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Profile image
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      profileImage != null && profileImage!.isNotEmpty
                          ? Image.network(
                            profileImage!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  strokeWidth: 2,
                                  color: Colors.amber,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print("Error loading profile image: $error");
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  if (error.toString().length <
                                      30) // Only show short errors
                                    Text(
                                      "Load error",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
                              );
                            },
                          )
                          : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                ),
              )
              .animate(controller: animationController)
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                delay: 400.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(width: 24),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      name,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    .animate(controller: animationController)
                    .fadeIn(duration: 500.ms, delay: 500.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      delay: 500.ms,
                    ),

                const SizedBox(height: 4),

                Text(
                      email,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.amber,
                      ),
                    )
                    .animate(controller: animationController)
                    .fadeIn(duration: 500.ms, delay: 600.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      delay: 600.ms,
                    ),

                const SizedBox(height: 4),

                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Active Account",
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(controller: animationController)
                    .fadeIn(duration: 500.ms, delay: 700.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      delay: 700.ms,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Profile image
          Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      profileImage != null && profileImage!.isNotEmpty
                          ? CachedNetworkImage(
                            imageUrl: profileImage!,
                            placeholder:
                                (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.amber,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                ),
              )
              .animate(controller: animationController)
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                delay: 400.ms,
                curve: Curves.easeOutBack,
              ),

          const SizedBox(height: 16),

          // Name and email
          Column(
            children: [
              Text(
                    name,
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  .animate(controller: animationController)
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 500.ms),

              const SizedBox(height: 4),

              Text(
                    email,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.amber,
                    ),
                  )
                  .animate(controller: animationController)
                  .fadeIn(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 600.ms),

              const SizedBox(height: 8),

              Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Active Account",
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(controller: animationController)
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 700.ms),
            ],
          ),
        ],
      ),
    );
  }
}
