import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manajemenasrama/services/auth_service.dart';
import 'package:manajemenasrama/services/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('login posts credentials, stores token, and sets expiry', () async {
    late http.Request captured;
    final mock = MockClient((req) async {
      captured = req;
      expect(req.method, 'POST');
      expect(req.url.path, '/api/auth/login');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['username'], 'ikhsanfadly');
      expect(body['password'], 'password12345');
      return http.Response(
        jsonEncode({
          'response_code': 'RC000',
          'status': false,
          'message_id': 'Sukses',
          'message_en': 'Success',
          'data': {
            'scope': 'SUPER_ADMIN',
            'access_token': 'abc.def.ghi',
            'token_type': 'Bearer',
            'expires_in': 3600,
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final auth = AuthService(httpClient: mock, tokenStorage: TokenStorage());
    final session = await auth.login(
      username: 'ikhsanfadly',
      password: 'password12345',
    );

    expect(captured.method, 'POST');
    expect(session.accessToken, 'abc.def.ghi');
    expect(session.scope, 'SUPER_ADMIN');
    expect(await TokenStorage().read(), isNotNull);
    expect(auth.isLoggedIn, isTrue);
  });

  test('register posts payload and succeeds', () async {
    final mock = MockClient((req) async {
      expect(req.method, 'POST');
      expect(req.url.path, '/api/auth/register');
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      expect(body['username'], 'ikhsanfadly');
      expect(body['password'], 'password12345');
      expect(body['full_name'], 'ikhsan fadly');
      expect(body['role'], 'SUPER_ADMIN');
      return http.Response(
        jsonEncode({
          'response_code': 'RC000',
          'status': false,
          'message_id': 'Sukses',
          'message_en': 'Success',
          'data': null,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final auth = AuthService(httpClient: mock);
    await auth.register(
      username: 'ikhsanfadly',
      password: 'password12345',
      fullName: 'ikhsan fadly',
      role: 'SUPER_ADMIN',
    );
  });

  test('login throws on bad credentials', () async {
    final mock = MockClient((_) async => http.Response(
          jsonEncode({'message_en': 'Invalid username or password'}),
          401,
          headers: {'content-type': 'application/json'},
        ));

    final auth = AuthService(httpClient: mock);
    expect(
      () => auth.login(username: 'bad', password: 'bad'),
      throwsA(isA<AppAuthException>()),
    );
  });
}

