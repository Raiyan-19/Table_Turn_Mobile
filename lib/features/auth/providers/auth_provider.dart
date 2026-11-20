import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/google_auth_service.dart';

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
  final String? generalError;
  final UserModel? currentUser;
  final String? token;
  final bool isInitialized;

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
    this.generalError,
    this.currentUser,
    this.token,
    this.isInitialized = false,
  });

  bool get isAuthenticated => currentUser != null && token != null;
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
    String? generalError,
    UserModel? currentUser,
    String? token,
    bool? isInitialized,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearNameError = false,
    bool clearGeneralError = false,
    bool clearUser = false,
    bool clearToken = false,
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
      generalError: clearGeneralError ? null : (generalError ?? this.generalError),
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      token: clearToken ? null : (token ?? this.token),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    restoreSession();
  }

  void setEmailOrPhone(String value) {
    state = state.copyWith(
      emailOrPhone: value,
      clearEmailError: true,
      clearGeneralError: true,
    );
  }

  void setPassword(String value) {
    state = state.copyWith(
      password: value,
      clearPasswordError: true,
      clearGeneralError: true,
    );
  }

  void setName(String value) {
    state = state.copyWith(
      name: value,
      clearNameError: true,
      clearGeneralError: true,
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

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void clearErrors() {
    state = state.copyWith(
      clearEmailError: true,
      clearPasswordError: true,
      clearNameError: true,
      clearGeneralError: true,
    );
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
      clearGeneralError: true,
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
    } else if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      emailError = 'Please enter a valid email address';
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
      clearGeneralError: true,
    );
    return true;
  }

  /// Restore persistent session from device storage on launch
  Future<void> restoreSession() async {
    try {
      final token = await AuthStorageService.getToken();
      final user = await AuthStorageService.getUser();

      if (token != null && user != null) {
        state = state.copyWith(
          token: token,
          currentUser: user,
          selectedRole: user.role,
          isInitialized: true,
        );

        // Verify token validity with backend in background
        try {
          final res = await ApiService.get('/auth/me', requireAuth: true);
          if (res['success'] == true && res['user'] != null) {
            final freshUser = UserModel.fromJson(res['user']);
            await AuthStorageService.saveSession(token: token, user: freshUser);
            state = state.copyWith(
              currentUser: freshUser,
              selectedRole: freshUser.role,
            );
          }
        } catch (apiErr) {
          if (apiErr is ApiException && apiErr.statusCode == 401) {
            // Token expired or invalidated
            await logout();
          }
        }
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (_) {
      state = state.copyWith(isInitialized: true);
    }
  }

  /// Real Backend Email & Password Login
  Future<bool> login({String? email, String? password}) async {
    final emailToUse = (email ?? state.emailOrPhone).trim();
    final passwordToUse = password ?? state.password;

    if (emailToUse.isEmpty || passwordToUse.isEmpty) {
      state = state.copyWith(generalError: 'Please provide both email and password.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearGeneralError: true);

    try {
      final response = await ApiService.post('/auth/login', body: {
        'email': emailToUse,
        'password': passwordToUse,
      });

      if (response['success'] == true) {
        final token = response['token'] as String;
        final user = UserModel.fromJson(response['user']);

        await AuthStorageService.saveSession(token: token, user: user);

        state = state.copyWith(
          isLoading: false,
          token: token,
          currentUser: user,
          selectedRole: user.role,
          clearGeneralError: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          generalError: response['message'] ?? 'Sign in failed.',
        );
        return false;
      }
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Real Backend Registration
  Future<bool> register() async {
    if (!validateSignUp()) return false;

    state = state.copyWith(isLoading: true, clearGeneralError: true);

    try {
      final response = await ApiService.post('/auth/register', body: {
        'name': state.name.trim(),
        'email': state.emailOrPhone.trim(),
        'phone': state.phone.trim(),
        'password': state.password,
      });

      if (response['success'] == true) {
        final token = response['token'] as String;
        final user = UserModel.fromJson(response['user']);

        await AuthStorageService.saveSession(token: token, user: user);

        state = state.copyWith(
          isLoading: false,
          token: token,
          currentUser: user,
          selectedRole: user.role,
          clearGeneralError: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          generalError: response['message'] ?? 'Registration failed.',
        );
        return false;
      }
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Genuine Google OAuth Authentication
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearGeneralError: true);

    try {
      final googleResult = await GoogleAuthService.signIn();

      if (googleResult.isCancelled) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      if (!googleResult.isSuccess || googleResult.email == null) {
        state = state.copyWith(
          isLoading: false,
          generalError: googleResult.errorMessage ?? 'Google authentication failed.',
        );
        return false;
      }

      // Exchange with TableTurn backend
      final response = await ApiService.post('/auth/google', body: {
        'idToken': googleResult.idToken,
        'email': googleResult.email,
        'name': googleResult.displayName,
        'avatarUrl': googleResult.photoUrl,
        'googleId': googleResult.googleId,
      });

      if (response['success'] == true) {
        final token = response['token'] as String;
        final user = UserModel.fromJson(response['user']);

        await AuthStorageService.saveSession(token: token, user: user);

        state = state.copyWith(
          isLoading: false,
          token: token,
          currentUser: user,
          selectedRole: user.role,
          clearGeneralError: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          generalError: response['message'] ?? 'Failed to complete Google Sign-In.',
        );
        return false;
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, generalError: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: 'Google Sign-In failed. Please try again.',
      );
      return false;
    }
  }

  /// Send OTP to user's registered email
  Future<bool> sendOtp([String? email]) async {
    final emailToUse = (email ?? state.currentUser?.email ?? state.emailOrPhone).trim();
    if (emailToUse.isEmpty) return false;

    try {
      final res = await ApiService.post('/auth/send-otp', body: {'email': emailToUse});
      return res['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Verify OTP code via backend
  Future<bool> verifyOtp(String otp, [String? email]) async {
    final emailToUse = (email ?? state.currentUser?.email ?? state.emailOrPhone).trim();
    if (emailToUse.isEmpty || otp.length < 6) return false;

    state = state.copyWith(isLoading: true, clearGeneralError: true);

    try {
      final res = await ApiService.post('/auth/verify-otp', body: {
        'email': emailToUse,
        'otp': otp.trim(),
      });

      if (res['success'] == true) {
        final token = res['token'] as String;
        final user = UserModel.fromJson(res['user']);

        await AuthStorageService.saveSession(token: token, user: user);

        state = state.copyWith(
          isLoading: false,
          token: token,
          currentUser: user,
          selectedRole: user.role,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          generalError: res['message'] ?? 'Invalid OTP code.',
        );
        return false;
      }
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, generalError: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, generalError: 'Verification failed.');
      return false;
    }
  }

  /// Request Password Reset Link / Code
  Future<bool> forgotPassword(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return false;

    try {
      final res = await ApiService.post('/auth/forgot-password', body: {'email': trimmed});
      return res['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Reset Password with Code
  Future<bool> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    try {
      final res = await ApiService.post('/auth/reset-password', body: {
        'email': email.trim(),
        'resetCode': resetCode.trim(),
        'newPassword': newPassword,
      });
      return res['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Demo / Test Mock Login (Preserved for backwards compatibility with tests)
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
      token: 'mock_jwt_token_${user.id}',
      isLoading: false,
    );
  }

  /// Secure Sign Out
  Future<void> logout() async {
    await AuthStorageService.clearSession();
    await GoogleAuthService.signOut();
    state = const AuthState(isInitialized: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
