import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/app_router.dart';
import 'services/attendance_store.dart';

class ClassCheckInApp extends StatefulWidget {
  const ClassCheckInApp({super.key, required this.store});

  final AttendanceStore store;

  @override
  State<ClassCheckInApp> createState() => _ClassCheckInAppState();
}

class _ClassCheckInAppState extends State<ClassCheckInApp> {
  bool _isLoggedIn = false;
  bool _isLoadingAuthState = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final isLoggedIn = await widget.store.isUserLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoadingAuthState = false;
    });
  }

  void _handleLoginSuccess() {
    setState(() => _isLoggedIn = true);
  }

  void _handleLogout() {
    setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0E7490),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    final router = AppRouter.createRouter(
      store: widget.store,
      isLoggedIn: _isLoggedIn,
      onLoginSuccess: _handleLoginSuccess,
      onLogout: _handleLogout,
    );

    return MaterialApp.router(
      title: 'Class Check-in',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.manropeTextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: const Color(0xFFF4EFE7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF132238),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}