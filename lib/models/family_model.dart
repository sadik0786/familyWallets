class FamilyModel {
  final String id;
  final String name;
  final String inviteCode;
  final String? createdBy;
  final String subscriptionTier; // 'free' or 'premium'
  final bool isActive;
  final DateTime createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    this.createdBy,
    this.subscriptionTier = 'free',
    this.isActive = true,
    required this.createdAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      createdBy: json['created_by'] as String?,
      subscriptionTier: json['subscription_tier'] as String? ?? 'free',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'created_by': createdBy,
      'subscription_tier': subscriptionTier,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  FamilyModel copyWith({
    String? id,
    String? name,
    String? inviteCode,
    String? createdBy,
    String? subscriptionTier,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      inviteCode: inviteCode ?? this.inviteCode,
      createdBy: createdBy ?? this.createdBy,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
