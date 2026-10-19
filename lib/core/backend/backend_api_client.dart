import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'backend_config.dart';

class BackendApiException implements Exception {
  BackendApiException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  final int statusCode;
  final String message;
  final dynamic body;

  @override
  String toString() => 'BackendApiException($statusCode): $message';
}

class BackendApiClient {
  BackendApiClient({http.Client? httpClient, this._bearerTokenProvider})
    : _http = httpClient ?? http.Client();

  final http.Client _http;
  final Future<String?> Function()? _bearerTokenProvider;

  /// Build a Uri for the request.
  ///
  /// Accepts either a relative path (e.g. '/api/users') or a full URL
  /// (e.g. 'https://example.com/api/users'). If `path` is already a full
  /// URI we parse and return it directly. Otherwise we join it to the
  /// configured BackendConfig.baseUrl.
  Uri _uri(String path) {
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return Uri.parse(p);
    }

    // Ensure we don't accidentally duplicate slashes
    final base = BackendConfig.baseUrl.trim();
    if (base.endsWith('/') && p.startsWith('/')) {
      return Uri.parse(base + p.substring(1));
    }
    if (!base.endsWith('/') && !p.startsWith('/')) {
      return Uri.parse('$base/$p');
    }
    return Uri.parse(base + p);
  }

  Future<Map<String, String>> _headers({bool json = true}) async {
    final provider = _bearerTokenProvider;
    final token = provider == null ? null : await provider();
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> getJson(String path) async {
    final uri = _uri(path);
    if (kDebugMode) debugPrint('GET $uri');
    final res = await _http.get(uri, headers: await _headers());
    return _decode(res);
  }

  Future<dynamic> postJson(String path, Object body) async {
    final uri = _uri(path);
    if (kDebugMode) debugPrint('POST $uri');
    final res = await _http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> putJson(String path, Object body) async {
    final uri = _uri(path);
    if (kDebugMode) debugPrint('PUT $uri');
    final res = await _http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> delete(String path) async {
    final uri = _uri(path);
    if (kDebugMode) debugPrint('DELETE $uri');
    final res = await _http.delete(uri, headers: await _headers());
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    dynamic body;
    if (res.body.isNotEmpty) {
      try {
        body = jsonDecode(res.body);
      } catch (_) {
        body = res.body;
      }
    }

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (!ok) {
      throw BackendApiException(
        statusCode: res.statusCode,
        message: _extractMessage(body) ?? 'HTTP ${res.statusCode}',
        body: body,
      );
    }
    return body;
  }

  String? _extractMessage(dynamic body) {
    if (body is Map) {
      return (body['message_id'] ??
              body['message_en'] ??
              body['message'] ??
              body['error'])
          ?.toString();
    }
    return null;
  }
}
