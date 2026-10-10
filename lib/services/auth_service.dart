import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../core/backend/backend_api_client.dart';
import '../shared/models/token.dart';
import '../shared/models/base_response.dart';
import 'session_storage.dart';

class AppAuthException implements Exception {
  AppAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    BackendApiClient? apiClient,
    SessionStorage? tokenStorage,
    http.Client? httpClient,
  })  : _api = apiClient ?? BackendApiClient(httpClient: httpClient),
        _storage = tokenStorage ?? SessionStorage();

  final BackendApiClient _api;
  final SessionStorage _storage;

  final StreamController<Token?> _controller =
      StreamController<Token?>.broadcast();

  Token? _session;

  Stream<Token?> get onSessionChanged => _controller.stream;

  Token? get currentSession => _session;

  bool get isLoggedIn => _session != null && !_session!.isExpired;

  Future<void> init() async {
    _session = await _storage.read();
    if (_session != null && _session!.isExpired) {
      await logout();
      return;
    }
    _controller.add(_session);
  }

  Future<Token> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      throw AppAuthException('Username dan password wajib diisi');
    }

    try {
      final response = await _api.postJson(
        '/api/auth/login',
        {'username': username.trim(), 'password': password},
      );

      final br = BaseResponse<Map<String, dynamic>>.fromJson(
        response,
        (d) => Map<String, dynamic>.from(d as Map),
      );

      if (!br.isSuccess) {
        throw AppAuthException(br.message ?? 'Login gagal');
      }

      final sessionJson = br.data ?? {};
      final session = Token.fromLoginResponse(username: username.trim(), json: {'data': sessionJson});
      if (session.accessToken.isEmpty) {
        throw AppAuthException('Token login tidak diterima');
      }

      _session = session;
      await _storage.save(session);
      _controller.add(session);
      return session;
    } on BackendApiException catch (e) {
      final msg = e.message.toLowerCase();
      if (e.statusCode == 401 || msg.contains('invalid') || msg.contains('salah')) {
        throw AppAuthException('Username atau password salah');
      }
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Login gagal: $e');
    }
  }

  Future<void> logout() async {
    _session = null;
    await _storage.clear();
    _controller.add(null);
  }

  int? sessionTtlSeconds(Token? session) {
    if (session == null) return null;
    return session.expiresAt.difference(DateTime.now()).inSeconds;
  }

  bool isSessionExpired(Token? session) {
    final ttl = sessionTtlSeconds(session);
    return ttl != null && ttl <= 0;
  }

  Future<String?> bearerToken() async => _session?.accessToken;
}
