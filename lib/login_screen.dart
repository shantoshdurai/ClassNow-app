import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: GlassCard(
            color: Colors.red.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            child: Text(
              e.message ?? 'Login failed',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? AppTheme.glassBg      : AppTheme.paperBg;
    final inkColor  = isDark ? AppTheme.glassInk  : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;
    final accent = isDark ? AppTheme.glassAccent  : AppTheme.paperAccent;
    final border = isDark ? AppTheme.glassBorder2 : AppTheme.paperLine;
    final surface = isDark ? AppTheme.glassBg2    : AppTheme.paperSurface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: bg,
        body: Stack(
          children: [
            // ── Background ─────────────────────────────────────────────────
            const AuroraBackground(),

            // ── Content ────────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : surface,
                              border: Border.all(color: border, width: 1),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: inkColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'MENTOR LOGIN',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: mutedColor,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 38),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),

                          // ── Hero heading ──────────────────────────────────
                          Text(
                            'Welcome\nBack.',
                            style: AppTextStyles.interTitle.copyWith(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: inkColor,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sign in with your mentor credentials to manage schedules.',
                            style: AppTextStyles.interSmall.copyWith(
                              color: mutedColor,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ── Form card ─────────────────────────────────────
                          GlassCard(
                            blur: 40,
                            opacity: isDark ? 0.05 : 0.7,
                            padding: const EdgeInsets.all(24),
                            borderRadius: BorderRadius.circular(28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email field
                                _fieldLabel('EMAIL ADDRESS', mutedColor),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _emailController,
                                  hint: 'mentor@university.edu',
                                  icon: Icons.email_outlined,
                                  isDark: isDark,
                                  inkColor: inkColor,
                                  mutedColor: mutedColor,
                                  accent: accent,
                                  border: border,
                                  surface: surface,
                                ),

                                const SizedBox(height: 20),

                                // Password field
                                _fieldLabel('PASSWORD', mutedColor),
                                const SizedBox(height: 8),
                                _inputField(
                                  controller: _passwordController,
                                  hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  isDark: isDark,
                                  inkColor: inkColor,
                                  mutedColor: mutedColor,
                                  accent: accent,
                                  border: border,
                                  surface: surface,
                                  obscure: _obscurePassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(
                                      () => _obscurePassword = !_obscurePassword,
                                    ),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: mutedColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Login button
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [AppTheme.glassAccent, AppTheme.glassAccent2]
                                          : [AppTheme.paperAccent, AppTheme.paperAccentInk],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: _isLoading ? null : _login,
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Text(
                                                'SIGN IN',
                                                style: AppTextStyles.monoLabel.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),


                          const SizedBox(height: 24),

                          // Footer note
                          Center(
                            child: Text(
                              'Student access doesn\'t require login.',
                              style: AppTextStyles.interSmall.copyWith(
                                color: mutedColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text, Color mutedColor) {
    return Text(
      text,
      style: AppTextStyles.monoLabel.copyWith(color: mutedColor, letterSpacing: 1.4),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color inkColor,
    required Color mutedColor,
    required Color accent,
    required Color border,
    required Color surface,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTextStyles.interSmall.copyWith(color: inkColor, fontSize: 15),
        keyboardType: hint.contains('@')
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.interSmall.copyWith(color: mutedColor.withOpacity(0.5), fontSize: 14),
          prefixIcon: Icon(icon, size: 18, color: mutedColor),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffixIcon,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        ),
      ),
    );
  }

}
