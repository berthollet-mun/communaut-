class ErrorResponse {
  final String error;
  final String code;
  final String? details;
  final int? statusCode;

  ErrorResponse({
    required this.error,
    required this.code,
    this.details,
    this.statusCode,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] ?? 'Erreur inconnue',
      code: json['code'] ?? 'UNKNOWN_ERROR',
      details: json['details'],
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'code': code,
      if (details != null) 'details': details,
      if (statusCode != null) 'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return 'ErrorResponse{error: $error, code: $code, details: $details}';
  }

  // Méthodes d'aide pour les erreurs courantes
  bool get isTokenInvalid => code == 'TOKEN_INVALID' || code == 'TOKEN_MISSING';
  bool get isPermissionDenied => code == 'PERMISSION_DENIED';
  bool get isNotFound => code == 'ROUTE_NOT_FOUND' || code == 'USER_NOT_FOUND';
  bool get isValidationError => code == 'VALIDATION_ERROR';
  bool get isRateLimit => code == 'RATE_LIMIT_EXCEEDED';
}
