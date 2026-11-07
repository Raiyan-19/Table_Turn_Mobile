import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_turn/app/app.dart';
import 'package:table_turn/features/splash/presentation/splash_screen.dart';
import 'package:table_turn/features/auth/presentation/sign_in_screen.dart';
import 'package:table_turn/features/auth/presentation/otp_screen.dart';
import 'package:table_turn/features/success/presentation/success_screen.dart';

void main() {
  testWidgets('Renders TableTurnApp and verifies initial SplashScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TableTurnApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Table Turn'), findsOneWidget);
    expect(find.text('Good food deserves a great table'), findsOneWidget);
    expect(find.text('A better dining experinece awaits'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Renders SignInScreen with all fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email or phone number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Or continue with'), findsOneWidget);
    expect(find.textContaining('Sign Up'), findsOneWidget);
  });

  testWidgets('Renders OtpScreen with OTP boxes, timer, and dial pad', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OtpScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.textContaining('+8801571284636'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Renders SuccessScreen with welcome back and continue button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SuccessScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('You’ve signed in succesfully'), findsOneWidget);
    expect(find.text('Continue to Home'), findsOneWidget);
  });
}
