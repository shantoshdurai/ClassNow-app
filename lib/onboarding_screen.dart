import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/widget_service.dart';
import 'main.dart';

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
      final items = snapshot.docs.map((doc) {
        final name = (doc.data())['name'] ?? doc.id;
        return DropdownMenuItem(value: doc.id, child: Text(name));
      }).toList();

      if (mounted) {
        setState(() {
          departmentItems = items;
          isInitialLoading = false;
        });
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
      final items = snapshot.docs.map((doc) {
        final name = (doc.data())['name'] ?? doc.id;
        return DropdownMenuItem(value: doc.id, child: Text(name));
      }).toList();
      if (mounted) {
        setState(() {
          yearItems = items;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          areYearsLoading = false;
        });
      }
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
      final items = snapshot.docs.map((doc) {
        final name = (doc.data())['name'] ?? doc.id;
        return DropdownMenuItem(value: doc.id, child: Text(name));
      }).toList();
      if (mounted) {
        setState(() {
          sectionItems = items;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          areSectionsLoading = false;
        });
      }
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
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
                    const SizedBox(height: 20),
                    // Logo/Icon Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 64,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to Class Now',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Let\'s get you set up with your timetable.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Selection Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
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
                                setState(() => selectedDepartmentId = value);
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: theme.primaryColor.withOpacity(0.4),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
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
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            dropdownColor: theme.cardColor,
            isExpanded: true,
            style: theme.textTheme.bodyLarge,
          ),
      ],
    );
  }
}
