import 'dart:convert';

import 'package:community/core/services/storage_service.dart';
import 'package:community/data/responses/api_response.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxService {
  static const String baseUrl = 'https://marpro.jobyrdc.com';
  final StorageService _storageService = Get.find();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(
        'Erreur de connexion: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(
        'Erreur de connexion: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  Future<ApiResponse> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(
        'Erreur de connexion: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  Future<ApiResponse> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(
        'Erreur de connexion: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse.error(
        'Erreur de connexion: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    print('=== API RESPONSE ===');
    print('URL: ${response.request?.url}');
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
    print('====================');

    // ✅ Gestion body vide
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ✅ petite amélioration: message "OK" si body vide
        return ApiResponse.success(message: 'OK', data: {});
      }
      return ApiResponse.error(
        'Erreur serveur (${response.statusCode})',
        code: 'EMPTY_RESPONSE',
      );
    }

    try {
      final dynamic decoded = json.decode(response.body);

      // Le backend peut renvoyer une liste ou un map
      final Map<String, dynamic> data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // ✅ NOUVEAU : Vérifier si le JSON contient success: false
        // car certains APIs renvoient 200 OK avec un corps d'erreur
        final bool isActuallySuccess = data['success'] ?? true;

        if (!isActuallySuccess) {
          final String error =
              (data['message'] ?? data['error'] ?? 'Erreur métier').toString();
          return ApiResponse.error(error,
              code: data['code']?.toString() ?? 'BUSINESS_ERROR');
        }

        final String? msg =
            (data['message'] ??
                    data['success_message'] ??
                    data['msg'] ??
                    data['status'])
                ?.toString();

        return ApiResponse.success(message: msg, data: data);
      } else {
        // ✅ 1) message simple
        String error = (data['error'] ?? data['message'] ?? 'Erreur inconnue')
            .toString();

        // ✅ 2) Laravel validation: errors:{field:[msg]}
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final firstKey = errors.keys.first;
            final firstVal = errors[firstKey];
            if (firstVal is List && firstVal.isNotEmpty) {
              error = firstVal.first.toString(); // ✅ message le plus utile
            } else if (firstVal != null) {
              error = firstVal.toString();
            }
          }
        }

        final code = data['code']?.toString() ?? 'HTTP_${response.statusCode}';
        return ApiResponse.error(error, code: code);
      }
    } catch (e) {
      print('JSON Parse Error: $e');
      return ApiResponse.error(
        'Réponse serveur invalide (JSON)',
        code: 'PARSE_ERROR',
      );
    }
  }
}
