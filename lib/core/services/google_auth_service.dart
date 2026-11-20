import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  final bool isSuccess;
  final String? idToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? googleId;
  final String? errorMessage;
  final bool isCancelled;

  const GoogleAuthResult({
    required this.isSuccess,
    this.idToken,
    this.email,
    this.displayName,
    this.photoUrl,
    this.googleId,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory GoogleAuthResult.success({
    required String? idToken,
    required String email,
    required String? displayName,
    required String? photoUrl,
    required String? googleId,
  }) {
    return GoogleAuthResult(
      isSuccess: true,
      idToken: idToken,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      googleId: googleId,
    );
  }

  factory GoogleAuthResult.cancelled() {
    return const GoogleAuthResult(
      isSuccess: false,
      isCancelled: true,
      errorMessage: 'Google Sign-In was cancelled by the user.',
    );
  }

  factory GoogleAuthResult.failure(String message) {
    return GoogleAuthResult(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Initiate genuine Google Sign-In flow
  static Future<GoogleAuthResult> signIn() async {
    try {
      // Sign out from any cached Google credentials to allow account selection
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return GoogleAuthResult.cancelled();
      }

      final GoogleSignInAuthentication auth = await account.authentication;

      return GoogleAuthResult.success(
        idToken: auth.idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        googleId: account.id,
      );
    } catch (e) {
      debugPrint('[Google Sign-In Exception] $e');
      return GoogleAuthResult.failure(
        'Google authentication failed: ${e.toString()}',
      );
    }
  }

  /// Sign out of Google session
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
