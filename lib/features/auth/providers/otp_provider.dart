import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpState {
  final String otp;
  final String phoneNumber;
  final int remainingSeconds;
  final bool isResendActive;
  final bool isVerifying;
  final String? errorMessage;

  const OtpState({
    this.otp = '',
    this.phoneNumber = '+8801571284636',
    this.remainingSeconds = 45,
    this.isResendActive = false,
    this.isVerifying = false,
    this.errorMessage,
  });

  String get formattedTimer {
    final mins = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  bool get isComplete => otp.length == 6;

  OtpState copyWith({
    String? otp,
    String? phoneNumber,
    int? remainingSeconds,
    bool? isResendActive,
    bool? isVerifying,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isResendActive: isResendActive ?? this.isResendActive,
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OtpNotifier extends StateNotifier<OtpState> {
  Timer? _timer;

  OtpNotifier() : super(const OtpState()) {
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: 45, isResendActive: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 1) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        state = state.copyWith(remainingSeconds: 0, isResendActive: true);
      }
    });
  }

  void addDigit(String digit) {
    if (state.otp.length < 6) {
      state = state.copyWith(
        otp: state.otp + digit,
        clearErrorMessage: true,
      );
    }
  }

  void removeDigit() {
    if (state.otp.isNotEmpty) {
      state = state.copyWith(
        otp: state.otp.substring(0, state.otp.length - 1),
        clearErrorMessage: true,
      );
    }
  }

  void clear() {
    state = state.copyWith(otp: '', clearErrorMessage: true);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void resendCode() {
    if (state.isResendActive) {
      clear();
      _startTimer();
    }
  }

  Future<bool> verify() async {
    if (state.otp.length < 6) {
      state = state.copyWith(errorMessage: 'Please enter all 6 digits of the OTP');
      return false;
    }

    state = state.copyWith(isVerifying: true, clearErrorMessage: true);
    // Simulate brief network verification delay
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isVerifying: false);
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  return OtpNotifier();
});

