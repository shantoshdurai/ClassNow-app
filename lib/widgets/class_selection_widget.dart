import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/app_theme.dart';
import 'package:flutter_firebase_test/widgets/glass_widgets.dart';

class ClassSelectionWidget extends StatefulWidget {
  final VoidCallback? onSelectionComplete;

  const ClassSelectionWidget({super.key, this.onSelectionComplete});

  @override
  State<ClassSelectionWidget> createState() => _ClassSelectionWidgetState();
}

class _ClassSelectionWidgetState extends State<ClassSelectionWidget> {
  String? _selectedDeptId;
  String? _selectedDeptName;
  String? _selectedYearId;
  String? _selectedYearName;
  String? _selectedSectionId;
  String? _selectedSectionName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingSelection();
  }

  Future<void> _loadExistingSelection() async {
    final provider = Provider.of<UserSelectionProvider>(context, listen: false);
    if (!provider.hasSelection) return;

    setState(() => _isLoading = true);

    try {
      final deptId = provider.departmentId!;
      final yearId = provider.yearId!;
      final sectionId = provider.sectionId!;

      // Fetch names concurrently
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('departments').doc(deptId).get(),
        FirebaseFirestore.instance
            .doc('departments/$deptId/years/$yearId')
            .get(),
        FirebaseFirestore.instance
            .doc('departments/$deptId/years/$yearId/sections/$sectionId')
            .get(),
      ]);

      if (mounted) {
        setState(() {
          _selectedDeptId = deptId;
          _selectedDeptName = results[0].data()?['name'] as String?;
          _selectedYearId = yearId;
          _selectedYearName = results[1].data()?['name'] as String?;
          _selectedSectionId = sectionId;
          _selectedSectionName = results[2].data()?['name'] as String?;
        });
      }
    } catch (e) {
      print('Error loading existing selection: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo with subtle glow in Glass mode
            Center(
              child: Container(
                decoration: isDark ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.glassAccent.withOpacity(0.15),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ) : null,
                child: Image.asset('assets/dsu_logo.png', height: 100),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Welcome to Class Now',
              style: (isDark ? AppTextStyles.interTitle.copyWith(color: AppTheme.glassInk) : AppTextStyles.interTitle.copyWith(color: AppTheme.paperInk)).copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s get you set up with your timetable.',
              style: AppTextStyles.interSmall.copyWith(
                color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Selection Section
            GlassCard(
              padding: const EdgeInsets.all(24),
              opacity: isDark ? 0.05 : 0.4,
              blur: isDark ? 40 : 10,
              borderRadius: BorderRadius.circular(32),
              child: Column(
                children: [
                  // Department Selection
                  _buildSelectionField(
                    label: 'DEPARTMENT',
                    value: _selectedDeptName,
                    placeholder: 'Select Department',
                    icon: Icons.business_rounded,
                    onTap: () => _showSelectionSheet(
                      title: 'Select Department',
                      collection: 'departments',
                      orderBy: 'name',
                      currentValue: _selectedDeptId,
                      onSelected: (id, name) {
                        setState(() {
                          _selectedDeptId = id;
                          _selectedDeptName = name;
                          _selectedYearId = null;
                          _selectedYearName = null;
                          _selectedSectionId = null;
                          _selectedSectionName = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Year Selection
                  _buildSelectionField(
                    label: 'YEAR',
                    value: _selectedYearName,
                    placeholder: 'Select Year',
                    icon: Icons.calendar_today_rounded,
                    enabled: _selectedDeptId != null,
                    onTap: () => _showSelectionSheet(
                      title: 'Select Year',
                      collection: 'departments/$_selectedDeptId/years',
                      currentValue: _selectedYearId,
                      onSelected: (id, name) {
                        setState(() {
                          _selectedYearId = id;
                          _selectedYearName = name;
                          _selectedSectionId = null;
                          _selectedSectionName = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Selection
                  _buildSelectionField(
                    label: 'SECTION',
                    value: _selectedSectionName,
                    placeholder: 'Select Section',
                    icon: Icons.class_rounded,
                    enabled: _selectedYearId != null,
                    onTap: () => _showSelectionSheet(
                      title: 'Select Section',
                      collection:
                          'departments/$_selectedDeptId/years/$_selectedYearId/sections',
                      currentValue: _selectedSectionId,
                      onSelected: (id, name) {
                        setState(() {
                          _selectedSectionId = id;
                          _selectedSectionName = name;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // Save Button
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _selectedSectionId != null ? 1.0 : 0.0,
              child: _selectedSectionId != null ? Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
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
                          'CONTINUE TO DASHBOARD',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ) : const SizedBox(height: 64),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String? value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label,
              style: AppTextStyles.monoLabel.copyWith(
                color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : AppTheme.paperBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: value != null
                      ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.5)
                      : (isDark ? Colors.white.withOpacity(0.05) : AppTheme.paperLine),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon, 
                    color: value != null 
                        ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent)
                        : (isDark ? AppTheme.glassMuted : AppTheme.paperMuted), 
                    size: 20
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value ?? placeholder,
                      style: TextStyle(
                        color: value != null
                            ? (isDark ? AppTheme.glassInk : AppTheme.paperInk)
                            : (isDark ? AppTheme.glassMuted : AppTheme.paperMuted),
                        fontSize: 16,
                        fontWeight: value != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSelectionSheet({
    required String title,
    required String collection,
    required Function(String id, String name) onSelected,
    String? orderBy,
    String? currentValue,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.glassBg2 : AppTheme.paperBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: isDark ? Border(top: BorderSide(color: AppTheme.glassBorder, width: 1)) : null,
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: (isDark ? AppTextStyles.interTitle.copyWith(color: AppTheme.glassInk) : AppTextStyles.interTitle.copyWith(color: AppTheme.paperInk)).copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted,
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: orderBy != null
                    ? FirebaseFirestore.instance
                          .collection(collection)
                          .orderBy(orderBy)
                          .snapshots()
                    : FirebaseFirestore.instance
                          .collection(collection)
                          .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading options',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                      ),
                    );
                  }

                  final docs = collection == 'departments'
                      ? snapshot.data!.docs
                            .where(
                              (doc) =>
                                  doc.id ==
                                  'school-of-engineering-and-technology',
                            )
                            .toList()
                      : snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No options found',
                        style: TextStyle(color: isDark ? AppTheme.glassMuted : AppTheme.paperMuted),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? doc.id;
                      final isSelected = doc.id == currentValue;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            onSelected(doc.id, name);
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent).withOpacity(0.1)
                                  : (isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : AppTheme.paperSurface),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent)
                                    : (isDark ? AppTheme.glassBorder : AppTheme.paperLine),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? AppTheme.glassAccent : AppTheme.paperAccent)
                                          : (isDark ? AppTheme.glassInk : AppTheme.paperInk),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: isDark ? AppTheme.glassAccent : AppTheme.paperAccent,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSelection() async {
    if (_selectedDeptId == null ||
        _selectedYearId == null ||
        _selectedSectionId == null)
      return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userSelection = Provider.of<UserSelectionProvider>(
        context,
        listen: false,
      );
      await userSelection.saveSelection(
        departmentId: _selectedDeptId!,
        yearId: _selectedYearId!,
        sectionId: _selectedSectionId!,
      );

      if (mounted && widget.onSelectionComplete != null) {
        widget.onSelectionComplete!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving selection: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
