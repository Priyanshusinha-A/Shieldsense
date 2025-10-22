import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // TODO: Replace with your Gmail credentials or use environment variables
  static const String _username = 'shieldsense7@gmail.com';
  static const String _password = 'xtmj iaig nnhv kmxk';

  static Future<void> sendLoginConfirmation(String recipientEmail, String userName) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'ShieldSense')
      ..recipients.add(recipientEmail)
      ..subject = 'Welcome to ShieldSense - Login Confirmation'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #1976D2;">Welcome to ShieldSense!</h2>
          <p>Dear <strong>$userName</strong>,</p>
          <p>Congratulations! You have successfully logged in to your ShieldSense account.</p>
          <p>ShieldSense is your comprehensive cybersecurity awareness platform designed to help you stay safe online.</p>
          <div style="background-color: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 8px;">
            <h3 style="margin-top: 0; color: #333;">What you can do with ShieldSense:</h3>
            <ul style="color: #555;">
              <li>Monitor your cyber health score</li>
              <li>Learn about phishing detection</li>
              <li>Check your system security status</li>
              <li>Access cybersecurity tips and training</li>
            </ul>
          </div>
          <p>If you have any questions or need assistance, please don't hesitate to contact our support team.</p>
          <p>Stay safe online!</p>
          <p>Best regards,<br>The ShieldSense Team</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #888;">
            This is an automated message. Please do not reply to this email.
          </p>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent. $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  static Future<void> sendOTP(String recipientEmail, String otp) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'ShieldSense')
      ..recipients.add(recipientEmail)
      ..subject = 'ShieldSense - Password Reset OTP'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #1976D2;">Password Reset Request</h2>
          <p>We received a request to reset your password for your ShieldSense account.</p>
          <div style="background-color: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 8px; text-align: center;">
            <h3 style="margin-top: 0; color: #333;">Your OTP Code</h3>
            <p style="font-size: 24px; font-weight: bold; color: #1976D2; letter-spacing: 4px;">$otp</p>
            <p style="color: #555;">This code will expire in 10 minutes.</p>
          </div>
          <p>If you didn't request this password reset, please ignore this email. Your password will remain unchanged.</p>
          <p>For security reasons, please do not share this OTP with anyone.</p>
          <p>Best regards,<br>The ShieldSense Team</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #888;">
            This is an automated message. Please do not reply to this email.
          </p>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('OTP sent: $sendReport');
    } on MailerException catch (e) {
      print('OTP not sent. $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  static Future<void> sendSignupOTP(String recipientEmail, String otp) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'ShieldSense')
      ..recipients.add(recipientEmail)
      ..subject = 'ShieldSense - Email Verification OTP'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #1976D2;">Welcome to ShieldSense!</h2>
          <p>Thank you for signing up for ShieldSense. To complete your account verification, please use the OTP code below.</p>
          <div style="background-color: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 8px; text-align: center;">
            <h3 style="margin-top: 0; color: #333;">Your Verification Code</h3>
            <p style="font-size: 24px; font-weight: bold; color: #1976D2; letter-spacing: 4px;">$otp</p>
            <p style="color: #555;">This code will expire in 10 minutes.</p>
          </div>
          <p>ShieldSense is your comprehensive cybersecurity awareness platform designed to help you stay safe online.</p>
          <div style="background-color: #e8f5e8; padding: 15px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #4CAF50;">
            <h4 style="margin-top: 0; color: #2E7D32;">What happens next?</h4>
            <ul style="color: #555; margin: 0; padding-left: 20px;">
              <li>Verify your email with this OTP</li>
              <li>Create your secure account</li>
              <li>Start your cybersecurity journey</li>
            </ul>
          </div>
          <p>If you didn't create this account, please ignore this email.</p>
          <p>For security reasons, please do not share this OTP with anyone.</p>
          <p>Best regards,<br>The ShieldSense Team</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #888;">
            This is an automated message. Please do not reply to this email.
          </p>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Signup OTP sent: $sendReport');
    } on MailerException catch (e) {
      print('Signup OTP not sent. $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  static Future<void> sendPasswordResetConfirmation(String recipientEmail, String userName) async {
    final smtpServer = gmail(_username, _password);

    final message = Message()
      ..from = Address(_username, 'ShieldSense')
      ..recipients.add(recipientEmail)
      ..subject = 'ShieldSense - Password Reset Successful'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #1976D2;">Password Reset Successful</h2>
          <p>Dear <strong>$userName</strong>,</p>
          <p>Your password has been successfully reset for your ShieldSense account.</p>
          <p>You can now log in with your new password.</p>
          <div style="background-color: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 8px;">
            <h3 style="margin-top: 0; color: #333;">Security Reminder:</h3>
            <ul style="color: #555;">
              <li>Use a strong, unique password</li>
              <li>Enable two-factor authentication if available</li>
              <li>Never share your password with others</li>
              <li>Change your password regularly</li>
            </ul>
          </div>
          <p>If you didn't make this change, please contact our support team immediately.</p>
          <p>Stay safe online!</p>
          <p>Best regards,<br>The ShieldSense Team</p>
          <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #888;">
            This is an automated message. Please do not reply to this email.
          </p>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Password reset confirmation sent: $sendReport');
    } on MailerException catch (e) {
      print('Password reset confirmation not sent. $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
