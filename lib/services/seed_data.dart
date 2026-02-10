import 'package:cloud_firestore/cloud_firestore.dart';

// Reverting seed logic to original hierarchy: Department -> Year -> Section
Future<void> seedAIDSData() async {
  final firestore = FirebaseFirestore.instance;

  try {
    print('🌱 Seeding database with corrected data...');

    // 1. Create/Update Department
    // Using a consistent ID for the department
    final deptId = 'school-of-engineering';
    final deptRef = firestore.collection('departments').doc(deptId);

    await deptRef.set({
      'name': 'School of Engineering',
      'code': 'SOE',
    }, SetOptions(merge: true));

    // 2. Create correct Academic Year '2024'
    final yearId = '2024';
    final yearName = '2024';

    final yearRef = deptRef.collection('years').doc(yearId);

    await yearRef.set({
      'name': yearName,
      'type': 'academic_year',
    }, SetOptions(merge: true));

    // 3. Create Specific Sections (AIDA4, A5, etc.)
    // User mentioned: "like aida4 a5" and "10 class"
    final sections = {
      'AIDA4': 'AIDA4',
      'A5': 'A5',
      // Adding a few more placeholders that look like real classes if needed,
      // but sticking to user's explicit examples for now.
    };

    for (var entry in sections.entries) {
      final sectionId = entry.key; // e.g. 'AIDA4'
      final sectionName = entry.value; // e.g. 'AIDA4'

      await yearRef.collection('sections').doc(sectionId).set({
        'name': sectionName,
      }, SetOptions(merge: true));
    }

    print(
      '✅ Seeded School of Engineering -> 2024 -> [${sections.keys.join(", ")}]',
    );
  } catch (e) {
    print('❌ Error seeding database: $e');
    throw e;
  }
}
