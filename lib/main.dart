import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(const AudioFolders());
}

class AudioFolders extends StatefulWidget {
  const AudioFolders({super.key});

  @override
  State<AudioFolders> createState() => _AudioFoldersState();
}

class _AudioFoldersState extends State<AudioFolders> {
  List<String> audioPaths = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getAllAudioFiles();
  }

  Future<void> requestAudioPermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  // Fetch audio files after permission is granted
  Future<void> getAllAudioFiles() async {
    await requestAudioPermission();

    final rootDir = Directory("/storage/emulated/0/Music");
    final List<String> paths = [];

    if (await rootDir.exists()) {
      try {
        rootDir.listSync(recursive: true).forEach((entity) {
          if (entity is File &&
              (entity.path.endsWith('.mp3') ||
                  entity.path.endsWith('.wav') ||
                  entity.path.endsWith('.m4a') ||
                  entity.path.endsWith('.ogg') ||
                  entity.path.endsWith('.flac'))) {
            paths.add(entity.path); // Add file paths instead of File objects
          }
        });
      } catch (e) {
        print("Error scanning directories: $e");
      }
    }

    setState(() {
      audioPaths = paths;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Audio Files"),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : audioPaths.isEmpty
                ? const Center(child: Text("No audio files found"))
                : ListView.builder(
                    itemCount: audioPaths.length,
                    itemBuilder: (context, index) {
                      final path = audioPaths[index];
                      return ListTile(
                        title: Text(path.split('/').last),
                       // subtitle: Text(path),
                        onTap: () {
                          // Handle audio file tap (e.g., play the audio)
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
