import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../services/cache_service.dart';
import 'api_constant.dart';

@singleton
class HttpServices {
  final Duration _timeout = const Duration(seconds: 30);

  Future<Map<String, dynamic>> get(
    String endPoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final token = await CacheService.getAccessToken();
      final url = ApiConstant.baseUrl + endPoint;

      // Merge custom headers with default headers and token
      final finalHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers, // Custom headers override defaults
      };

      _logRequest('GET', url, headers: finalHeaders, token: token);

      final response = await http
          .get(Uri.parse(url), headers: finalHeaders)
          .timeout(_timeout);

      return _processResponse(response);
    } catch (e, trace) {
      log('❌ GET Error: $e\n$trace', name: 'HttpServices');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
    String endPoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final token = await CacheService.getAccessToken();
      final url = ApiConstant.baseUrl + endPoint;

      // Merge custom headers with default headers and token
      final finalHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?headers, // Custom headers override defaults
      };

      _logRequest('POST', url, headers: finalHeaders, token: token, body: body);

      final response = await http
          .post(
            Uri.parse(url),
            headers: finalHeaders,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(_timeout);

      return _processResponse(response);
    } catch (e, trace) {
      log('❌ POST Error: $e\n$trace', name: 'HttpServices');
      rethrow;
    }
  }

  void _logRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    String? token,
    dynamic body,
  }) {
    log(
      '🌐 $method Request\n'
      '📍 URL: $url\n'
      '🔑 Token: ${token != null ? '${token.substring(0, 10)}...' : 'None'}\n'
      '📋 Headers: ${headers ?? 'Default'}\n'
      '📦 Body: ${body ?? 'None'}',
      name: 'HttpServices',
    );
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    log(
      '📥 Response\n'
      '📊 Status: ${response.statusCode}\n'
      '📄 Body: ${response.body}',
      name: 'HttpServices',
    );

    final body = json.decode(response.body);

    if (body is Map<String, dynamic>) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body.isEmpty) return {};
        return body;
      } else if (response.statusCode == 422) {
        throw NoDataException(
          body['error'] ?? body['message'] ?? 'Validation error',
        );
      } else if (response.statusCode == 401) {
        throw Exception(body['error'] ?? 'Unauthorized access');
      } else {
        throw Exception(body['error'] ?? 'An error occurred');
      }
    } else {
      if (body is List) {
        return {'data': body};
      } else {
        throw Exception(
          'Unexpected server response format. Please try again later.',
        );
      }
    }
  }
}

class NoDataException implements Exception {
  final String message;

  NoDataException(this.message);
}
