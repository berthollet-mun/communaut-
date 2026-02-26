class CommunityResponse {
  final int community_id;
  final String nom;
  final String description;
  final String invite_code;
  final String role;
  final int? members_count;
  final int? projects_count;

  CommunityResponse({
    required this.community_id,
    required this.nom,
    required this.description,
    required this.invite_code,
    required this.role,
    this.members_count,
    this.projects_count,
  });

  factory CommunityResponse.fromJson(Map<String, dynamic> json) {
    return CommunityResponse(
      community_id: json['community_id'],
      nom: json['nom'],
      description: json['description'],
      invite_code: json['invite_code'],
      role: json['role'],
      members_count: json['members_count'],
      projects_count: json['projects_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'community_id': community_id,
      'nom': nom,
      'description': description,
      'invite_code': invite_code,
      'role': role,
      if (members_count != null) 'members_count': members_count,
      if (projects_count != null) 'projects_count': projects_count,
    };
  }
}
