import 'package:flutter/material.dart';
import 'package:kkplayer/Accces%20Device/audiofiles.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Audio App',
      home: AudioFiles(), // Start with AudioFiles
    );
  }
}