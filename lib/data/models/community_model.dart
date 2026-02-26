class CommunityModel {
  final int community_id;
  final String nom;
  final String description;
  final String invite_code;

  /// ⚠️ IMPORTANT :
  /// - role peut être vide ("") si l’endpoint details ne le renvoie pas.
  /// - le controller se chargera de conserver l’ancien role dans ce cas.
  final String role;

  final DateTime? joined_at;
  final DateTime? created_at;
  final String? creator_nom;
  final String? creator_prenom;
  final int members_count;
  final int projects_count;
  final int tasks_count;
  final int completed_tasks;

  CommunityModel({
    required this.community_id,
    required this.nom,
    required this.description,
    required this.invite_code,
    required this.role,
    this.joined_at,
    this.created_at,
    this.creator_nom,
    this.creator_prenom,
    this.members_count = 1,
    this.projects_count = 0,
    this.tasks_count = 0,
    this.completed_tasks = 0,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    // ✅ Support: item peut être { community: {...}, role: "..."} ou directement {...}
    final Map<String, dynamic> base =
        (json['community'] is Map<String, dynamic>)
        ? (json['community'] as Map<String, dynamic>)
        : json;

    // ✅ rôle: priorise role/your_role au niveau parent, puis dans base
    final dynamic roleRaw =
        json['your_role'] ?? json['role'] ?? base['your_role'] ?? base['role'];

    return CommunityModel(
      community_id: _parseInt(
        base['community_id'] ?? base['id'],
        defaultValue: 0,
      ),

      nom: _cleanText(
        (base['nom'] ?? base['name'] ?? base['community_name'] ?? '')
            .toString(),
      ),
      description: _cleanText(
        (base['description'] ?? base['desc'] ?? '').toString(),
      ),
      invite_code: (base['invite_code'] ?? base['code'] ?? '').toString(),

      // ✅ si role absent -> "" (important pour ne pas écraser ADMIN)
      role: _parseRole(roleRaw),

      joined_at: _parseDate(base['joined_at']),
      created_at: _parseDate(base['created_at']),
      creator_nom: base['creator_nom']?.toString(),
      creator_prenom: base['creator_prenom']?.toString(),
      members_count: _parseInt(base['members_count'], defaultValue: 1),
      projects_count: _parseInt(base['projects_count'], defaultValue: 0),
      tasks_count: _parseInt(base['tasks_count'] ?? base['total_tasks'], defaultValue: 0),
      completed_tasks: _parseInt(base['completed_tasks'] ?? base['done_tasks'], defaultValue: 0),
    );
  }

  static String _parseRole(dynamic raw) {
    if (raw == null) return '';
    final r = raw.toString().trim();
    if (r.isEmpty) return '';
    return r.toUpperCase();
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

  // ✅ corrige les entités HTML qu’on voit dans tes screenshots (&quot; &#039; ...)
  static String _cleanText(String s) {
    return s
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': community_id,
      'nom': nom,
      'description': description,
      'invite_code': invite_code,
      'role': role,
      if (joined_at != null) 'joined_at': joined_at!.toIso8601String(),
      if (created_at != null) 'created_at': created_at!.toIso8601String(),
      if (creator_nom != null) 'creator_nom': creator_nom,
      if (creator_prenom != null) 'creator_prenom': creator_prenom,
      'members_count': members_count,
      'projects_count': projects_count,
    };
  }

  CommunityModel copyWith({
    int? community_id,
    String? nom,
    String? description,
    String? invite_code,
    String? role,
    DateTime? joined_at,
    DateTime? created_at,
    String? creator_nom,
    String? creator_prenom,
    int? members_count,
    int? projects_count,
  }) {
    return CommunityModel(
      community_id: community_id ?? this.community_id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      invite_code: invite_code ?? this.invite_code,
      role: role ?? this.role,
      joined_at: joined_at ?? this.joined_at,
      created_at: created_at ?? this.created_at,
      creator_nom: creator_nom ?? this.creator_nom,
      creator_prenom: creator_prenom ?? this.creator_prenom,
      members_count: members_count ?? this.members_count,
      projects_count: projects_count ?? this.projects_count,
    );
  }

  String get fullCreatorName =>
      '${creator_prenom ?? ''} ${creator_nom ?? ''}'.trim();
}
