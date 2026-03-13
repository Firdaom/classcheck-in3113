import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/attendance_session.dart';
import '../services/attendance_store.dart';
import 'session_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});

  final AttendanceStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _selectedClassId;
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _selectedClassId = _courses.first.id;
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('attendance_student_id') ?? 'STU-240031';
    setState(() {
      _studentId = studentId;
    });
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 18) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  CourseOption get _selectedCourse =>
      _courses.firstWhere((course) => course.id == _selectedClassId);

  AttendanceSession? get _todaySession => widget.store.sessionForDate(
        classId: _selectedClassId,
        date: DateTime.now(),
      );

  Future<void> _openFlow(SessionFormMode mode) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SessionFormScreen(
          store: widget.store,
          classId: _selectedCourse.id,
          className: _selectedCourse.name,
          mode: mode,
          sessionDate: DateTime.now(),
        ),
      ),
    );

    if (!mounted || saved != true) {
      return;
    }

    final message = mode == SessionFormMode.checkIn
        ? 'Check-in saved locally.'
        : 'Class completion saved locally.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final todaySession = _todaySession;
        final todayDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF4EFE7), Color(0xFFE1F0EA), Color(0xFFFBE2BA)],
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── User Header ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A73E8).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          _studentId.isNotEmpty
                              ? 'ID: $_studentId'
                              : 'Please check-in to start',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Colors.white60, size: 14),
                            const SizedBox(width: 6),
                            Text(todayDate,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current class', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            'Choose the session you are attending right now.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedClassId,
                            decoration: const InputDecoration(labelText: 'Class'),
                            items: _courses
                                .map(
                                  (course) => DropdownMenuItem<String>(
                                    value: course.id,
                                    child: Text('${course.id} • ${course.name}'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _selectedClassId = value;
                              });
                            },
                          ),

                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'Check-in',
                          description: 'Capture QR, GPS, previous topic, expected topic, and mood.',
                          icon: Icons.login_rounded,
                          tint: const Color(0xFFD8F0EC),
                          onPressed: todaySession?.checkIn != null
                              ? null
                              : () => _openFlow(SessionFormMode.checkIn),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          title: 'Finish class',
                          description: 'Capture final QR, GPS, learning summary, and feedback.',
                          icon: Icons.task_alt_rounded,
                          tint: const Color(0xFFF8E4C8),
                          onPressed: todaySession?.checkIn == null || todaySession?.finish != null
                              ? null
                              : () => _openFlow(SessionFormMode.finishClass),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent sessions', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          if (widget.store.sessions.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Text('No attendance records yet. Start with today\'s check-in.'),
                            )
                          else
                            ...widget.store.sessions.take(1).map(_buildSessionTile),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionTile(AttendanceSession session) {
    final dateText = DateFormat('dd MMM yyyy').format(session.sessionDate);
    
    // Determine status: if finished, show "Class finished", otherwise show "Check-in done"
    String statusLabel = session.finish != null ? 'Class finished' : 'Check-in done';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.className, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${session.classId} • $dateText'),
                  ],
                ),
              ),
              _StatusChip(label: statusLabel, isComplete: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.checkIn == null
                ? 'Check-in not submitted'
                : 'Check-in mood: ${session.checkIn!.moodScore}/5 • ${session.checkIn!.expectedTopic}',
          ),
          const SizedBox(height: 6),
          Text(
            session.finish == null
                ? 'Class completion not submitted'
                : 'Learned: ${session.finish!.learnedToday}',
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.tint,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color tint;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(icon, color: const Color(0xFF132238)),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onPressed,
            child: Text(title),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isComplete});

  final String label;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFD8F0EC) : const Color(0xFFF3E5D1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class CourseOption {
  const CourseOption({required this.id, required this.name});

  final String id;
  final String name;
}

const List<CourseOption> _courses = <CourseOption>[
  CourseOption(id: 'CSC101', name: 'Mobile App Development'),
  CourseOption(id: 'CSC202', name: 'Software Engineering'),
  CourseOption(id: 'MAT115', name: 'Discrete Mathematics'),
];