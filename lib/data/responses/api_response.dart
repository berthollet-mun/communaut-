class ApiResponse {
  final bool success;
  final String? message; // message "UI-friendly"
  final dynamic data;
  final String? error; // erreur brute
  final String? code;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.code,
  });

  /// ✅ Toujours utile pour l'UI
  /// - si success => message
  /// - si error => error
  String get displayMessage {
    return (message?.toString().trim().isNotEmpty ?? false)
        ? message!.toString()
        : (error?.toString().trim().isNotEmpty ?? false)
        ? error!.toString()
        : '';
  }

  factory ApiResponse.success({String? message, dynamic data}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      error: null,
      code: null,
    );
  }

  /// ✅ IMPORTANT: on remplit aussi `message` pour ne jamais le perdre
  factory ApiResponse.error(String error, {String? code}) {
    return ApiResponse(
      success: false,
      message: error, // ✅ maintenant message n'est plus null en erreur
      data: null,
      error: error,
      code: code,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (error != null) 'error': error,
      if (code != null) 'code': code,
    };
  }
}

/// ✅ Optionnel mais très utile:
/// modèle "AuthResponse" si ton backend renvoie token + user_id + user infos
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

  static int _parseInt(dynamic v, {int defaultValue = 0}) {
    if (v == null) return defaultValue;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user_id: _parseInt(json['user_id']),
      email: (json['email'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      created_at: _parseDate(json['created_at']),
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
