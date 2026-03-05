import json

with open('tool/new_timetable.json', 'r', encoding='utf-8') as f:
    data = f.read()

dart_code = f'''import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const jsonData = r\'\'\'{data}\'\'\';

Future<void> main() async {{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ImportApp());
}}

class ImportApp extends StatelessWidget {{
  const ImportApp({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ImportScreen(),
    );
  }}
}}

class ImportScreen extends StatefulWidget {{
  const ImportScreen({{super.key}});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}}

class _ImportScreenState extends State<ImportScreen> {{
  String _status = "Initializing...";
  bool _isDone = false;
  double _progress = 0;

  @override
  void initState() {{
    super.initState();
    _runImport();
  }}

  Future<void> _runImport() async {{
    try {{
      setState(() => _status = "Decoding data...");
      await Future.delayed(const Duration(milliseconds: 500));
      
      final List<dynamic> classes = jsonDecode(jsonData);
      
      final firestore = FirebaseFirestore.instance;

      setState(() => _status = "Clearing existing schedule data (this may take a while)...");
      await Future.delayed(const Duration(milliseconds: 500));
      
      final deptRef = firestore.collection('departments').doc('school-of-engineering-and-technology');
      final yearRef = deptRef.collection('years').doc('2024');
      final sectionsSnapshot = await yearRef.collection('sections').get();

      // We'll process deletions in batches or one by one with delays to avoid UI freeze
      int totalSectionsToClear = sectionsSnapshot.docs.length;
      int sectionsCleared = 0;

      for (var sectionDoc in sectionsSnapshot.docs) {{
        final scheduleSnapshot = await sectionDoc.reference.collection('schedule').get();
        
        WriteBatch batch = firestore.batch();
        int opCount = 0;
        
        for (var classDoc in scheduleSnapshot.docs) {{
          batch.delete(classDoc.reference);
          opCount++;
          
          if (opCount == 500) {{
             await batch.commit();
             batch = firestore.batch();
             opCount = 0;
          }}
        }}
        if (opCount > 0) {{
           await batch.commit();
        }}
        
        sectionsCleared++;
        setState(() => _status = "Cleared \${{sectionsCleared}} / \${{totalSectionsToClear}} old sections...");
      }}

      setState(() => _status = "Importing new classes...");
      int importedCount = 0;
      final departmentName = 'School of Engineering and Technology';
      final yearName = '2024';

      for (int i = 0; i < classes.length; i++) {{
        var classData = classes[i];
        final sectionName = classData['section'];
        if (sectionName == null) continue;

        await deptRef.set({{'name': departmentName, 'code': 'SET'}}, SetOptions(merge: true));
        await yearRef.set({{'name': yearName}}, SetOptions(merge: true));
        
        final sectionRef = yearRef.collection('sections').doc(sectionName);
        await sectionRef.set({{'name': sectionName}}, SetOptions(merge: true));

        await sectionRef.collection('schedule').add({{
          'subject': classData['subject'],
          'code': classData['code'],
          'mentor': classData['mentor'],
          'room': classData['room'],
          'day': classData['day'],
          'startTime': classData['startTime'],
          'endTime': classData['endTime'],
        }});
        importedCount++;
        
        if (i % 5 == 0) {{ // Update UI less frequently to avoid lag
           setState(() {{
               _progress = (i + 1) / classes.length;
               _status = "Imported \$importedCount/\${{classes.length}}\\n\${{classData['subject']}} (\${{classData['day']}})";
           }});
           await Future.delayed(const Duration(milliseconds: 10)); // Yield to event loop
        }}
      }}

      setState(() {{
        _progress = 1.0;
        _status = "✅ Successfully imported \$importedCount classes!\\nYou can close this app now and run your main app.";
        _isDone = true;
      }});
      print('--- Finished importing \$importedCount classes for all days. ---');
    }} catch (e) {{
      setState(() {{
        _status = "❌ Error:\\n\$e";
        _isDone = true;
      }});
      print(e);
    }}
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      appBar: AppBar(title: const Text('Updating Timetable Data')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isDone) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 20),
              ] else ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
              ],
              Text(
                _status, 
                textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 18)
              ),
            ],
          ),
        ),
      ),
    );
  }}
}}
'''

with open('tool/import_data.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)
print('Dart file written successfully. UI App embedded with batching fixes.')
