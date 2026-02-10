import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/services/seed_data.dart';
import 'package:flutter_firebase_test/widget_service.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'main.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  String? selectedDepartmentId;
  String? selectedYearId;
  String? selectedSectionId;

  List<DropdownMenuItem<String>> departmentItems = [];
  List<DropdownMenuItem<String>> yearItems = [];
  List<DropdownMenuItem<String>> sectionItems = [];

  bool isInitialLoading = true;
  bool areYearsLoading = false;
  bool areSectionsLoading = false;

  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
          ),
        );

    _fetchDepartments();
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('departments')
          .get();

      var matchingDocs = snapshot.docs.where((doc) {
        final name = (doc.data()['name'] ?? doc.id).toString();
        return name.toLowerCase().contains('school of engineering');
      }).toList();

      // Deduplication Logic:
      // If multiple "School of Engineering" entries exist, we want to keep the "good" one.
      // Priority:
      // 1. school-of-engineering (The corrected seed ID)
      // 2. school-of-engineering-and-technology (The old working ID)
      // 3. SET (The old broken ID)
      if (matchingDocs.length > 1) {
        matchingDocs.sort((a, b) {
          int score(String id) {
            if (id == 'school-of-engineering') return 3;
            if (id == 'school-of-engineering-and-technology') return 2;
            return 1;
          }

          return score(b.id).compareTo(score(a.id)); // Higher score first
        });
        // Filter to keep only the best match
        matchingDocs = [matchingDocs.first];
      }

      final items = matchingDocs.map((doc) {
        final name = doc.data()['name'] ?? doc.id;
        return DropdownMenuItem(value: doc.id, child: Text(name));
      }).toList();

      if (mounted) {
        setState(() {
          departmentItems = items;
          isInitialLoading = false;
        });

        if (departmentItems.isNotEmpty) {
          if (departmentItems.length == 1) {
            final id = departmentItems.first.value;
            if (selectedDepartmentId != id) {
              // Schedule the next fetch after the build phase
              Future.microtask(() {
                if (mounted) {
                  setState(() => selectedDepartmentId = id);
                  _fetchYears(id!);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isInitialLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching departments: $e')),
        );
      }
    }
  }

  Future<void> _fetchYears(String departmentId) async {
    setState(() {
      areYearsLoading = true;
      selectedYearId = null;
      selectedSectionId = null;
      yearItems = [];
      sectionItems = [];
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .collection('years')
          .get();

      final items = snapshot.docs
          .where((doc) {
            final name = (doc.data()['name'] ?? doc.id).toString();
            return name.contains('2024');
          })
          .map((doc) {
            final name = doc.data()['name'] ?? doc.id;
            return DropdownMenuItem(value: doc.id, child: Text(name));
          })
          .toList();

      if (mounted) {
        setState(() {
          yearItems = items;
          areYearsLoading = false;
        });

        if (yearItems.isNotEmpty) {
          if (yearItems.length == 1) {
            final id = yearItems.first.value;
            if (selectedYearId != id) {
              Future.microtask(() {
                if (mounted) {
                  setState(() => selectedYearId = id);
                  _fetchSections(departmentId, id!);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => areYearsLoading = false);
    }
  }

  Future<void> _fetchSections(String departmentId, String yearId) async {
    setState(() {
      areSectionsLoading = true;
      selectedSectionId = null;
      sectionItems = [];
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('departments')
          .doc(departmentId)
          .collection('years')
          .doc(yearId)
          .collection('sections')
          .get();

      final items = snapshot.docs
          .where((doc) {
            final name = (doc.data()['name'] ?? doc.id).toString();
            final lowerName = name.toLowerCase();
            // Filter out "Section A", "Section B" etc.
            // We want "AIDA4", "A5" to pass.
            // Invalid: Starts with 'section ' OR is just a single letter 'a','b','c'
            final isGeneric =
                lowerName.startsWith('section ') ||
                ['a', 'b', 'c', 'd'].contains(lowerName);
            return !isGeneric;
          })
          .map((doc) {
            final name = doc.data()['name'] ?? doc.id;
            return DropdownMenuItem(value: doc.id, child: Text(name));
          })
          .toList();

      if (mounted) {
        setState(() {
          sectionItems = items;
          areSectionsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => areSectionsLoading = false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (selectedDepartmentId != null &&
        selectedYearId != null &&
        selectedSectionId != null) {
      await Provider.of<UserSelectionProvider>(
        context,
        listen: false,
      ).saveSelection(
        departmentId: selectedDepartmentId!,
        yearId: selectedYearId!,
        sectionId: selectedSectionId!,
      );

      // Trigger immediate widget update so it's not invisible
      await WidgetService.updateFromForeground();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const DashboardPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please make a selection for all fields.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Animated Background Blobs
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentPurple.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
          ],

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo/Icon Section
                      // Single Prominent DSU Logo with Shine Effect
                      // Single Prominent DSU Logo with Shine Effect
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Glow
                            Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.primaryColor.withOpacity(0.05),
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .scale(
                                  duration: 3.seconds,
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.2, 1.2),
                                  curve: Curves.easeInOut,
                                )
                                .fadeOut(duration: 3.seconds),

                            // Main Logo with Shimmer
                            Container(
                                  width: 140,
                                  height: 140,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset('assets/dsu_logo.png'),
                                  ),
                                )
                                .animate()
                                .scale(
                                  duration: 800.ms,
                                  curve: Curves.easeOutBack,
                                )
                                .shimmer(
                                  duration: 2.seconds,
                                  color: Colors.white.withOpacity(0.4),
                                  angle: 45,
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .shimmer(
                                  delay: 3.seconds,
                                  duration: 2.seconds,
                                  color: Colors.white.withOpacity(0.4),
                                  angle: 45,
                                ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Welcome to Class Now',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.interTitle.copyWith(
                          fontSize: 28,
                          color: theme.colorScheme.onSurface,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Let\'s get you set up with your timetable.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.hintColor.withOpacity(0.8),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Selection Card
                      GlassCard(
                        blur: 20,
                        opacity: 0.1,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDropdownSection(
                              title: 'Department',
                              icon: Icons.business_rounded,
                              value: selectedDepartmentId,
                              items: departmentItems,
                              isLoading: isInitialLoading,
                              hint: 'Choose your department',
                              onChanged: (value) {
                                if (value != null) {
                                  _fetchYears(value);
                                  setState(() {
                                    selectedDepartmentId = value;
                                    selectedYearId = null;
                                    selectedSectionId = null;
                                  });
                                }
                              },
                            ),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: selectedDepartmentId != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: _buildDropdownSection(
                                        title: 'Academic Year',
                                        icon: Icons.calendar_today_rounded,
                                        value: selectedYearId,
                                        items: yearItems,
                                        isLoading: areYearsLoading,
                                        hint: 'Select your year',
                                        onChanged: (value) {
                                          if (value != null) {
                                            _fetchSections(
                                              selectedDepartmentId!,
                                              value,
                                            );
                                            setState(
                                              () => selectedYearId = value,
                                            );
                                          }
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: selectedYearId != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: _buildDropdownSection(
                                        title: 'Section',
                                        icon: Icons.group_rounded,
                                        value: selectedSectionId,
                                        items: sectionItems,
                                        isLoading: areSectionsLoading,
                                        hint: 'Find your section',
                                        onChanged: (value) {
                                          setState(
                                            () => selectedSectionId = value,
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              (selectedDepartmentId == null ||
                                  selectedYearId == null ||
                                  selectedSectionId == null)
                              ? null
                              : _saveAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: theme.primaryColor
                                .withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: theme.primaryColor.withOpacity(0.5),
                          ),
                          child: const Text("Continue", style: TextStyle()),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () async {
                          try {
                            await seedAIDSData();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Database restored! Please restart the app or reload sections.',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _fetchDepartments();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error restoring: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Restore Database (Fix)',
                          style: TextStyle(
                            color: theme.hintColor.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required bool isLoading,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                height: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.primaryColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: theme.cardColor,
            isExpanded: true,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.0),
          ),
      ],
    );
  }
}
