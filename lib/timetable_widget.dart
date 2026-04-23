import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_test/providers/user_selection_provider.dart';
import 'package:flutter_firebase_test/widgets/skeleton_loader.dart';
import 'package:flutter_firebase_test/widget_service.dart';

class TimetableWidget extends StatefulWidget {
  const TimetableWidget({super.key});

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _refreshController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    // Initialize rotation animation controller
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Update every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  DateTime _parseTime(String timeStr) {
    try {
      final now = DateTime.now();
      final cleanTime = timeStr.trim().toUpperCase();

      if (cleanTime.contains('AM') || cleanTime.contains('PM')) {
        final parsed = DateFormat('hh:mm a').parse(cleanTime);
        return DateTime(
          now.year,
          now.month,
          now.day,
          parsed.hour,
          parsed.minute,
        );
      }

      final parts = cleanTime.split(':');
      var hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Smart Conversion: In a school context, hours like 1-7 are likely PM
      if (hour >= 1 && hour <= 7) {
        hour += 12;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, 0, 0);
    }
  }

  Map<String, dynamic>? _getCurrentClass(List<DocumentSnapshot> docs) {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now);

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['day'] != currentDay) continue;

      final start = _parseTime(data['startTime'] as String);
      final end = _parseTime(data['endTime'] as String);

      if (now.isAfter(start) && now.isBefore(end)) {
        return {'data': data, 'start': start, 'end': end, 'isCurrent': true};
      }
    }
    return null;
  }

  Map<String, dynamic>? _getNextClass(List<DocumentSnapshot> docs) {
    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now);

    DocumentSnapshot? nextClass;
    DateTime? nextStart;

    // Sort logic to prioritize earliest future class
    // We iterate through all, so sorting isn't strictly necessary for finding min,
    // but safer to find closest. Actually the loop below finds min.

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['day'] != currentDay) continue;

      final start = _parseTime(data['startTime'] as String);

      if (start.isAfter(now)) {
        if (nextStart == null || start.isBefore(nextStart)) {
          nextStart = start;
          nextClass = doc;
        }
      }
    }

    if (nextClass != null) {
      final data = nextClass.data() as Map<String, dynamic>;
      return {
        'data': data,
        'start': nextStart,
        'end': _parseTime(data['endTime'] as String),
        'isCurrent': false,
      };
    }
    return null;
  }

  String _getTimeRemaining(DateTime end) {
    final now = DateTime.now();
    final diff = end.difference(now);

    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m left';
    } else {
      return '${diff.inSeconds}s left';
    }
  }

  double _getProgress(DateTime start, DateTime end) {
    final now = DateTime.now();
    final total = end.difference(start).inMinutes;
    if (total <= 0) return 1.0;
    final elapsed = now.difference(start).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<UserSelectionProvider>(
      builder: (context, userSelection, child) {
        if (!userSelection.hasSelection) {
          return const SizedBox.shrink(); // Or a placeholder
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('departments')
              .doc(userSelection.departmentId)
              .collection('years')
              .doc(userSelection.yearId)
              .collection('sections')
              .doc(userSelection.sectionId)
              .collection('schedule')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const TimetableCardSkeleton();
            }
            if (snapshot.hasError) {
              return Card(
                elevation: theme.cardTheme.elevation ?? 1,
                color: theme.cardColor,
                shape:
                    theme.cardTheme.shape ??
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(child: Text("Error: ${snapshot.error}")),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            final current = _getCurrentClass(docs);
            final next = _getNextClass(docs);

            if (current == null && next == null) {
              return Card(
                elevation: theme.cardTheme.elevation ?? 1,
                color: theme.cardColor,
                shape:
                    theme.cardTheme.shape ??
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        color: theme.hintColor,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No More Classes Today',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final display = current ?? next;
            final data = display!['data'] as Map<String, dynamic>;
            final isCurrent = display['isCurrent'] as bool;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              elevation: theme.cardTheme.elevation ?? 1,
              color: theme.cardColor,
              shape:
                  theme.cardTheme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCurrent ? 'NOW' : 'NEXT UP',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isCurrent
                                ? theme.colorScheme.secondary
                                : theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: _isRefreshing
                              ? null
                              : () async {
                                  if (_isRefreshing) return;

                                  setState(() {
                                    _isRefreshing = true;
                                  });

                                  // Start the smooth rotation animation
                                  _refreshController.reset();
                                  await _refreshController.forward();

                                  // Trigger a manual update of the home screen widget
                                  WidgetService.updateFromForeground();
                                  if (mounted) {
                                    setState(() {
                                      _isRefreshing = false;
                                    });
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: RotationTransition(
                              turns: _refreshController,
                              child: Icon(
                                Icons.sync_rounded,
                                size: 22,
                                color: _isRefreshing
                                    ? theme.primaryColor
                                    : theme.hintColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['subject'] ?? 'Unknown',
                      style: theme.textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${data['startTime']} - ${data['endTime']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Room ${data['room']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _getProgress(display['start'], display['end']),
                          backgroundColor: theme.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.secondary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTimeRemaining(display['end']),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text(
                        'Starts in ${_getTimeRemaining(display['start']).replaceAll(' left', '')}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (isCurrent && next != null) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: theme.dividerColor),
                      const SizedBox(height: 12),
                      Text(
                        'UP NEXT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (next['data'] as Map<String, dynamic>)['subject'] ??
                            'Unknown',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
