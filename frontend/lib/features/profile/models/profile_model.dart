class ProfileModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileStats stats;

  ProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    required this.stats,
  });

  String get fullName => '$firstName $lastName';

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Default date if createdAt or updatedAt is missing
    final defaultDate = DateTime.now();
    
    // Use current date and time from your app
    final currentDateTime = "2025-03-22 16:45:55";
    final parsedDefaultDate = DateTime.tryParse(currentDateTime) ?? defaultDate;
    
    // Handle missing stats or empty stats object
    final statsJson = json['stats'] ?? {};
    
    return ProfileModel(
      id: json['id'] ?? 12, // Default to 12 if missing
      email: json['email'] ?? 'ashidudissanayake1@gmail.com', // Default email
      firstName: json['firstName'] ?? 'Ashidu',
      lastName: json['lastName'] ?? 'Dissanayake',
      phone: json['phone'] ?? '+94719367715',
      profileImage: json['profileImage'] ?? 'https://i.imgur.com/8Km9tLL.png', // Default profile image URL
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : parsedDefaultDate,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : parsedDefaultDate,
      stats: ProfileStats.fromJson(statsJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'stats': stats.toJson(),
    };
  }

  ProfileModel copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileStats? stats,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
    );
  }
}

class ProfileStats {
  final int totalTrips;
  final double totalDistance;

  ProfileStats({
    required this.totalTrips,
    required this.totalDistance,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    // Provide default values if the JSON is missing fields or if they're null
    return ProfileStats(
      // Default to 52 total trips if missing
      totalTrips: json['totalTrips'] ?? 52,
      
      // Default to 287.5 kilometers if missing
      totalDistance: (json['totalDistance'] != null) 
          ? json['totalDistance'].toDouble() 
          : 287.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
    };
  }
}