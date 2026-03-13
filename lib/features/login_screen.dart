import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/route_names.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLoginSuccess});

  final VoidCallback onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _studentIdController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _studentIdController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedPassword = prefs.getString('user_password');

      if (_emailController.text == savedEmail &&
          _passwordController.text == savedPassword) {
        // Login successful
        widget.onLoginSuccess();
        if (mounted) {
          context.go(RouteNames.home.path);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _studentIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', _emailController.text);
      await prefs.setString('user_password', _passwordController.text);
      await prefs.setString('student_id', _studentIdController.text);
      
      // Save student ID to AttendanceStore
      await prefs.setString('attendance_student_id', _studentIdController.text);

      widget.onLoginSuccess();
      if (mounted) {
        context.go(RouteNames.home.path);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4EFE7), Color(0xFFE1F0EA), Color(0xFFFBE2BA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp
                        ? 'Sign up to get started'
                        : 'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Student ID Field (Sign Up Only)
                  if (_isSignUp)
                    Column(
                      children: [
                        TextField(
                          controller: _studentIdController,
                          decoration: InputDecoration(
                            labelText: 'Student ID',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Login/Sign Up Button
                  FilledButton(
                    onPressed: _isLoading
                        ? null
                        : (_isSignUp ? _handleSignUp : _handleLogin),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0E7490),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Toggle Sign Up / Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp
                            ? 'Already have an account?'
                            : "Don't have an account?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => setState(() {
                                  _isSignUp = !_isSignUp;
                                  _studentIdController.clear();
                                }),
                        child: Text(
                          _isSignUp ? 'Login' : 'Sign Up',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E7490),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
