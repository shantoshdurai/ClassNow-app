import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/app_theme.dart';

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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo
            Image.asset('assets/dsu_logo.png', height: 120),
            const SizedBox(height: 32),
            Text(
              'Welcome to Class Now',
              style: AppTextStyles.interTitle.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Let\'s get you set up with your timetable.',
              style: AppTextStyles.interSmall.copyWith(
                color: theme.hintColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Department Selection
            _buildSelectionCard(
              label: 'Department',
              value: _selectedDeptName, // Display Name
              placeholder: 'Select Department',
              icon: Icons.business_rounded,
              onTap: () => _showSelectionSheet(
                title: 'Select Department',
                collection: 'departments',
                orderBy: 'name', // Ensure ordered by name if field exists
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
            const SizedBox(height: 16),

            // Year Selection
            if (_selectedDeptId != null)
              _buildSelectionCard(
                label: 'Year',
                value: _selectedYearName, // Display Name
                placeholder: 'Select Year',
                icon: Icons.calendar_today_rounded,
                onTap: () => _showSelectionSheet(
                  title: 'Select Year',
                  collection: 'departments/$_selectedDeptId/years',
                  orderBy: 'name',
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
            if (_selectedDeptId != null) const SizedBox(height: 16),

            // Section Selection
            if (_selectedYearId != null)
              _buildSelectionCard(
                label: 'Section',
                value: _selectedSectionName, // Display Name
                placeholder: 'Select Section',
                icon: Icons.class_rounded,
                onTap: () => _showSelectionSheet(
                  title: 'Select Section',
                  collection:
                      'departments/$_selectedDeptId/years/$_selectedYearId/sections',
                  orderBy: 'name',
                  currentValue: _selectedSectionId,
                  onSelected: (id, name) {
                    setState(() {
                      _selectedSectionId = id;
                      _selectedSectionName = name;
                    });
                  },
                ),
              ),
            if (_selectedYearId != null) const SizedBox(height: 32),

            // Save Button
            if (_selectedSectionId != null)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: theme.primaryColor.withOpacity(0.5),
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
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String label,
    required String? value,
    required String placeholder,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: theme.hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: value != null
                    ? theme.primaryColor.withOpacity(0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ??
                        placeholder, // Note: You might need to look up the NAME of the ID if possible, but for now ID/Name
                    style: TextStyle(
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : theme.hintColor,
                      fontSize: 15,
                      fontWeight: value != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.hintColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
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
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: theme.hintColor,
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
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No options found',
                        style: TextStyle(color: theme.hintColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor.withOpacity(0.1)
                                  : (isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.grey.withOpacity(0.05)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : Colors.transparent,
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
                                          ? theme.primaryColor
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.primaryColor,
                                    size: 20,
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
