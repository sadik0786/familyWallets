import 'user_model.dart';

class MemberModel {
  final String id;
  final String familyId;
  final String userId;
  final String role; // 'admin', 'manager', 'member', 'viewer'
  final DateTime joinedAt;
  final UserModel? userDetails; // Expanded details from user_profiles

  MemberModel({
    required this.id,
    required this.familyId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userDetails,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null 
          ? DateTime.parse(json['joined_at'] as String) 
          : DateTime.now(),
      userDetails: json['users'] != null 
          ? UserModel.fromJson(json['users'] as Map<String, dynamic>) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  MemberModel copyWith({
    String? id,
    String? familyId,
    String? userId,
    String? role,
    DateTime? joinedAt,
    UserModel? userDetails,
  }) {
    return MemberModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      userDetails: userDetails ?? this.userDetails,
    );
  }
}
