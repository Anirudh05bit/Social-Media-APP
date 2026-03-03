import 'dart:async';
import 'package:flutter/material.dart';
import '../services/focus_mode_service.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({super.key});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  final _service = FocusModeService();
  Timer? _timer;

  DateTime? _endTime;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _load() async {
    _endTime = await _service.getEndTime();
    _tick();
  }

  Future<void> _tick() async {
    final enabled = await _service.isEnabled();
    if (!enabled) {
      if (mounted) Navigator.pop(context, true);
      return;
    }

    if (_endTime == null) {
      setState(() => _remaining = null);
      return;
    }

    final diff = _endTime!.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    String two(int x) => x.toString().padLeft(2, '0');
    return "${two(h)}:${two(m)}:${two(s)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF9500).withOpacity(0.12),
              const Color(0xFFFFAB76).withOpacity(0.10),
              const Color(0xFFFF6B6B).withOpacity(0.10),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.self_improvement, size: 72),
                const SizedBox(height: 18),
                const Text(
                  "Focus Mode",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  _remaining == null
                      ? "Focus is ON"
                      : "Time left: ${_format(_remaining!)}",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 28),

                // Exit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _service.disable();
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    },
                    child: const Text("Exit Focus Mode"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}