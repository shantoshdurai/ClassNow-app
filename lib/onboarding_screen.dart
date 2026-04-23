import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/widget_service.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/dashboard_page.dart';
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
  String? selectedDepartmentName;
  String? selectedYearId;
  String? selectedYearName;
  String? selectedSectionId;
  String? selectedSectionName;

  List<_PickerOption> departmentItems = [];
  List<_PickerOption> yearItems = [];
  List<_PickerOption> sectionItems = [];

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

      final items = snapshot.docs
          .map((doc) => _PickerOption(doc.id, (doc.data()['name'] ?? doc.id) as String))
          .toList();

      if (mounted) {
        setState(() {
          departmentItems = items;
          isInitialLoading = false;
        });

        if (departmentItems.isNotEmpty) {
          if (departmentItems.length == 1) {
            final only = departmentItems.first;
            if (selectedDepartmentId != only.id) {
              Future.microtask(() {
                if (mounted) {
                  setState(() {
                    selectedDepartmentId = only.id;
                    selectedDepartmentName = only.name;
                  });
                  _fetchYears(only.id);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isInitialLoading = false);
        Future.delayed(Duration.zero, () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching departments: $e')),
            );
          }
        });
      }
    }
  }

  Future<void> _fetchYears(String departmentId) async {
    setState(() {
      areYearsLoading = true;
      selectedYearId = null;
      selectedYearName = null;
      selectedSectionId = null;
      selectedSectionName = null;
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
          .map((doc) => _PickerOption(doc.id, (doc.data()['name'] ?? doc.id) as String))
          .toList();

      if (mounted) {
        setState(() {
          yearItems = items;
          areYearsLoading = false;
        });

        if (yearItems.isNotEmpty) {
          if (yearItems.length == 1) {
            final only = yearItems.first;
            if (selectedYearId != only.id) {
              Future.microtask(() {
                if (mounted) {
                  setState(() {
                    selectedYearId = only.id;
                    selectedYearName = only.name;
                  });
                  _fetchSections(departmentId, only.id);
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
      selectedSectionName = null;
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
          .map((doc) => _PickerOption(doc.id, (doc.data()['name'] ?? doc.id) as String))
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppTheme.glassBg : AppTheme.paperBg,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top indicator
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'STEP 2/2',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: mutedColor,
                            letterSpacing: 2.0,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logo Section
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.05),
                              ),
                            ).animate(onPlay: (c) => c.repeat()).scale(
                              duration: 3.seconds,
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                              curve: Curves.easeInOut,
                            ).fadeOut(),

                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.2),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset('assets/dsu_logo.png'),
                              ),
                            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'Sync Your Class',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.interTitle.copyWith(
                          fontSize: 32,
                          color: inkColor,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select your details to fetch your personalized timetable automatically.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.interSmall.copyWith(
                          color: mutedColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Selection Card
                      GlassCard(
                        blur: 40,
                        opacity: isDark ? 0.05 : 0.7,
                        padding: const EdgeInsets.all(24),
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPickerField(
                              title: 'DEPARTMENT',
                              icon: Icons.account_balance_rounded,
                              valueName: selectedDepartmentName,
                              valueId: selectedDepartmentId,
                              items: departmentItems,
                              isLoading: isInitialLoading,
                              hint: 'Select Department',
                              isDark: isDark,
                              inkColor: inkColor,
                              mutedColor: mutedColor,
                              sheetTitle: 'Select your department',
                              chipMode: false,
                              onSelected: (opt) {
                                setState(() {
                                  selectedDepartmentId = opt.id;
                                  selectedDepartmentName = opt.name;
                                  selectedYearId = null;
                                  selectedYearName = null;
                                  selectedSectionId = null;
                                  selectedSectionName = null;
                                });
                                _fetchYears(opt.id);
                              },
                            ),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: selectedDepartmentId != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: _buildPickerField(
                                        title: 'ACADEMIC YEAR',
                                        icon: Icons.calendar_today_rounded,
                                        valueName: selectedYearName,
                                        valueId: selectedYearId,
                                        items: yearItems,
                                        isLoading: areYearsLoading,
                                        hint: 'Select Year',
                                        isDark: isDark,
                                        inkColor: inkColor,
                                        mutedColor: mutedColor,
                                        sheetTitle: 'Pick your academic year',
                                        chipMode: true,
                                        onSelected: (opt) {
                                          setState(() {
                                            selectedYearId = opt.id;
                                            selectedYearName = opt.name;
                                            selectedSectionId = null;
                                            selectedSectionName = null;
                                          });
                                          _fetchSections(selectedDepartmentId!, opt.id);
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
                                      child: _buildPickerField(
                                        title: 'SECTION',
                                        icon: Icons.grid_view_rounded,
                                        valueName: selectedSectionName,
                                        valueId: selectedSectionId,
                                        items: sectionItems,
                                        isLoading: areSectionsLoading,
                                        hint: 'Select Section',
                                        isDark: isDark,
                                        inkColor: inkColor,
                                        mutedColor: mutedColor,
                                        sheetTitle: 'Choose your section',
                                        chipMode: true,
                                        onSelected: (opt) {
                                          setState(() {
                                            selectedSectionId = opt.id;
                                            selectedSectionName = opt.name;
                                          });
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
                              color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: (selectedDepartmentId == null ||
                                    selectedYearId == null ||
                                    selectedSectionId == null)
                                ? null
                                : _saveAndContinue,
                            child: Center(
                              child: Opacity(
                                opacity: (selectedDepartmentId == null ||
                                        selectedYearId == null ||
                                        selectedSectionId == null) ? 0.5 : 1.0,
                                child: Text(
                                  "START JOURNEY",
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
                      ),
                      const SizedBox(height: 32),
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

  Widget _buildPickerField({
    required String title,
    required IconData icon,
    required String? valueName,
    required String? valueId,
    required List<_PickerOption> items,
    required bool isLoading,
    required String hint,
    required bool isDark,
    required Color inkColor,
    required Color mutedColor,
    required String sheetTitle,
    required bool chipMode,
    required ValueChanged<_PickerOption> onSelected,
  }) {
    final accent = isDark ? AppTheme.glassAccent : AppTheme.paperAccent;
    final hasValue = valueId != null;
    final disabled = !isLoading && items.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: mutedColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.monoLabel.copyWith(
                color: mutedColor,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                minHeight: 2,
              ),
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: disabled
                  ? null
                  : () => _openPickerSheet(
                        title: sheetTitle,
                        icon: icon,
                        items: items,
                        currentId: valueId,
                        chipMode: chipMode,
                        onSelected: onSelected,
                      ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isDark
                      ? Colors.white.withOpacity(hasValue ? 0.06 : 0.04)
                      : Colors.black.withOpacity(hasValue ? 0.04 : 0.025),
                  border: Border.all(
                    color: hasValue
                        ? accent.withOpacity(0.45)
                        : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        valueName ?? hint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.interSmall.copyWith(
                          color: hasValue ? inkColor : mutedColor.withOpacity(0.7),
                          fontSize: 15,
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasValue
                            ? accent.withOpacity(0.18)
                            : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: hasValue ? accent : mutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _openPickerSheet({
    required String title,
    required IconData icon,
    required List<_PickerOption> items,
    required String? currentId,
    required bool chipMode,
    required ValueChanged<_PickerOption> onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.glassAccent : AppTheme.paperAccent;
    final inkColor = isDark ? AppTheme.glassInk : AppTheme.paperInk;
    final mutedColor = isDark ? AppTheme.glassMuted : AppTheme.paperMuted;

    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? items
                : items.where((o) => o.name.toLowerCase().contains(query)).toList();

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.glassBg2.withOpacity(0.92)
                        : AppTheme.paperBg.withOpacity(0.96),
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppTheme.glassBorder2 : AppTheme.paperLine,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: mutedColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, size: 18, color: accent),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTextStyles.interSmall.copyWith(
                                    color: inkColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (items.length > 6) ...[
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black.withOpacity(0.05),
                                ),
                              ),
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (_) => setSheetState(() {}),
                                style: AppTextStyles.interSmall.copyWith(
                                  color: inkColor,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 18,
                                    color: mutedColor,
                                  ),
                                  hintText: 'Search...',
                                  hintStyle: AppTextStyles.interSmall.copyWith(
                                    color: mutedColor.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Flexible(
                          child: filtered.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Text(
                                    'No matches',
                                    style: AppTextStyles.interSmall.copyWith(color: mutedColor),
                                  ),
                                )
                              : (chipMode
                                  ? _buildChipGrid(filtered, currentId, accent, inkColor, mutedColor, isDark, onSelected, sheetContext)
                                  : _buildList(filtered, currentId, accent, inkColor, mutedColor, isDark, onSelected, sheetContext)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildList(
    List<_PickerOption> items,
    String? currentId,
    Color accent,
    Color inkColor,
    Color mutedColor,
    bool isDark,
    ValueChanged<_PickerOption> onSelected,
    BuildContext sheetContext,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final opt = items[i];
        final selected = opt.id == currentId;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              onSelected(opt);
              Navigator.pop(sheetContext);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withOpacity(0.12)
                    : (isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.black.withOpacity(0.03)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? accent.withOpacity(0.5)
                      : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      opt.name,
                      style: AppTextStyles.interSmall.copyWith(
                        color: selected ? accent : inkColor,
                        fontSize: 15,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, size: 20, color: accent),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChipGrid(
    List<_PickerOption> items,
    String? currentId,
    Color accent,
    Color inkColor,
    Color mutedColor,
    bool isDark,
    ValueChanged<_PickerOption> onSelected,
    BuildContext sheetContext,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
      physics: const BouncingScrollPhysics(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((opt) {
          final selected = opt.id == currentId;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                onSelected(opt);
                Navigator.pop(sheetContext);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withOpacity(0.12)
                      : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.03)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? accent.withOpacity(0.5)
                        : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  opt.name,
                  style: AppTextStyles.interSmall.copyWith(
                    color: selected ? accent : inkColor,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PickerOption {
  final String id;
  final String name;
  const _PickerOption(this.id, this.name);
}
