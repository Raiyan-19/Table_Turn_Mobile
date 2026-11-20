import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service managing persistent local storage of JWT authentication tokens and session state.
class AuthStorageService {
  static const _tokenKey = 'tableturn_jwt_token';
  static const _userKey = 'tableturn_current_user';
  static String? _memToken;
  static UserModel? _memUser;

  static bool _isTestMode() {
    if (kIsWeb) return false;
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Save session token and user profile
  static Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    _memToken = token;
    _memUser = user;
    if (_isTestMode()) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  /// Retrieve stored JWT token
  static Future<String?> getToken() async {
    if (_memToken != null) return _memToken;
    if (_isTestMode()) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve stored user profile
  static Future<UserModel?> getUser() async {
    if (_memUser != null) return _memUser;
    if (_isTestMode()) return null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;
      final Map<String, dynamic> map = jsonDecode(userJson);
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Clear session credentials on logout
  static Future<void> clearSession() async {
    _memToken = null;
    _memUser = null;
    if (_isTestMode()) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}
  }

  /// Check if user has an active stored session
  static Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
