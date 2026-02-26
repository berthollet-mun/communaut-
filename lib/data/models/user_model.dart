// user_model.dart
class UserModel {
  final int user_id;
  final String email;
  final String? password;
  final String nom;
  final String prenom;
  final DateTime created_at;
  final String? token;

  UserModel({
    required this.user_id,
    required this.email,
    this.password,
    required this.nom,
    required this.prenom,
    required this.created_at,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('=== PARSING USER ===');
    print('JSON reçu: $json');
    print('====================');

    // ✅ Gère user_id OU id (selon l'endpoint)
    int userId;
    if (json.containsKey('user_id')) {
      userId = json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'];
    } else if (json.containsKey('id')) {
      userId = json['id'] is String ? int.parse(json['id']) : json['id'];
    } else {
      userId = 0;
    }

    return UserModel(
      user_id: userId,
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString(),
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      token: json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'email': email,
      if (password != null) 'password': password,
      'nom': nom,
      'prenom': prenom,
      'created_at': created_at.toIso8601String(),
      if (token != null) 'token': token,
    };
  }

  UserModel copyWith({
    int? user_id,
    String? email,
    String? password,
    String? nom,
    String? prenom,
    DateTime? created_at,
    String? token,
  }) {
    return UserModel(
      user_id: user_id ?? this.user_id,
      email: email ?? this.email,
      password: password ?? this.password,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      created_at: created_at ?? this.created_at,
      token: token ?? this.token,
    );
  }

  String get fullName => '$prenom $nom'.trim();

  @override
  String toString() {
    return 'UserModel(user_id: $user_id, email: $email, nom: $nom, prenom: $prenom)';
  }
}
