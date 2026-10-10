import 'dart:async';

import 'package:flutter/material.dart';

import 'core/backend/backend_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'shared/models/token.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!BackendConfig.isConfigured) {
    // ignore: avoid_print
    print('WARNING: BACKEND_BASE_URL not set. Using ${BackendConfig.baseUrl}.');
  }

  final authService = AuthService();
  await authService.init();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.authService});

  final AuthService authService;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Token?>? _sub;
  Timer? _expiryTimer;
  Token? _session;

  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(authService: widget.authService);
    _session = widget.authService.currentSession;
    _scheduleExpiry(_session);
    _sub = widget.authService.onSessionChanged.listen((session) {
      if (!mounted) return;
      setState(() => _session = session);
      _scheduleExpiry(session);
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  void _scheduleExpiry(Token? session) {
    _expiryTimer?.cancel();
    final ttl = widget.authService.sessionTtlSeconds(session);
    if (ttl == null) return;
    if (ttl <= 0) {
      widget.authService.logout();
      return;
    }

    _expiryTimer = Timer(Duration(seconds: ttl + 1), () async {
      if (widget.authService.isSessionExpired(widget.authService.currentSession)) {
        await widget.authService.logout();
      } else {
        _scheduleExpiry(widget.authService.currentSession);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.authService.isLoggedIn
        ? DashboardPage(
            authService: widget.authService,
            userService: _userService,
          )
        : LoginPage(authService: widget.authService);

    return MaterialApp(
      title: 'Modern Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MobileApp(child: child),
    );
  }
}

class MobileApp extends StatelessWidget {
  const MobileApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
    );
  }
}