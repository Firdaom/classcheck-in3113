import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../models/attendance_session.dart';
import '../services/attendance_store.dart';
import 'qr_scanner_screen.dart';

enum SessionFormMode {
  checkIn,
  finishClass,
}

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({
    super.key,
    required this.store,
    required this.classId,
    required this.className,
    required this.mode,
    required this.sessionDate,
  });

  final AttendanceStore store;
  final String classId;
  final String className;
  final SessionFormMode mode;
  final DateTime sessionDate;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();

  late final DateTime _capturedAt;
  Position? _position;
  String? _locationError;
  String? _qrCode;
  int? _moodScore;
  bool _isSaving = false;
  bool _isLoadingLocation = true;
  final bool _isTestMode = true; // Allow testing without real QR scanning

  bool get _isCheckIn => widget.mode == SessionFormMode.checkIn;

  @override
  void initState() {
    super.initState();
    _capturedAt = DateTime.now();
    _captureLocation();
  }

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required to submit attendance.');
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) {
        return;
      }

      setState(() {
        _position = position;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const QrScannerScreen(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _qrCode = result;
    });
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture location before submitting.')),
      );
      return;
    }

    if (_qrCode == null && !_isTestMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan the class QR code before submitting.')),
      );
      return;
    }

    // Auto-fill test QR code if in test mode and no QR code scanned yet
    if (_qrCode == null && _isTestMode) {
      _qrCode = 'TEST-QR-${DateTime.now().millisecondsSinceEpoch}';
    }

    if (_isCheckIn && _moodScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select your mood before class.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final submission = AttendanceSubmission(
      timestamp: _capturedAt,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      qrCode: _qrCode!,
      previousTopic: _isCheckIn ? _previousTopicController.text.trim() : null,
      expectedTopic: _isCheckIn ? _expectedTopicController.text.trim() : null,
      moodScore: _isCheckIn ? _moodScore : null,
      learnedToday: _isCheckIn ? null : _learnedTodayController.text.trim(),
      feedback: _isCheckIn ? null : _feedbackController.text.trim(),
    );

    if (_isCheckIn) {
      await widget.store.saveCheckIn(
        classId: widget.classId,
        className: widget.className,
        sessionDate: widget.sessionDate,
        submission: submission,
      );
    } else {
      await widget.store.saveFinish(
        classId: widget.classId,
        className: widget.className,
        sessionDate: widget.sessionDate,
        submission: submission,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCheckIn ? 'Check-in details' : 'Finish class'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF4EFE7), Color(0xFFE2F0EF)],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _InfoCard(
                  title: widget.className,
                  subtitle: widget.classId,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.schedule_rounded,
                        label: 'Recorded time',
                        value: dateFormat.format(_capturedAt),
                      ),
                      const SizedBox(height: 12),
                      _LocationStatus(
                        isLoading: _isLoadingLocation,
                        error: _locationError,
                        position: _position,
                        onRetry: _captureLocation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'QR verification',
                  subtitle: _qrCode == null ? (_isTestMode ? 'Test mode (optional)' : 'Required before submit') : 'Verified ✓',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _qrCode ?? 'No QR code scanned yet.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: _scanQrCode,
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: Text(_qrCode == null ? 'Scan class QR' : 'Scan again'),
                          ),
                          if (_isTestMode)
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _qrCode = 'TEST-QR-${DateTime.now().millisecondsSinceEpoch}';
                                });
                              },
                              icon: const Icon(Icons.bug_report_outlined),
                              label: const Text('Use test QR'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_isCheckIn) ...[
                  _InfoCard(
                    title: 'Before class reflection',
                    subtitle: 'All fields are required',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _previousTopicController,
                          decoration: const InputDecoration(
                            labelText: 'Topic covered in the previous class',
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _expectedTopicController,
                          decoration: const InputDecoration(
                            labelText: 'What do you expect to learn today?',
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Mood before class',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List<Widget>.generate(_moodOptions.length, (index) {
                            final option = _moodOptions[index];
                            return ChoiceChip(
                              label: Text('${option.emoji} ${option.label}'),
                              selected: _moodScore == option.score,
                              onSelected: (_) {
                                setState(() {
                                  _moodScore = option.score;
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _InfoCard(
                    title: 'After class reflection',
                    subtitle: 'Summarize learning and add feedback',
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _learnedTodayController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'What did you learn today?',
                          ),
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _feedbackController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Feedback about the class or instructor',
                          ),
                          validator: _requiredValidator,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(_isSaving
                      ? 'Saving...'
                      : _isCheckIn
                          ? 'Submit check-in'
                          : 'Submit finish class'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Records are currently stored on-device and marked for later sync.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }

    return null;
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0E7490)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationStatus extends StatelessWidget {
  const _LocationStatus({
    required this.isLoading,
    required this.error,
    required this.position,
    required this.onRetry,
  });

  final bool isLoading;
  final String? error;
  final Position? position;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Capturing current location...'),
        ],
      );
    }

    if (position != null) {
      return _InfoRow(
        icon: Icons.location_on_outlined,
        label: 'GPS location',
        value: '${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          error ?? 'Location not available.',
          style: const TextStyle(color: Color(0xFFB42318)),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry location'),
        ),
      ],
    );
  }
}

class _MoodOption {
  const _MoodOption({
    required this.score,
    required this.emoji,
    required this.label,
  });

  final int score;
  final String emoji;
  final String label;
}

const List<_MoodOption> _moodOptions = <_MoodOption>[
  _MoodOption(score: 1, emoji: '😡', label: 'Very negative'),
  _MoodOption(score: 2, emoji: '🙁', label: 'Negative'),
  _MoodOption(score: 3, emoji: '😐', label: 'Neutral'),
  _MoodOption(score: 4, emoji: '🙂', label: 'Positive'),
  _MoodOption(score: 5, emoji: '😄', label: 'Very positive'),
];