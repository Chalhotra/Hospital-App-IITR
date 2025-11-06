import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OtpService {
  static String? _currentOtp;
  static String? _currentEmail;
  static DateTime? _otpGeneratedTime;

  // OTP validity duration (5 minutes)
  static const Duration otpValidityDuration = Duration(minutes: 5);

  /// Generate a 4-digit OTP
  static String _generateOtp() {
    final random = Random();
    final otp = (1000 + random.nextInt(9000)).toString();
    return otp;
  }

  /// Send OTP via email
  static Future<bool> sendOtp(
    String recipientEmail,
    String recipientName,
  ) async {
    try {
      print('📧 [OTP] Generating OTP for $recipientEmail');

      // Generate OTP
      _currentOtp = _generateOtp();
      _currentEmail = recipientEmail;
      _otpGeneratedTime = DateTime.now();

      print('📧 [OTP] Generated OTP: $_currentOtp');

      // Get email credentials from environment
      print('📧 [OTP] Attempting to read SMTP credentials from .env...');
      print('📧 [OTP] dotenv.env keys: ${dotenv.env.keys.toList()}');

      final smtpEmail = dotenv.env['SMTP_EMAIL'];
      final smtpPassword = dotenv.env['SMTP_PASSWORD'];

      print('📧 [OTP] SMTP_EMAIL: ${smtpEmail ?? "NULL"}');
      print(
        '📧 [OTP] SMTP_PASSWORD: ${smtpPassword != null ? "***${smtpPassword.substring(smtpPassword.length - 4)}" : "NULL"}',
      );

      if (smtpEmail == null || smtpPassword == null) {
        print('❌ [OTP] Email credentials not found in .env file');
        throw Exception('Email configuration missing');
      }

      // Configure SMTP
      final smtpServer = gmail(smtpEmail, smtpPassword);

      // Create email message
      final message = Message()
        ..from = Address(smtpEmail, 'IITR Hospital')
        ..recipients.add(recipientEmail)
        ..subject = 'Your OTP for IITR Hospital Login'
        ..html =
            '''
          <!DOCTYPE html>
          <html>
          <head>
            <style>
              body { font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px; }
              .container { background-color: white; padding: 30px; border-radius: 10px; max-width: 500px; margin: 0 auto; }
              .header { text-align: center; color: #D36C6C; font-size: 24px; font-weight: bold; margin-bottom: 20px; }
              .otp-box { background-color: #FFF3F3; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0; }
              .otp { font-size: 36px; font-weight: bold; color: #D36C6C; letter-spacing: 8px; }
              .message { color: #333; line-height: 1.6; margin: 15px 0; }
              .footer { color: #999; font-size: 12px; text-align: center; margin-top: 30px; }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">🏥 IITR Hospital</div>
              <div class="message">
                <p>Hello <strong>$recipientName</strong>,</p>
                <p>Your One-Time Password (OTP) for login is:</p>
              </div>
              <div class="otp-box">
                <div class="otp">$_currentOtp</div>
              </div>
              <div class="message">
                <p>This OTP is valid for <strong>5 minutes</strong>.</p>
                <p>Please do not share this OTP with anyone.</p>
                <p>If you did not request this OTP, please ignore this email.</p>
              </div>
              <div class="footer">
                <p>This is an automated email. Please do not reply.</p>
                <p>&copy; ${DateTime.now().year} IIT Roorkee Institute Hospital</p>
              </div>
            </div>
          </body>
          </html>
        ''';

      // Send email
      print('📧 [OTP] Sending email to $recipientEmail...');
      final sendReport = await send(message, smtpServer);
      print('✅ [OTP] Email sent successfully: ${sendReport.toString()}');

      return true;
    } catch (e) {
      print('❌ [OTP] Failed to send email: $e');
      return false;
    }
  }

  /// Verify OTP
  static bool verifyOtp(String enteredOtp, String email) {
    print('🔍 [OTP] Verifying OTP for $email');
    print('🔍 [OTP] Entered: $enteredOtp, Expected: $_currentOtp');

    // Check if OTP exists
    if (_currentOtp == null ||
        _currentEmail == null ||
        _otpGeneratedTime == null) {
      print('❌ [OTP] No OTP found');
      return false;
    }

    // Check if email matches
    if (_currentEmail != email) {
      print('❌ [OTP] Email mismatch');
      return false;
    }

    // Check if OTP has expired
    final now = DateTime.now();
    final difference = now.difference(_otpGeneratedTime!);
    if (difference > otpValidityDuration) {
      print('❌ [OTP] OTP expired (${difference.inMinutes} minutes old)');
      clearOtp();
      return false;
    }

    // Check if OTP matches
    if (_currentOtp == enteredOtp) {
      print('✅ [OTP] OTP verified successfully');
      clearOtp(); // Clear OTP after successful verification
      return true;
    }

    print('❌ [OTP] OTP does not match');
    return false;
  }

  /// Clear current OTP
  static void clearOtp() {
    print('🗑️ [OTP] Clearing OTP');
    _currentOtp = null;
    _currentEmail = null;
    _otpGeneratedTime = null;
  }

  /// Check if OTP is expired
  static bool isOtpExpired() {
    if (_otpGeneratedTime == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_otpGeneratedTime!);
    return difference > otpValidityDuration;
  }

  /// Get remaining time for OTP validity
  static Duration? getRemainingTime() {
    if (_otpGeneratedTime == null) return null;

    final now = DateTime.now();
    final elapsed = now.difference(_otpGeneratedTime!);
    final remaining = otpValidityDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }
}
