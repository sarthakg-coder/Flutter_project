/// UserModel represents the authenticated user's profile information.
///
/// Viva/Interview explanation:
/// "Models in Dart convert raw JSON maps received from the REST API
/// into strongly typed Dart objects using fromJson() factory constructor,
/// preventing runtime type errors and null reference exceptions."
class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? location;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.location,
    this.createdAt,
  });

  /// Factory constructor to parse JSON from backend into UserModel.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Converts UserModel instance to a JSON Map for API updates (PUT requests).
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'location': location,
    };
  }

  /// CopyWith helper to easily update fields in setState without mutation.
  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
