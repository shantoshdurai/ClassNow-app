import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/onboarding_screen.dart';
import 'package:flutter_firebase_test/services/user_service.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isFetching = false;
  bool _isSaving = false;
  String? _fetchError;
  UserData? _fetched;

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    super.dispose();
  }

  Future<void> _fetchFromRoboEye() async {
    final roll = _rollController.text.trim();
    if (roll.isEmpty) {
      setState(() => _fetchError = 'Enter your roll number first');
      return;
    }
    setState(() {
      _isFetching = true;
      _fetchError = null;
      _fetched = null;
    });

    final result = await UserService.fetchFromRoboEye(roll);
    if (!mounted) return;

    if (result != null) {
      setState(() {
        _fetched = result;
        _nameController.text = result.name;
        _isFetching = false;
      });
    } else {
      setState(() {
        _isFetching = false;
        _fetchError = 'Could not fetch automatically — enter your name below.';
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final userData = _fetched ??
        UserData(
          name: _nameController.text.trim(),
          rollNumber: _rollController.text.trim().isEmpty
              ? 'N/A'
              : _rollController.text.trim(),
          branch: 'DSU',
        );

    await UserService.saveUserData(userData.copyWith(
      name: _nameController.text.trim(),
    ));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;
    final accent = isDark ? AppTheme.glassAccent : AppTheme.paperAccent;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
        body: Stack(
          children: [
            if (isDark) const AuroraBackground() else Container(color: AppTheme.paperBg),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step label
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'STEP 1/2',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: mutedColor,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Heading
                      Text(
                        'Tell us\nwho you are',
                        style: AppTextStyles.interTitle.copyWith(
                          fontSize: 34,
                          color: inkColor,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 10),
                      Text(
                        'Your name and roll number are stored only on this device.',
                        style: AppTextStyles.interSmall.copyWith(
                          color: mutedColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 36),

                      // Form card
                      GlassCard(
                        blur: 40,
                        opacity: isDark ? 0.05 : 0.7,
                        padding: const EdgeInsets.all(24),
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Roll number row
                            _fieldLabel('ROLL NUMBER', mutedColor),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _textField(
                                    controller: _rollController,
                                    hint: 'e.g. 1DS22CS001',
                                    isDark: isDark,
                                    inkColor: inkColor,
                                    mutedColor: mutedColor,
                                    capitalization: TextCapitalization.characters,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _lookupButton(accent, isDark),
                              ],
                            ),

                            if (_fetchError != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _fetchError!,
                                style: AppTextStyles.interSmall.copyWith(
                                  color: Colors.orangeAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // Name field
                            _fieldLabel('YOUR NAME', mutedColor),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: AppTextStyles.interSmall.copyWith(
                                color: inkColor,
                                fontSize: 15,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                              decoration: _inputDecoration(
                                hint: 'Your full name',
                                isDark: isDark,
                                mutedColor: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0),

                      const SizedBox(height: 48),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [AppTheme.glassAccent, AppTheme.glassAccent2]
                                  : [AppTheme.paperAccent, AppTheme.paperAccentInk],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.28),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _isSaving ? null : _saveAndContinue,
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'CONTINUE',
                                        style: AppTextStyles.monoLabel.copyWith(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lookupButton(Color accent, bool isDark) {
    return GestureDetector(
      onTap: _isFetching ? null : _fetchFromRoboEye,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: accent.withOpacity(0.12),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: _isFetching
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: accent,
                ),
              )
            : Icon(Icons.manage_search_rounded, color: accent, size: 20),
      ),
    );
  }

  Widget _fieldLabel(String text, Color mutedColor) {
    return Text(
      text,
      style: AppTextStyles.monoLabel.copyWith(
        color: mutedColor,
        letterSpacing: 1.4,
        fontSize: 10,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required Color inkColor,
    required Color mutedColor,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: capitalization,
      style: AppTextStyles.interSmall.copyWith(color: inkColor, fontSize: 15),
      decoration: _inputDecoration(hint: hint, isDark: isDark, mutedColor: mutedColor),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required bool isDark,
    required Color mutedColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.interSmall.copyWith(
        color: mutedColor.withOpacity(0.5),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
