import 'package:flutter/material.dart';
import 'time_picker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsung Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TimePickerScreen(),
    );
  }
}
