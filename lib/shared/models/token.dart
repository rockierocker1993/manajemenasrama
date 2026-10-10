class Token {
  Token({
    required this.username,
    required this.accessToken,
    required this.tokenType,
    required this.scope,
    required this.expiresIn,
    required this.expiresAt,
  });

  final String username;
  final String accessToken;
  final String tokenType;
  final String scope;
  final int expiresIn;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory Token.fromLoginResponse({
    required String username,
    required Map<String, dynamic> json,
  }) {
    final data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 0;
    return Token(
      username: username,
      accessToken: (data['access_token'] ?? '').toString(),
      tokenType: (data['token_type'] ?? 'Bearer').toString(),
      scope: (data['scope'] ?? '').toString(),
      expiresIn: expiresIn,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'access_token': accessToken,
    'token_type': tokenType,
    'scope': scope,
    'expires_in': expiresIn,
    'expires_at': expiresAt.millisecondsSinceEpoch,
  };

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    username: (json['username'] ?? '').toString(),
    accessToken: (json['access_token'] ?? '').toString(),
    tokenType: (json['token_type'] ?? 'Bearer').toString(),
    scope: (json['scope'] ?? '').toString(),
    expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
    expiresAt: DateTime.fromMillisecondsSinceEpoch(
      (json['expires_at'] as num?)?.toInt() ?? 0,
    ),
  );
}
