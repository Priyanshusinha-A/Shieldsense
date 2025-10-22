import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/email_service.dart';
import '../providers/user_provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _userEmail;
  Map<String, String>? _signupData;
  bool _isSignup = false;
  int _resendAttempts = 0;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _userEmail = args['email'];
        _signupData = args['signupData'];
        _isSignup = args['isSignup'] ?? false;
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOTPChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (_isSignup && _signupData != null) {
        // Handle signup verification
        final result = await userProvider.verifySignupOTP(_userEmail!, otp, _signupData!);
        if (result['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully! Please login.')),
            );
            // Navigate to login with success flag
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false, arguments: {'showSignupSuccess': true});
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
          }
        }
      } else {
        // Handle password reset verification (existing logic)
        // For now, navigate to new password screen
        if (mounted) {
          Navigator.of(context).pushNamed('/new-password', arguments: {
            'email': _userEmail,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: ${e.toString()}')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendOTP() async {
    if (_resendAttempts >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum resend attempts reached. Please try again later.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (_isSignup) {
        // Resend signup OTP
        final newOTP = await userProvider.sendSignupOTP(_userEmail!);
        if (newOTP != null) {
          _resendAttempts++;
          setState(() => _canResend = false);
          Future.delayed(const Duration(minutes: 1), () {
            if (mounted) setState(() => _canResend = true);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP resent successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to resend OTP. Please try again.')),
          );
        }
      } else {
        // Resend password reset OTP
        final newOTP = _generateOTP();
        _resendAttempts++;
        await EmailService.sendOTP(_userEmail!, newOTP);

        setState(() => _canResend = false);
        Future.delayed(const Duration(minutes: 1), () {
          if (mounted) setState(() => _canResend = true);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending OTP: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  String _generateOTP() {
    // Use Random for better uniqueness instead of millisecondsSinceEpoch
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // 6-digit number
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit OTP sent to your email address.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      onChanged: (value) => _onOTPChanged(index, value),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: (_isLoading || !_canResend) ? null : _resendOTP,
                child: Text(
                  _canResend ? 'Resend OTP' : 'Resend OTP (wait 1 min)',
                  style: TextStyle(
                    color: _canResend ? null : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
