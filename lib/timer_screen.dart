import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';
import 'time_picker_screen.dart';
import 'notification_service.dart';

class SamsungTimerScreen extends StatefulWidget {
  final int initialSeconds;

  const SamsungTimerScreen({super.key, required this.initialSeconds});

  @override
  State<SamsungTimerScreen> createState() => _SamsungTimerScreenState();
}

class _SamsungTimerScreenState extends State<SamsungTimerScreen>
    with SingleTickerProviderStateMixin {
  late int remainingSeconds;
  late int originalSeconds;
  late DateTime endTime;
  Timer? timer;
  bool isPaused = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    originalSeconds = widget.initialSeconds;
    remainingSeconds = originalSeconds;
    updateEndTime();
    startTimer();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: originalSeconds),
    )..forward();
  }

  void updateEndTime() {
    endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused && remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
          updateEndTime();
        });
        if (!_controller.isAnimating) _controller.forward();
      } else if (remainingSeconds == 0) {
        timer?.cancel();
        triggerTimerEndActions();
      }
    });
  }

void triggerTimerEndActions() {
  NotificationService.showTimerPopup(
    context: context,
    originalSeconds: originalSeconds,
  );
}

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
      if (isPaused) {
        _controller.stop();
      } else {
        _controller.forward();
        updateEndTime();
      }
    });
  }

  void resetTimer() {
    setState(() {
      remainingSeconds = originalSeconds;
      isPaused = false;
      updateEndTime();
    });
    _controller.reset();
    _controller.forward();
    startTimer();
  }

  String formatSmartTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    } else if (m > 0) {
      return '$m:${s.toString().padLeft(2, '0')}';
    } else {
      return s.toString();
    }
  }

  String formatInitialTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    List<String> parts = [];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0) parts.add('${s}s');
    return parts.join(' ').isEmpty ? '0s' : parts.join(' ');
  }

  String getEndTimeString() {
    return DateFormat('h:mm a').format(endTime);
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            timer?.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TimePickerScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = 1.0 - _controller.value;
                return Center(
                  child: SizedBox(
                    width: 360,
                    height: 360,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 330,
                          height: 330,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 12,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.grey.shade800,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPaused
                                  ? Colors.grey
                                  : (remainingSeconds <= 5
                                      ? Colors.red
                                      : const Color.fromARGB(255, 105, 105, 246)),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatInitialTime(originalSeconds),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              formatSmartTime(remainingSeconds),
                              style: const TextStyle(
                                fontSize: 64,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.notifications_none,
                                    size: 22, color: Colors.white54),
                                const SizedBox(width: 6),
                                Text(
                                  getEndTimeString(),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildActionButton('Reset', Colors.grey[800]!, resetTimer),
                buildActionButton(
                  isPaused ? 'Resume' : 'Pause',
                  isPaused
                      ? const Color.fromARGB(255, 105, 105, 246)
                      : Colors.red,
                  togglePause,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 130,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
