// ==========================================
// CONTRIBUTION MODEL
// ==========================================
class ContributionModel {
  final String id;
  final String familyId;
  final double amount;
  final String? contributorId;
  final String contributorName;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  ContributionModel({
    required this.id,
    required this.familyId,
    required this.amount,
    this.contributorId,
    required this.contributorName,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      contributorId: json['contributor_id'] as String?,
      contributorName: json['contributor_name'] as String? ?? 'Family Member',
      note: json['note'] as String?,
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String) 
          : DateTime.now(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'amount': amount,
      'contributor_id': contributorId,
      'contributor_name': contributorName,
      'note': note,
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'created_at': createdAt.toIso8601String(),
    };
  }

  ContributionModel copyWith({
    String? id,
    String? familyId,
    double? amount,
    String? contributorId,
    String? contributorName,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ContributionModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      amount: amount ?? this.amount,
      contributorId: contributorId ?? this.contributorId,
      contributorName: contributorName ?? this.contributorName,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ==========================================
// EXPENSE MODEL
// ==========================================
class ExpenseModel {
  final String id;
  final String familyId;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final String? addedBy;
  final String addedByName;
  final String? receiptUrl;
  final String? recurringRuleId;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.familyId,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    this.addedBy,
    required this.addedByName,
    this.receiptUrl,
    this.recurringRuleId,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String?,
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String) 
          : DateTime.now(),
      addedBy: json['added_by'] as String?,
      addedByName: json['added_by_name'] as String? ?? 'Family Member',
      receiptUrl: json['receipt_url'] as String?,
      recurringRuleId: json['recurring_rule_id'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'added_by': addedBy,
      'added_by_name': addedByName,
      'receipt_url': receiptUrl,
      'recurring_rule_id': recurringRuleId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? familyId,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? addedBy,
    String? addedByName,
    String? receiptUrl,
    String? recurringRuleId,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      addedBy: addedBy ?? this.addedBy,
      addedByName: addedByName ?? this.addedByName,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ==========================================
// BUDGET LIMIT MODEL
// ==========================================
class BudgetLimitModel {
  final String id;
  final String familyId;
  final String category;
  final double limitAmount;
  final int month;
  final int year;

  BudgetLimitModel({
    required this.id,
    required this.familyId,
    required this.category,
    required this.limitAmount,
    required this.month,
    required this.year,
  });

  factory BudgetLimitModel.fromJson(Map<String, dynamic> json) {
    return BudgetLimitModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      category: json['category'] as String? ?? 'All',
      limitAmount: (json['limit_amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'category': category,
      'limit_amount': limitAmount,
      'month': month,
      'year': year,
    };
  }
}

// ==========================================
// NOTIFICATION MODEL
// ==========================================
class NotificationModel {
  final String id;
  final String familyId;
  final String? userId;
  final String title;
  final String message;
  final String type; // 'low_balance', 'monthly_summary', 'upcoming_bills', 'member_activity'
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.familyId,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String? ?? 'system',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ==========================================
// SUBSCRIPTION MODEL
// ==========================================
class SubscriptionModel {
  final String id;
  final String familyId;
  final String tier; // 'free' or 'premium'
  final String status; // 'active', 'cancelled', 'expired'
  final DateTime? expiresAt;

  SubscriptionModel({
    required this.id,
    required this.familyId,
    required this.tier,
    required this.status,
    this.expiresAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      tier: json['tier'] as String? ?? 'free',
      status: json['status'] as String? ?? 'active',
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'tier': tier,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

// ==========================================
// ACTIVITY LOG MODEL
// ==========================================
class ActivityLogModel {
  final String id;
  final String familyId;
  final String? userId;
  final String userName;
  final String action;
  final String? details;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    required this.familyId,
    this.userId,
    required this.userName,
    required this.action,
    this.details,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String? ?? 'System',
      action: json['action'] as String,
      details: json['details'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
