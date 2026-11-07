import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String emailOrPhone;
  final String password;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;

  const AuthState({
    this.emailOrPhone = '',
    this.password = '',
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.emailError,
    this.passwordError,
  });

  AuthState copyWith({
    String? emailOrPhone,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    String? emailError,
    String? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
  }) {
    return AuthState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setEmailOrPhone(String value) {
    state = state.copyWith(
      emailOrPhone: value,
      clearEmailError: true,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      clearPasswordError: true,
    );
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  bool validateAndSubmit() {
    String? emailError;
    String? passwordError;

    final trimmedEmail = state.emailOrPhone.trim();
    if (trimmedEmail.isEmpty) {
      emailError = 'Please enter your email or phone number';
    }

    if (state.password.isEmpty) {
      passwordError = 'Please enter your password';
    } else if (state.password.length < 4) {
      passwordError = 'Password must be at least 4 characters';
    }

    if (emailError != null || passwordError != null) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
      );
      return false;
    }

    state = state.copyWith(
      clearEmailError: true,
      clearPasswordError: true,
    );
    return true;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

