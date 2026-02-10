import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> diagnoseFirestore() async {
  final firestore = FirebaseFirestore.instance;
  print('--- FIRESTORE DIAGNOSIS ---');

  final depts = await firestore.collection('departments').get();
  for (var dept in depts.docs) {
    print('Department: ${dept.id} (${dept.data()['name']})');

    final years = await dept.reference.collection('years').get();
    for (var year in years.docs) {
      print('  Year: ${year.id} (${year.data()['name']})');

      final sections = await year.reference.collection('sections').get();
      for (var section in sections.docs) {
        print('    Section: ${section.id} (${section.data()['name']})');

        // Peek at schedule count
        final schedule = await section.reference.collection('schedule').get();
        print('      Schedule count: ${schedule.size}');
        if (schedule.size > 0) {
          final first = schedule.docs.first.data();
          print('      Sample Class: ${first['subject']} in ${first['room']}');
        }
      }
    }
  }
}
