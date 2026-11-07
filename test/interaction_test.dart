import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_turn/app/app.dart';

void main() {
  testWidgets('Full application flow: Splash -> SignIn -> OTP -> Success', (WidgetTester tester) async {
    // Set a realistic mobile device viewport (402 x 874 matching Figma)
    tester.view.physicalSize = const Size(402 * 3, 874 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: TableTurnApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Splash Screen
    expect(find.text('Table Turn'), findsOneWidget);
    expect(find.text('A better dining experinece awaits'), findsOneWidget);

    // Tap to navigate to Sign In
    await tester.tap(find.text('A better dining experinece awaits'));
    await tester.pumpAndSettle();

    // 2. Sign In Screen
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Enter credentials
    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);

    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.pumpAndSettle();

    // Tap Sign In button
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // 3. OTP Screen
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.textContaining('+8801571284636'), findsOneWidget);

    // Dial digits using the custom Dial Pad
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();

    // Verify button
    await tester.ensureVisible(find.text('Verify'));
    await tester.tap(find.text('Verify'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // 4. Success Screen
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue to Home'), findsOneWidget);

    // Tap Continue to Home
    await tester.tap(find.text('Continue to Home'));
    await tester.pumpAndSettle();

    expect(find.text('Enjoy Dining!'), findsOneWidget);
    expect(find.text('Restart Flow'), findsOneWidget);

    await tester.tap(find.text('Restart Flow'));
    await tester.pumpAndSettle();

    // Returns back to Splash Screen
    expect(find.text('A better dining experinece awaits'), findsOneWidget);
  });
}
