import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/otp_provider.dart';
import '../widgets/dial_pad.dart';
import '../widgets/otp_box.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  void _handleVerify() async {
    final otpNotifier = ref.read(otpProvider.notifier);
    final isValid = await otpNotifier.verify();

    if (isValid && mounted) {
      context.push('/success');
    }
  }

  void _showEditPhoneDialog() {
    final otpState = ref.read(otpProvider);
    final controller = TextEditingController(text: otpState.phoneNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundWarm,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Edit Phone Number',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: 'Enter phone number',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  ref.read(otpProvider.notifier).setPhoneNumber(text);
                }
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                              context.go('/sign-in');
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

                    // Enter OTP Title
                    Text(
                      'Enter OTP',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.21,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone and Edit link
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text.rich(
                        TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: "We’ve sent a 6-digit code to\n${otpState.phoneNumber} ",
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: GestureDetector(
                                onTap: _showEditPhoneDialog,
                                child: Text(
                                  'Edit',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6-digit OTP boxes
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        final gap = availableWidth < 340 ? 6.0 : 10.0;
                        final boxSize = ((availableWidth - (gap * 5)) / 6).clamp(38.0, 48.0);

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final digit = index < otpState.otp.length
                                ? otpState.otp[index]
                                : '';
                            final isFocused = index == otpState.otp.length;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == 5 ? 0 : gap,
                              ),
                              child: OtpBox(
                                digit: digit,
                                isFocused: isFocused,
                                width: boxSize,
                                height: boxSize,
                              ),
                            );
                          }),
                        );
                      },
                    ),

                    // Error text if validation fails
                    if (otpState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          otpState.errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Resend code timer / button
                    if (otpState.isResendActive)
                      TextButton(
                        onPressed: () => otpNotifier.resendCode(),
                        child: Text(
                          'Resend code now',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Resend code in ${otpState.formattedTimer}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          height: 1.21,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Verify Button
                    PrimaryButton(
                      text: 'Verify',
                      height: 48,
                      borderRadius: 10,
                      isLoading: otpState.isVerifying,
                      textStyle: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      onPressed: _handleVerify,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Custom In-App Dial Pad at bottom
            DialPad(
              onNumberTap: (digit) => otpNotifier.addDigit(digit),
              onDeleteTap: () => otpNotifier.removeDigit(),
            ),
          ],
        ),
      ),
    );
  }
}
