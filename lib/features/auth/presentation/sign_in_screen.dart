import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/social_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    _emailController = TextEditingController(text: authState.emailOrPhone);
    _passwordController = TextEditingController(text: authState.password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final notifier = ref.read(authProvider.notifier);
    notifier.setEmailOrPhone(_emailController.text.trim());
    notifier.setPassword(_passwordController.text);

    if (!notifier.validateAndSubmit()) {
      return;
    }

    notifier.setLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));
    final success = await notifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    notifier.setLoading(false);

    if (mounted) {
      if (success) {
        final authState = ref.read(authProvider);
        if (authState.currentRole == UserRole.manager) {
          context.go('/manager-dashboard');
        } else if (authState.currentRole == UserRole.admin) {
          context.go('/admin-dashboard');
        } else if (authState.currentUser != null && !authState.currentUser!.isEmailVerified) {
          context.push('/otp');
        } else {
          context.go('/home');
        }
      } else {
        final errorMsg = ref.read(authProvider).generalError ??
            'Sign in failed. Please verify your credentials.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showForgotPasswordSheet() {
    final emailController = TextEditingController(text: _emailController.text.trim());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWarm,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your registered email address to receive password reset instructions.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                hintText: 'Registered email',
                prefixIconAsset: AppAssets.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Send Reset Link',
                height: 52,
                onPressed: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) return;
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  await ref.read(authProvider.notifier).forgotPassword(email);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'If that email is registered, instructions have been sent.',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _onSocialTap(String provider) async {
    if (provider == 'Google') {
      final success = await ref.read(authProvider.notifier).loginWithGoogle();
      if (mounted) {
        if (success) {
          final authState = ref.read(authProvider);
          if (authState.currentRole == UserRole.manager) {
            context.go('/manager-dashboard');
          } else if (authState.currentRole == UserRole.admin) {
            context.go('/admin-dashboard');
          } else {
            context.go('/home');
          }
        } else {
          final errorMsg = ref.read(authProvider).generalError;
          if (errorMsg != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg, style: GoogleFonts.poppins()),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider sign-in will be available in the next release.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.darkGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Back Arrow
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomBackButton(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/splash');
                      }
                    },
                  ),
                ),
              ),

              // Logo
              Image.asset(
                AppAssets.logo,
                width: 171,
                height: 171,
                fit: BoxFit.contain,
              ),

              // App Title
              Text(
                'Table Turn ',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),

              // Welcome Back Heading
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Sign in to continue your journey for\ngreat food',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email or Phone field
              CustomTextField(
                controller: _emailController,
                hintText: 'Email or phone number',
                prefixIconAsset: AppAssets.email,
                keyboardType: TextInputType.emailAddress,
                errorText: authState.emailError,
                onChanged: (value) => authNotifier.setEmailOrPhone(value),
              ),
              const SizedBox(height: 14),

              // Password field
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIconAsset: AppAssets.lock,
                isPassword: true,
                obscureText: !authState.isPasswordVisible,
                suffixIconAsset: AppAssets.eye,
                onToggleVisibility: authNotifier.togglePasswordVisibility,
                errorText: authState.passwordError,
                onChanged: (value) => authNotifier.setPassword(value),
              ),
              const SizedBox(height: 8),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: _showForgotPasswordSheet,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 6.0,
                    ),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGreen,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sign In Button
              PrimaryButton(
                text: 'Sign In',
                height: 64,
                isLoading: authState.isLoading,
                textStyle: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.5,
                ),
                onPressed: _handleSignIn,
              ),
              const SizedBox(height: 18),

              // Or continue with
              Text(
                'Or continue with',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Social Login Row
              Row(
                children: [
                  Expanded(
                    child: SocialButton(
                      iconAsset: AppAssets.google,
                      onTap: () => _onSocialTap('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SocialButton(
                      iconAsset: AppAssets.apple,
                      onTap: () => _onSocialTap('Apple'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SocialButton(
                      iconAsset: AppAssets.facebook,
                      onTap: () => _onSocialTap('Facebook'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign Up Footer
              GestureDetector(
                onTap: () {
                  context.push('/sign-up');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: "Don’t have an account? "),
                        TextSpan(
                          text: "Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
