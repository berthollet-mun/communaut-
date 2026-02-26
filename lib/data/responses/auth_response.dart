class AuthResponse {
  final int user_id;
  final String email;
  final String nom;
  final String prenom;
  final String token;
  final DateTime? created_at;

  AuthResponse({
    required this.user_id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.token,
    this.created_at,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user_id: json['user_id'],
      email: json['email'],
      nom: json['nom'],
      prenom: json['prenom'],
      token: json['token'],
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'token': token,
      if (created_at != null) 'created_at': created_at!.toIso8601String(),
    };
  }
}
