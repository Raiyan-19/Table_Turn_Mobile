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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  UserRole _selectedRole = UserRole.customer;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    _nameController = TextEditingController(text: authState.name);
    _emailController = TextEditingController(text: authState.emailOrPhone);
    _passwordController = TextEditingController(text: authState.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final notifier = ref.read(authProvider.notifier);
    notifier.setName(_nameController.text.trim());
    notifier.setEmailOrPhone(_emailController.text.trim());
    notifier.setPassword(_passwordController.text);

    if (!notifier.validateSignUp()) {
      return;
    }

    final success = await notifier.register();

    if (mounted) {
      if (success) {
        context.push('/otp');
      } else {
        final errorMsg = ref.read(authProvider).generalError ??
            'Registration failed. Please check your details.';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CustomBackButton(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/sign-in');
                      }
                    },
                  ),
                ),
              ),

              Image.asset(
                AppAssets.logo,
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),

              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join TableTurn to reserve tables across Bangladesh',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Role Selection Segment
              Container(
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = UserRole.customer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.customer
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Customer',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: _selectedRole == UserRole.customer
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedRole == UserRole.customer
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = UserRole.manager),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedRole == UserRole.manager
                                ? AppColors.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Restaurant Staff',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: _selectedRole == UserRole.manager
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedRole == UserRole.manager
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Full Name Field
              CustomTextField(
                controller: _nameController,
                hintText: 'Full Name',
                prefixIconAsset: AppAssets.email,
                errorText: authState.nameError,
                onChanged: (val) => authNotifier.setName(val),
              ),
              const SizedBox(height: 14),

              // Email or Phone field
              CustomTextField(
                controller: _emailController,
                hintText: 'Email or phone number',
                prefixIconAsset: AppAssets.email,
                keyboardType: TextInputType.emailAddress,
                errorText: authState.emailError,
                onChanged: (val) => authNotifier.setEmailOrPhone(val),
              ),
              const SizedBox(height: 14),

              // Password field
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password (min. 6 chars)',
                prefixIconAsset: AppAssets.lock,
                isPassword: true,
                obscureText: !authState.isPasswordVisible,
                suffixIconAsset: AppAssets.eye,
                onToggleVisibility: authNotifier.togglePasswordVisibility,
                errorText: authState.passwordError,
                onChanged: (val) => authNotifier.setPassword(val),
              ),
              const SizedBox(height: 24),

              // Sign Up Button
              PrimaryButton(
                text: 'Create Account',
                height: 56,
                isLoading: authState.isLoading,
                onPressed: _handleSignUp,
              ),
              const SizedBox(height: 20),

              // Back to Sign In
              GestureDetector(
                onTap: () => context.go('/sign-in'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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

