class RailwayStation {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? services;
  final String? nameEn;
  final String? nameSi;
  final String? nameTa;
  final String? operatorType;
  final DateTime? createdAt;

  RailwayStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.services,
    this.nameEn,
    this.nameSi,
    this.nameTa,
    this.operatorType,
    this.createdAt,
  });

  factory RailwayStation.fromJson(Map<String, dynamic> json) {
    return RailwayStation(
      id:
          int.tryParse(json['id'].toString()) ??
          0, // Fallback to 0 if parsing fails
      name: json['name']?.toString() ?? 'Unknown',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      services: json['service']?.toString(),
      nameEn: json['name_en']?.toString(),
      nameSi: json['name_sin']?.toString(),
      nameTa: json['name_ta']?.toString(),
      operatorType: json['operator_type']?.toString(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  // Optional: Add a toJson method if you need to send data back to the server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'services': services,
      'name_en': nameEn,
      'name_si': nameSi,
      'name_ta': nameTa,
      'operator_type': operatorType,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
