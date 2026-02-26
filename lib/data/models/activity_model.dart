class ActivityModel {
  final int id;
  final String activity_type;
  final String description;
  final String nom;
  final String prenom;
  final String email;
  final DateTime created_at;

  ActivityModel({
    required this.id,
    required this.activity_type,
    required this.description,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.created_at,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: _parseInt(json['id'] ?? json['activity_id'], defaultValue: 0),
      activity_type: json['activity_type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      created_at: _parseDate(json['created_at']) ?? DateTime.now(),
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
      'activity_type': activity_type,
      'description': description,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'created_at': created_at.toIso8601String(),
    };
  }

  ActivityModel copyWith({
    int? id,
    String? activity_type,
    String? description,
    String? nom,
    String? prenom,
    String? email,
    DateTime? created_at,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      activity_type: activity_type ?? this.activity_type,
      description: description ?? this.description,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      created_at: created_at ?? this.created_at,
    );
  }

  String get fullName => '$prenom $nom'.trim();
}
