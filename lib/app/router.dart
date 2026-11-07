import 'package:go_router/go_router.dart';
import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/success/presentation/success_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
  ],
);

