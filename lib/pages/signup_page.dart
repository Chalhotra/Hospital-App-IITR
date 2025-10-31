import 'package:dummy/app_colours.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreed = false;

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
                        onPressed: () {},
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
