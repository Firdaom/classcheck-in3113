import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/attendance_session.dart';
import '../services/attendance_store.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.store});

  final AttendanceStore store;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy, HH:mm').format(dt);

  List<AttendanceSession> get _sessionsWithCheckIn =>
      widget.store.sessions.where((s) => s.checkIn != null).toList();

  List<AttendanceSession> get _sessionsWithFinish =>
      widget.store.sessions.where((s) => s.finish != null).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0E7490),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF0E7490),
          tabs: [
            Tab(
              icon: const Icon(Icons.login),
              text: 'Check-in (${_sessionsWithCheckIn.length})',
            ),
            Tab(
              icon: const Icon(Icons.logout),
              text: 'Finish class (${_sessionsWithFinish.length})',
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCheckInList(),
              _buildFinishList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCheckInList() {
    if (_sessionsWithCheckIn.isEmpty) {
      return _emptyState('No check-in records yet');
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sessionsWithCheckIn.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _checkInCard(_sessionsWithCheckIn[i]),
      ),
    );
  }

  Widget _checkInCard(AttendanceSession session) {
    final checkIn = session.checkIn;
    if (checkIn == null) return const SizedBox.shrink();

    const moodEmojis = ['😡', '🙁', '😐', '🙂', '😄'];
    const moodLabels = ['Very negative', 'Negative', 'Neutral', 'Positive', 'Very positive'];
    final moodIndex = (checkIn.moodScore ?? 1) - 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E7490).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.classId,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0E7490),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                moodEmojis[moodIndex],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              Text(
                moodLabels[moodIndex],
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF0E7490),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.schedule, _formatDate(checkIn.timestamp)),
          _infoRow(
            Icons.location_on_outlined,
            '${checkIn.latitude.toStringAsFixed(4)}, ${checkIn.longitude.toStringAsFixed(4)}',
          ),
          _infoRow(Icons.history, 'Previous: ${checkIn.previousTopic}'),
          _infoRow(Icons.lightbulb_outline, 'Expected: ${checkIn.expectedTopic}'),
          _infoRow(Icons.qr_code_2, 'QR: ${checkIn.qrCode}'),
        ],
      ),
    );
  }

  Widget _buildFinishList() {
    if (_sessionsWithFinish.isEmpty) {
      return _emptyState('No finish class records yet');
    }
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sessionsWithFinish.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _finishCard(_sessionsWithFinish[i]),
      ),
    );
  }

  Widget _finishCard(AttendanceSession session) {
    final finish = session.finish;
    if (finish == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8A726).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.classId,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFF8A726),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow(Icons.schedule, _formatDate(finish.timestamp)),
          _infoRow(
            Icons.location_on_outlined,
            '${finish.latitude.toStringAsFixed(4)}, ${finish.longitude.toStringAsFixed(4)}',
          ),
          _infoRow(Icons.auto_stories, 'Learned: ${finish.learnedToday}'),
          if ((finish.feedback ?? '').isNotEmpty)
            _infoRow(Icons.feedback_outlined, 'Feedback: ${finish.feedback}'),
          _infoRow(Icons.qr_code_2, 'QR: ${finish.qrCode}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
