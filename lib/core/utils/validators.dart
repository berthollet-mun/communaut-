class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'La confirmation du mot de passe est requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    if (value.trim().isEmpty) {
      return '$fieldName ne peut pas être vide';
    }

    return null;
  }

  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code d\'invitation est requis';
    }

    if (value.length != 8) {
      return 'Le code d\'invitation doit contenir 8 caractères';
    }

    return null;
  }
}
