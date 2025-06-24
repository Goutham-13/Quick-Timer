import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'timer_screen.dart';

class TimePickerScreen extends StatefulWidget {
  const TimePickerScreen({super.key});

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  final TextEditingController hourCtrl = TextEditingController(text: "0");
  final TextEditingController minuteCtrl = TextEditingController(text: "0");
  final TextEditingController secondCtrl = TextEditingController(text: "0");

  int normalizedHours = 0;
  int normalizedMinutes = 0;
  int normalizedSeconds = 0;

  final Color accentColor = const Color.fromARGB(255, 105, 105, 246);
  final Color bgColor = Colors.black;

  @override
  void initState() {
    super.initState();
    hourCtrl.addListener(_updateTime);
    minuteCtrl.addListener(_updateTime);
    secondCtrl.addListener(_updateTime);
    _updateTime();
  }

  void _updateTime() {
    final h = int.tryParse(hourCtrl.text) ?? 0;
    final m = int.tryParse(minuteCtrl.text) ?? 0;
    final s = int.tryParse(secondCtrl.text) ?? 0;

    int totalSeconds = h * 3600 + m * 60 + s;

    final newH = totalSeconds ~/ 3600;
    final newM = (totalSeconds % 3600) ~/ 60;
    final newS = totalSeconds % 60;

    setState(() {
      normalizedHours = newH;
      normalizedMinutes = newM;
      normalizedSeconds = newS;
    });
  }

  int totalTimeInSeconds() {
    return normalizedHours * 3600 + normalizedMinutes * 60 + normalizedSeconds;
  }

  @override
  void dispose() {
    hourCtrl.dispose();
    minuteCtrl.dispose();
    secondCtrl.dispose();
    super.dispose();
  }

  Widget inputBox(String label, TextEditingController controller) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 28, color: Colors.white),
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0",
                hintStyle: TextStyle(color: Colors.white30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getFormattedTime() {
    List<String> parts = [];
    if (normalizedHours > 0) parts.add('${normalizedHours}h');
    if (normalizedMinutes > 0) parts.add('${normalizedMinutes}m');
    if (normalizedSeconds > 0) parts.add('${normalizedSeconds}s');
    return parts.isEmpty ? '0s' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Live formatted display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  getFormattedTime(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // HH:MM:SS Inputs
              Row(
                children: [
                  inputBox("Hour", hourCtrl),
                  const SizedBox(width: 12),
                  inputBox("Min", minuteCtrl),
                  const SizedBox(width: 12),
                  inputBox("Sec", secondCtrl),
                ],
              ),

              const SizedBox(height: 50),

              ElevatedButton(
                onPressed: totalTimeInSeconds() > 0
                    ? () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SamsungTimerScreen(
                                initialSeconds: totalTimeInSeconds()),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Start",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
