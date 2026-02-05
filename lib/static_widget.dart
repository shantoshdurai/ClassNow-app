import 'package:flutter/material.dart';

// --- EXISTING LARGE WIDGET ---
// --- REDESIGNED PREMIUM WIDGETS ---

// --- FIXED WIDGETS ---

class StaticTimetableWidget extends StatelessWidget {
  final Map<String, dynamic>? currentClass;
  final Map<String, dynamic>? nextClass;
  final String? timeRemaining;
  final double progress;
  final double refreshAngle;

  const StaticTimetableWidget({
    super.key,
    this.currentClass,
    this.nextClass,
    this.timeRemaining,
    this.progress = 0.0,
    this.refreshAngle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 400,
      padding: const EdgeInsets.all(32), // Reduced padding slightly
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white12, width: 2.0),
      ),
      child: Material(color: Colors.transparent, child: _buildContent()),
    );
  }

  Widget _buildContent() {
    final displayData = currentClass ?? nextClass;
    final isCurrent = currentClass != null;

    if (displayData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.weekend_rounded, color: Colors.white24, size: 80),
            const SizedBox(height: 16),
            const Text(
              'No Classes',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Transform.rotate(
            angle: refreshAngle,
            child: Icon(Icons.sync_rounded, color: Colors.white24, size: 40),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : const Color(0xFF0EA5E9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCurrent ? 'NOW' : 'NEXT UP',
                    style: TextStyle(
                      color: isCurrent
                          ? const Color(0xFF34D399)
                          : const Color(0xFF38BDF8),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (isCurrent && timeRemaining != null)
                  Text(
                    timeRemaining!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            Expanded(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    displayData['subject'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44, // Reduced from 52 to separate
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            Row(
              children: [
                Icon(Icons.access_time_filled, color: Colors.white54, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${displayData['startTime']} - ${displayData['endTime']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.room, color: Colors.white54, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Room ${displayData['room']}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (isCurrent) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF34D399),
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// --- CLASSIC ROBOT WIDGET (REVERTED TO BLOCKS) ---
class SmallRobotWidget extends StatelessWidget {
  final Map<String, dynamic>? currentClass;
  final Map<String, dynamic>? nextClass;
  final double refreshAngle;

  const SmallRobotWidget({
    super.key,
    this.currentClass,
    this.nextClass,
    this.refreshAngle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    String status = "FREE";
    String timeOrInfo = "Relax";
    Color themeColor = const Color(0xFF6EE7B7);

    if (currentClass != null) {
      status = "CLASS";
      timeOrInfo = "${currentClass!['endTime']}";
      themeColor = const Color(0xFFFCA5A5);
    } else if (nextClass != null) {
      status = "NEXT";
      timeOrInfo = "${nextClass!['startTime']}";
      themeColor = const Color(0xFF38BDF8);
    }

    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: Colors.white12, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Transform.rotate(
              angle: refreshAngle,
              child: Icon(Icons.sync_rounded, color: Colors.white24, size: 40),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // CLASSIC BLOCK EYES
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 70, // Rectangular box
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Container(
                    width: 90,
                    height: 70, // Rectangular box
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                status,
                style: TextStyle(
                  color: themeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  timeOrInfo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class ErrorWidgetDisplay extends StatelessWidget {
  final bool small;
  const ErrorWidgetDisplay({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: small ? 160 : 320,
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent.withOpacity(0.8),
                size: small ? 24 : 32,
              ),
              const SizedBox(height: 12),
              Text(
                small
                    ? 'TAP TO RELOAD'
                    : 'Widget Sync Error\nTap to Reload App',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: small ? 10 : 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
