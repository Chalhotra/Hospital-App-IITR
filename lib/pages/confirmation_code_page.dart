import 'package:dummy/app_colours.dart';
import 'package:dummy/bloc/auth_bloc.dart';
import 'package:dummy/bloc/auth_event.dart';
import 'package:dummy/bloc/auth_state.dart';
import 'package:dummy/bloc/patient_bloc.dart';
import 'package:dummy/bloc/patient_event.dart';
import 'package:dummy/pages/book_appointment_page/book_appointment_page.dart';
import 'package:dummy/repositories/auth_repository.dart';
import 'package:dummy/services/otp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConfirmationCodePage extends StatefulWidget {
  final String bookletNo;

  const ConfirmationCodePage({super.key, required this.bookletNo});

  @override
  State<ConfirmationCodePage> createState() => _ConfirmationCodePageState();
}

class _ConfirmationCodePageState extends State<ConfirmationCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());
  bool _isVerifying = false;
  String? _email;
  String? _recipientName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nodes.first.requestFocus();
    _fetchPatientInfo();
  }

  Future<void> _fetchPatientInfo() async {
    try {
      final authRepository = context.read<AuthRepository>();
      final patientInfo = await authRepository.getSavedPatientInfo();

      if (patientInfo != null && patientInfo.isNotEmpty) {
        setState(() {
          _email = patientInfo[0].emailID;
          _recipientName = patientInfo[0].fullName;
          _isLoading = false;
        });

        print('📧 [OTP] Fetched email: $_email');
      } else {
        print('❌ [OTP] No patient info found');
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to retrieve patient information'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ [OTP] Error fetching patient info: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _nodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  bool get _isFilled =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 70),

                      const Text(
                        "Enter confirmation code",
                        style: AppTextStyles.title,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "A 4-digit code was sent to\n${_email ?? 'your email'}",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.subtitle,
                      ),

                      const SizedBox(height: 40),

                      // ===== CODE BOXES =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 55,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _nodes[index],
                              cursorColor: AppColours.mainColor, // ✅ added
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 22),
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.inputRadius,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.inputRadius,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppColours.mainColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) => _onChanged(value, index),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      // ===== RESEND CODE =====
                      TextButton(
                        onPressed: () async {
                          if (_email == null || _recipientName == null) return;

                          // Resend OTP
                          final success = await OtpService.sendOtp(
                            _email!,
                            _recipientName!,
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'OTP resent successfully!'
                                      : 'Failed to resend OTP. Please try again.',
                                ),
                                backgroundColor: success
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }

                          // Clear all fields
                          for (var controller in _controllers) {
                            controller.clear();
                          }
                          _nodes.first.requestFocus();
                        },
                        style: TextButton.styleFrom(
                          splashFactory: InkRipple.splashFactory,
                          overlayColor: AppColours.mainColor.withOpacity(0.1),
                        ),
                        child: const Text(
                          "Resend code",
                          style: TextStyle(
                            color: AppColours.linkRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== CONTINUE BTN =====
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFilled
                                ? AppColours.mainColor
                                : AppColours.mainColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.buttonRadius,
                              ),
                            ),
                          ),
                          onPressed: _isFilled && !_isVerifying
                              ? () async {
                                  setState(() => _isVerifying = true);

                                  if (_email == null) {
                                    setState(() => _isVerifying = false);
                                    return;
                                  }

                                  // Get entered OTP
                                  final enteredOtp = _controllers
                                      .map((c) => c.text)
                                      .join();

                                  // Verify OTP
                                  final isValid = OtpService.verifyOtp(
                                    enteredOtp,
                                    _email!,
                                  );

                                  if (isValid) {
                                    // OTP verified successfully - NOW trigger authentication
                                    print(
                                      '✅ [OTP] OTP verified - triggering authentication',
                                    );

                                    if (mounted) {
                                      // Trigger auth check to set authenticated state
                                      context.read<AuthBloc>().add(
                                        AuthCheckRequested(),
                                      );

                                      // Wait a moment for auth state to update
                                      await Future.delayed(
                                        const Duration(milliseconds: 300),
                                      );

                                      // Get authenticated user
                                      final authState = context
                                          .read<AuthBloc>()
                                          .state;
                                      if (authState is AuthAuthenticated) {
                                        // Load patient data
                                        context.read<PatientBloc>().add(
                                          PatientLoadRequested(
                                            authState.user.token,
                                          ),
                                        );

                                        // Navigate to home
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const BookAppointmentPage(),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // OTP verification failed
                                    setState(() => _isVerifying = false);

                                    if (mounted) {
                                      // Clear fields
                                      for (var controller in _controllers) {
                                        controller.clear();
                                      }
                                      _nodes.first.requestFocus();

                                      // Show error
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Invalid or expired OTP. Please try again.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          child: _isVerifying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
