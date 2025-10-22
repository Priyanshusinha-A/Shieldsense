import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/system_check_service.dart';
import '../services/email_service.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = User.fromJson(json.decode(userData));
      // Perform system checks to update statuses (run in background)
      _performSystemChecks().then((_) {
        notifyListeners();
      });
      notifyListeners();
    } else {
      // Create default user and perform initial checks
      _user = User(
        id: '1',
        name: 'Demo User',
        username: '',
        email: '',
        employeeId: '',
        password: '',
        cyberHealthScore: 0,
        badges: ['Phish Fighter'],
        phishingDetections: 5,
      );
      // Perform system checks in background
      _performSystemChecks().then((_) async {
        await saveUser();
        notifyListeners();
      });
      notifyListeners();
    }
  }

  Future<void> _performSystemChecks() async {
    if (_user == null) return;

    // Run all system checks concurrently
    final results = await Future.wait([
      SystemCheckService.checkAntivirus(),
      SystemCheckService.checkFirewall(),
      SystemCheckService.checkOsPatches(),
      SystemCheckService.checkBackup(),
      SystemCheckService.checkNetworkSafety(),
    ]);

    // Check password strength based on user's login password
    int passwordStrength = SystemCheckService.checkPasswordStrength(_user!.password);

    // Update user with real statuses
    _user = User(
      id: _user!.id,
      name: _user!.name,
      username: _user!.username,
      email: _user!.email,
      employeeId: _user!.employeeId,
      password: _user!.password,
      cyberHealthScore: _user!.cyberHealthScore,
      badges: _user!.badges,
      phishingDetections: _user!.phishingDetections,
      antivirusActive: results[0] is bool ? results[0] as bool : false,
      firewallActive: results[1] is bool ? results[1] as bool : false,
      passwordStrength: passwordStrength,
      lastPasswordChange: _user!.lastPasswordChange,
      osPatchStatus: results[2] is bool ? results[2] as bool : false,
      backupStatus: results[3] is bool ? results[3] as bool : false,
      cyberAwarenessScore: _user!.cyberAwarenessScore,
      networkSafety: results[4] is Map<String, bool> ? results[4] as Map<String, bool> : {'publicWifiUse': false, 'suspiciousAlerts': false},
    );
  }

  Future<void> saveUser() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      await prefs.setBool('isLoggedIn', _isLoggedIn);
    }
  }

  Future<void> loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      // Check database for user
      final user = await DatabaseService.login(usernameOrEmail, password);

      if (user != null) {
        _user = user;
        _isLoggedIn = true;
        await _performSystemChecks();
        await saveUser();

        // Send login confirmation email only to the registered user's email
        try {
          await EmailService.sendLoginConfirmation(user.email, user.name);
        } catch (emailError) {
          print('Failed to send login confirmation email: $emailError');
          // Don't fail login if email fails
        }

        notifyListeners();
        return true;
      }

      // Invalid credentials - user doesn't exist or wrong password
      return false;
    } catch (e) {
      print('Login error: $e');
      // Re-throw to allow UI to handle connection errors differently
      throw e;
    }
  }

  Future<String?> sendSignupOTP(String email) async {
    try {
      // Check if user already exists with this email
      final existingUser = await DatabaseService.getUserByEmail(email);
      if (existingUser != null) {
        print('Signup failed: Email already exists: $email');
        throw Exception('Email already exists. Please use a different email or login if you already have an account.');
      }

      // Generate OTP
      final otp = _generateOTP();

      // Store OTP temporarily (in a real app, you'd use Redis or similar)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('signup_otp_$email', otp);
      await prefs.setInt('signup_otp_time_$email', DateTime.now().millisecondsSinceEpoch);

      // Send OTP email
      await EmailService.sendSignupOTP(email, otp);

      return otp; // Return for testing purposes
    } catch (e) {
      print('Send signup OTP error: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  Future<Map<String, dynamic>> verifySignupOTP(String email, String otp, Map<String, String> signupData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedOTP = prefs.getString('signup_otp_$email');
      final otpTime = prefs.getInt('signup_otp_time_$email');

      // Check if OTP exists and is not expired (10 minutes)
      if (storedOTP == null || otpTime == null) {
        print('OTP verification failed: OTP not found or expired for email: $email');
        return {'success': false, 'message': 'OTP not found or expired. Please request a new verification code.'};
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - otpTime > 10 * 60 * 1000) { // 10 minutes
        print('OTP verification failed: OTP expired for email: $email');
        // Clean up expired OTP
        await prefs.remove('signup_otp_$email');
        await prefs.remove('signup_otp_time_$email');
        return {'success': false, 'message': 'OTP has expired. Please request a new verification code.'};
      }

      if (storedOTP != otp) {
        print('OTP verification failed: Invalid OTP for email: $email. Stored: $storedOTP, Entered: $otp');
        return {'success': false, 'message': 'Invalid OTP. Please check the code and try again.'};
      }

      // OTP verified, create user account
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: signupData['name']!,
        username: signupData['username']!,
        email: email,
        employeeId: signupData['employeeId']!,
        password: signupData['password']!,
        cyberHealthScore: 0,
        badges: [],
        phishingDetections: 0,
      );

      // Save to database
      final success = await DatabaseService.signup(newUser);

      if (success) {
        print('User account created successfully for: $email');
        // Set as current user
        _user = newUser;
        _isLoggedIn = true;
        await _performSystemChecks();
        await saveUser();

        // Clean up OTP
        await prefs.remove('signup_otp_$email');
        await prefs.remove('signup_otp_time_$email');

        return {'success': true, 'message': ''};
      } else {
        print('Failed to create user account for: $email - user may already exist');
        // Clean up OTP even on failure to prevent reuse
        await prefs.remove('signup_otp_$email');
        await prefs.remove('signup_otp_time_$email');
        return {'success': false, 'message': 'Failed to create account. This email may already be registered.'};
      }
    } catch (e) {
      print('Verify signup OTP error: $e');
      return {'success': false, 'message': 'Verification error occurred. Please try again.'};
    }
  }

  String _generateOTP() {
    // Use Random for better uniqueness instead of millisecondsSinceEpoch
    final random = Random();
    return (random.nextInt(900000) + 100000).toString(); // 6-digit number
  }

  Future<bool> signup(String name, String username, String email, String employeeId, String password) async {
    try {
      // Create new user
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        username: username,
        email: email,
        employeeId: employeeId,
        password: password,
        cyberHealthScore: 0,
        badges: [],
        phishingDetections: 0,
      );

      // Save to database
      final success = await DatabaseService.signup(newUser);

      if (success) {
        // Set as current user
        _user = newUser;
        _isLoggedIn = true;
        await _performSystemChecks();
        await saveUser();
      }

      return success;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }

  void updateScore(int newScore) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: newScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void addBadge(String badge) {
    if (_user != null && !_user!.badges.contains(badge)) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: [..._user!.badges, badge],
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void incrementDetections() {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections + 1,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateAntivirusStatus(bool status) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: status,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateFirewallStatus(bool status) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: status,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updatePasswordStrength(int strength) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: strength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateLastPasswordChange(DateTime? date) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: date,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateOsPatchStatus(bool status) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: status,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateBackupStatus(bool status) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: status,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateCyberAwarenessScore(int score) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: score,
        networkSafety: _user!.networkSafety,
      );
      saveUser();
      notifyListeners();
    }
  }

  void updateNetworkSafety(Map<String, bool> safety) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        username: _user!.username,
        email: _user!.email,
        employeeId: _user!.employeeId,
        password: _user!.password,
        cyberHealthScore: _user!.cyberHealthScore,
        badges: _user!.badges,
        phishingDetections: _user!.phishingDetections,
        antivirusActive: _user!.antivirusActive,
        firewallActive: _user!.firewallActive,
        passwordStrength: _user!.passwordStrength,
        lastPasswordChange: _user!.lastPasswordChange,
        osPatchStatus: _user!.osPatchStatus,
        backupStatus: _user!.backupStatus,
        cyberAwarenessScore: _user!.cyberAwarenessScore,
        networkSafety: safety,
      );
      saveUser();
      notifyListeners();
    }
  }

  Future<void> checkAntivirusStatus() async {
    final status = await SystemCheckService.checkAntivirus();
    updateAntivirusStatus(status);
  }

  Future<void> checkFirewallStatus() async {
    final status = await SystemCheckService.checkFirewall();
    updateFirewallStatus(status);
  }
}
