import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manajemenasrama/core/backend/backend_api_client.dart';
import 'package:manajemenasrama/services/auth_service.dart';
import 'package:manajemenasrama/services/user_service.dart';
import 'package:manajemenasrama/shared/models/user_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('list parses array response', () async {
    final mock = MockClient((req) async {
      expect(req.method, 'GET');
      expect(req.url.path, '/api/users');
      expect(req.headers['Authorization'], 'Bearer token-123');
      return http.Response(
        jsonEncode([
          {'id': '1', 'username': 'ana', 'full_name': 'Ana', 'role': 'PENGURUS'},
          {'id': '2', 'username': 'siti', 'full_name': 'Siti', 'role': 'USTADZAH'},
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = UserService(
      authService: AuthService(),
      apiClient: BackendApiClient(
        httpClient: mock,
        bearerTokenProvider: () async => 'token-123',
      ),
    );

    final users = await service.list();
    expect(users, hasLength(2));
    expect(users.first.role, UserRole.pengurus);
    expect(users.last.role, UserRole.ustadzah);
  });

  test('create calls register endpoint', () async {
    final mock = MockClient((req) async {
      expect(req.method, 'POST');
      expect(req.url.path, '/api/auth/register');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['username'], 'budi');
      expect(body['full_name'], 'Budi S');
      expect(body['password'], 'chelRE@1da');
      expect(body['role'], 'SUPER_ADMIN');
      return http.Response(
        jsonEncode({'response_code': 'RC000', 'status': true, 'data': {}}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final auth = AuthService(httpClient: mock);
    final service = UserService(
      authService: auth,
      apiClient: BackendApiClient(
        httpClient: mock,
        bearerTokenProvider: () async => 'token-123',
      ),
    );
    final ok = await service.create(
      username: 'budi',
      fullName: 'Budi S',
      password: 'chelRE@1da',
      role: UserRole.superAdmin,
    );
    expect(ok, isTrue);
  });

  test('update sends bearer token and payload', () async {
    final mock = MockClient((req) async {
      expect(req.method, 'PUT');
      expect(req.url.path, '/api/users/7');
      expect(req.headers['Authorization'], 'Bearer token-123');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['username'], 'ana');
      expect(body['full_name'], 'Ana');
      expect(body['role'], 'PENGURUS');
      expect(body.containsKey('password'), isFalse);
      return http.Response(jsonEncode({'data': null}), 200);
    });

    final service = UserService(
      authService: AuthService(),
      apiClient: BackendApiClient(
        httpClient: mock,
        bearerTokenProvider: () async => 'token-123',
      ),
    );

    await service.update(
      id: '7',
      username: 'ana',
      fullName: 'Ana',
      role: UserRole.pengurus,
    );
  });

  test('delete returns normally on 204', () async {
    final mock = MockClient((req) async {
      expect(req.method, 'DELETE');
      expect(req.url.path, '/api/users/9');
      return http.Response('', 204);
    });

    final service = UserService(
      authService: AuthService(),
      apiClient: BackendApiClient(
        httpClient: mock,
        bearerTokenProvider: () async => 'token-123',
      ),
    );

    await service.delete('9');
  });
}

