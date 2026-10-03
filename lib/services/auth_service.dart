import 'dart:async';

import 'package:http/http.dart' as http;

import '../core/backend/backend_api_client.dart';
import '../shared/models/backend_session.dart';
import 'token_storage.dart';

class AppAuthException implements Exception {
  AppAuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    BackendApiClient? apiClient,
    TokenStorage? tokenStorage,
    http.Client? httpClient,
  })  : _api = apiClient ?? BackendApiClient(httpClient: httpClient),
        _storage = tokenStorage ?? TokenStorage();

  final BackendApiClient _api;
  final TokenStorage _storage;

  final StreamController<BackendSession?> _controller =
      StreamController<BackendSession?>.broadcast();

  BackendSession? _session;

  Stream<BackendSession?> get onSessionChanged => _controller.stream;

  BackendSession? get currentSession => _session;

  bool get isLoggedIn => _session != null && !_session!.isExpired;

  Future<void> init() async {
    _session = await _storage.read();
    if (_session != null && _session!.isExpired) {
      await logout();
      return;
    }
    _controller.add(_session);
  }

  Future<BackendSession> login({
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

      if (response is! Map<String, dynamic>) {
        throw AppAuthException('Format response login tidak valid');
      }

      final session = BackendSession.fromLoginResponse(
        username: username.trim(),
        json: response,
      );
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

  Future<void> register({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    if (username.trim().isEmpty || password.isEmpty || fullName.trim().isEmpty) {
      throw AppAuthException('Username, password, dan nama lengkap wajib diisi');
    }

    try {
      await _api.postJson(
        '/api/auth/register',
        {
          'username': username.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'role': role,
        },
      );
    } on BackendApiException catch (e) {
      throw AppAuthException(e.message);
    }
  }

  Future<void> logout() async {
    _session = null;
    await _storage.clear();
    _controller.add(null);
  }

  int? sessionTtlSeconds(BackendSession? session) {
    if (session == null) return null;
    return session.expiresAt.difference(DateTime.now()).inSeconds;
  }

  bool isSessionExpired(BackendSession? session) {
    final ttl = sessionTtlSeconds(session);
    return ttl != null && ttl <= 0;
  }

  Future<String?> bearerToken() async => _session?.accessToken;
}
