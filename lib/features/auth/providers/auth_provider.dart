import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';

class AuthState {
  final String emailOrPhone;
  final String password;
  final String name;
  final String phone;
  final UserRole selectedRole;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? nameError;
  final UserModel? currentUser;

  const AuthState({
    this.emailOrPhone = '',
    this.password = '',
    this.name = '',
    this.phone = '',
    this.selectedRole = UserRole.customer,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.nameError,
    this.currentUser,
  });

  bool get isAuthenticated => currentUser != null;
  UserRole get currentRole => currentUser?.role ?? UserRole.customer;

  AuthState copyWith({
    String? emailOrPhone,
    String? password,
    String? name,
    String? phone,
    UserRole? selectedRole,
    bool? isPasswordVisible,
    bool? isLoading,
    String? emailError,
    String? passwordError,
    String? nameError,
    UserModel? currentUser,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearNameError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      selectedRole: selectedRole ?? this.selectedRole,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError ? null : (passwordError ?? this.passwordError),
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
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

  void setName(String value) {
    state = state.copyWith(
      name: value,
      clearNameError: true,
    );
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value);
  }

  void setSelectedRole(UserRole role) {
    state = state.copyWith(selectedRole: role);
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

  bool validateSignUp() {
    String? nameError;
    String? emailError;
    String? passwordError;

    if (state.name.trim().isEmpty) {
      nameError = 'Please enter your full name';
    }

    final trimmedEmail = state.emailOrPhone.trim();
    if (trimmedEmail.isEmpty) {
      emailError = 'Please enter email or phone number';
    }

    if (state.password.isEmpty) {
      passwordError = 'Please enter password';
    } else if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (nameError != null || emailError != null || passwordError != null) {
      state = state.copyWith(
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
      );
      return false;
    }

    state = state.copyWith(
      clearNameError: true,
      clearEmailError: true,
      clearPasswordError: true,
    );
    return true;
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void loginAsRole(UserRole role) {
    UserModel user;
    switch (role) {
      case UserRole.manager:
        user = MockData.defaultManager;
        break;
      case UserRole.admin:
        user = MockData.defaultAdmin;
        break;
      case UserRole.customer:
        user = MockData.defaultCustomer;
        break;
    }
    state = state.copyWith(
      currentUser: user,
      selectedRole: role,
      isLoading: false,
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
