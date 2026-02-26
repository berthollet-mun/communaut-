class MemberModel {
  final int id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final DateTime? joinedAt;

  MemberModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.joinedAt,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: _parseInt(
        json['id'] ?? json['member_id'] ?? json['user_id'],
        defaultValue: 0,
      ),
      email: (json['email'] ?? '').toString(),
      nom: (json['nom'] ?? json['last_name'] ?? '').toString(),
      prenom: (json['prenom'] ?? json['first_name'] ?? '').toString(),
      role: (json['role'] ?? 'MEMBRE').toString().toUpperCase(),
      joinedAt: _parseDate(json['joined_at'] ?? json['joinedAt']),
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'role': role,
      if (joinedAt != null) 'joined_at': joinedAt!.toIso8601String(),
    };
  }

  /// ✅ AJOUT IMPORTANT
  MemberModel copyWith({
    int? id,
    String? email,
    String? nom,
    String? prenom,
    String? role,
    DateTime? joinedAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  String get fullName => '$prenom $nom'.trim();
}
