import 'package:flutter_test/flutter_test.dart';
import 'package:manajemenasrama/main.dart';
import 'package:manajemenasrama/services/auth_service.dart';

void main() {
  testWidgets('App launches to login screen', (tester) async {
    await tester.pumpWidget(MyApp(authService: AuthService()));
    await tester.pump();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
