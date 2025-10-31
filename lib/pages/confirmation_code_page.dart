import 'package:dummy/app_colours.dart';
import 'package:flutter/material.dart';

class ConfirmationCodePage extends StatefulWidget {
  final String email;
  const ConfirmationCodePage({super.key, required this.email});

  @override
  State<ConfirmationCodePage> createState() => _ConfirmationCodePageState();
}

class _ConfirmationCodePageState extends State<ConfirmationCodePage> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _nodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _nodes.first.requestFocus();
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
        child: SingleChildScrollView(
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
                  "A 4-digit code was sent to\n${widget.email}",
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
                InkWell(
                  splashColor: AppColours.mainColor,
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      "  Resend code  ",
                      style: TextStyle(color: AppColours.linkRed, fontSize: 15),
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
                    onPressed: _isFilled ? () {} : null,
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
