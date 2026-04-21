import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'main.dart'; 
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isOtpSent = false;

  final String baseUrl = "http://192.168.100.14:3000/api/auth";

  // --- FEATURE: FORGOT PASSWORD ---
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar("Pehle email likhein!", Colors.orange);
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnackBar("Reset link aapki email par bhej diya gaya hai.", Colors.green);
    } catch (e) {
      _showSnackBar("Email bhejne mein masla hua.", Colors.red);
    }
  }

  // --- LOGIC: LOGIN ---
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        await context.read<UserAuthProvider>().saveSession("firebase_logged_in");
        _showSnackBar("Khush Amdeed!", Colors.green);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login fail ho gaya", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC: SEND OTP ---
  Future<void> _sendOTP() async {
    if (!_emailController.text.contains('@')) {
      _showSnackBar("Sahi email likhein", Colors.redAccent);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text.trim()}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() => _isOtpSent = true);
        _showSnackBar("OTP aapki email par bhej diya gaya!", Colors.green);
      } else {
        _showSnackBar("Server se OTP nahi aya", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Internet check karein ya server off hai", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC: REGISTER ---
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate() || _otpController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "password": _passwordController.text,
          "otp": _otpController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          await context.read<UserAuthProvider>().saveSession("firebase_logged_in");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        }
      } else {
        _showSnackBar("Registration Fail: OTP galat ho sakta hai", Colors.redAccent);
      }
    } catch (e) {
      _showSnackBar("Connection error!", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildMeshBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: _buildGlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 70, color: Color(0xFF004AAD)),
                        const SizedBox(height: 10),
                        Text(_isLoginMode ? "ALAM STORE" : "JOIN US", 
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 30),

                        if (!_isLoginMode) ...[
                          _buildField("Full Name", Icons.person_outline, false, _nameController, enabled: !_isOtpSent),
                          const SizedBox(height: 15),
                        ],
                        
                        _buildField("Email Address", Icons.email_outlined, false, _emailController, enabled: !_isOtpSent),
                        const SizedBox(height: 15),
                        
                        if (!_isLoginMode) ...[
                          _buildField("Phone", Icons.phone_android_outlined, false, _phoneController, enabled: !_isOtpSent),
                          const SizedBox(height: 15),
                        ],

                        _buildField("Password", Icons.lock_outline, true, _passwordController, enabled: !_isOtpSent),
                        
                        if (!_isLoginMode && _isOtpSent) ...[
                          const SizedBox(height: 20),
                          const Text("Enter 6-Digit OTP", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004AAD))),
                          const SizedBox(height: 10),
                          _buildField("OTP Code", Icons.security, false, _otpController, isNumber: true),
                        ],

                        if (_isLoginMode)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _handleForgotPassword,
                              child: const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
                            ),
                          ),
                        
                        const SizedBox(height: 25),
                        _buildMainButton(),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_isLoginMode ? "New here?" : "Already a member?"),
                            TextButton(
                              onPressed: () => setState(() { _isLoginMode = !_isLoginMode; _isOtpSent = false; }), 
                              child: Text(_isLoginMode ? "Create Account" : "Sign In", style: const TextStyle(fontWeight: FontWeight.bold))
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildMainButton() {
    String text = _isLoginMode ? "SIGN IN" : (_isOtpSent ? "VERIFY & REGISTER" : "SEND OTP");
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : (_isLoginMode ? _handleLogin : (_isOtpSent ? _handleSignup : _sendOTP)),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004AAD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildMeshBackground() {
    return Stack(
      children: [
        Positioned(top: -100, right: -50, child: _blob(400, Colors.blue.withOpacity(0.2))),
        Positioned(bottom: -100, left: -50, child: _blob(350, Colors.green.withOpacity(0.15))),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: child,
    );
  }

  Widget _buildField(String hint, IconData icon, bool isPass, TextEditingController controller, {bool enabled = true, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPass && !_isPasswordVisible,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => v!.isEmpty ? "Zaroori hai" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF004AAD)),
        suffixIcon: isPass ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), 
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
      ),
    );
  }
}