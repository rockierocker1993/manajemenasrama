import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../shared/models/token.dart';

class SessionStorage {
  static const _token_key = 'backend_session';

  Future<void> save(Token session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token_key, jsonEncode(session.toJson()));
  }

  Future<Token?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_token_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Token.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_token_key);
  }
}
