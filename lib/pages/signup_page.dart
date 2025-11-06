import 'package:dummy/app_colours.dart';
import 'package:dummy/bloc/auth_bloc.dart';
import 'package:dummy/bloc/auth_event.dart';
import 'package:dummy/models/register_request.dart';
import 'package:dummy/pages/confirmation_code_page.dart';
import 'package:dummy/repositories/auth_repository.dart';
import 'package:dummy/services/otp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreed = false;
  bool _isLoading = false;

  final TextEditingController _bookletController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _bookletController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== TOP SECTION =====
              Container(
                width: double.infinity,
                height: 140,
                color: AppColours.backgroundLight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/iitr_logo.png', height: 80),
                    const SizedBox(height: 10),
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Times New Roman',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ===== FORM SECTION =====
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Sign Up", style: AppTextStyles.title),
                    const SizedBox(height: 25),

                    // ==== Name field ====
                    TextField(
                      controller: _bookletController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Booklet No.',
                        hintText: 'Enter your Booklet No.',
                        hintStyle: const TextStyle(color: AppColours.textGrey),
                        labelStyle: const TextStyle(color: AppColours.textGrey),
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
                    ),

                    const SizedBox(height: 20),

                    // ==== Password field ====
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Create your password',
                        hintStyle: const TextStyle(color: AppColours.textGrey),
                        labelStyle: const TextStyle(color: AppColours.textGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
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
                    ),

                    const SizedBox(height: 20),

                    // ==== Confirm Password field ====
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter password',
                        hintStyle: const TextStyle(color: AppColours.textGrey),
                        labelStyle: const TextStyle(color: AppColours.textGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
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
                    ),

                    const SizedBox(height: 15),

                    // ==== Terms checkbox ====
                    Row(
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: AppColours.mainColor,
                          onChanged: (value) {
                            setState(() {
                              _agreed = value!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            "I agree to the Terms & Conditions and Privacy Policy.",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ==== Sign Up button ====
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColours.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.buttonRadius,
                            ),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                // Validate inputs
                                final booklet = _bookletController.text.trim();
                                final password = _passwordController.text
                                    .trim();
                                final confirmPassword =
                                    _confirmPasswordController.text.trim();

                                if (booklet.isEmpty ||
                                    password.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill in all fields',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Passwords do not match'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (!_agreed) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please agree to Terms & Conditions',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);

                                try {
                                  // Create registration request
                                  final registerRequest = RegisterRequest(
                                    username: booklet,
                                    password: password,
                                    roles: 'PAT',
                                  );

                                  // Call register API
                                  final authRepository = context
                                      .read<AuthRepository>();
                                  final response = await authRepository
                                      .register(registerRequest);

                                  // Save user token temporarily (DON'T authorize yet)
                                  await authRepository.saveUser(response);

                                  // Fetch patient info to get email (without triggering auth state)
                                  print(
                                    '📧 [REGISTER] Fetching patient info for OTP...',
                                  );

                                  // Manually fetch patient info using the token
                                  final patientInfoFetched =
                                      await authRepository
                                          .fetchAndSavePatientInfo(
                                            response.token,
                                          );

                                  if (!patientInfoFetched) {
                                    // Failed to fetch patient info - clear token and logout
                                    print(
                                      '❌ [REGISTER] Failed to fetch patient info',
                                    );
                                    await authRepository.clearUser();
                                    setState(() => _isLoading = false);

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Registration failed: Unable to fetch patient information',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  final patientInfo = await authRepository
                                      .getSavedPatientInfo();

                                  if (patientInfo != null &&
                                      patientInfo.isNotEmpty) {
                                    final email = patientInfo[0].emailID;
                                    final name = patientInfo[0].fullName;

                                    print(
                                      '📧 [REGISTER] Sending OTP to $email',
                                    );

                                    // Send OTP
                                    final otpSent = await OtpService.sendOtp(
                                      email,
                                      name,
                                    );

                                    setState(() => _isLoading = false);

                                    if (otpSent && mounted) {
                                      // OTP sent successfully - Navigate to OTP verification page
                                      // NOTE: User is NOT authenticated yet - will be after OTP verification
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConfirmationCodePage(
                                                bookletNo: booklet,
                                              ),
                                        ),
                                      );
                                    } else {
                                      // OTP send failed - clear token and logout
                                      print(
                                        '❌ [REGISTER] Failed to send OTP - logging out',
                                      );
                                      await authRepository.clearUser();

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to send OTP. Registration cancelled.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    }
                                  } else {
                                    // No patient info - clear token and logout
                                    print(
                                      '❌ [REGISTER] No patient info found - logging out',
                                    );
                                    await authRepository.clearUser();
                                    setState(() => _isLoading = false);

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Registration failed: No patient information found',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  }
                                } catch (e) {
                                  setState(() => _isLoading = false);
                                  print('❌ [REGISTER] Error: $e');

                                  // Clear any saved data on error
                                  try {
                                    await context
                                        .read<AuthRepository>()
                                        .clearUser();
                                  } catch (_) {}

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Registration failed: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ==== Already member ====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppColours.linkRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Container(height: 1, color: Colors.grey[300]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
