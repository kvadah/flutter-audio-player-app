
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:developer';
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
    getAudioFolders();
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
  Future<void> _scanDirectory(Directory dir, List<String> folderPaths) async {
  try {
    final List<FileSystemEntity> entities = dir.listSync(recursive: false);

    bool folderHasAudio = false;

    for (var entity in entities) {
      if (entity is File && isAudioFile(entity.path)) {
        folderHasAudio = true; // Folder has at least one audio file
      } else if (entity is Directory && !entity.path.contains("/Android")) {
        await _scanDirectory(entity, folderPaths); // Recursively scan subfolders
      }
    }
    // Add the folder if it contains audio files
    if (folderHasAudio) {
      folderPaths.add(dir.path);
    }
  } catch (e) {
    log("Error scanning directory ${dir.path}: $e");
  }
}

  Future<List<String>> getAudioFolders() async {
     await requestAudioPermission();

    final rootDir = Directory("/storage/emulated/0"); // Root directory
    final List<String> folderPaths = []; // List to store folder paths

     if (await rootDir.exists()) {
    try {
      await _scanDirectory(rootDir, folderPaths);
      log("Folders with audio files: $folderPaths");
    } catch (e) {
      log("Error scanning directories: $e");
    }
  } else {
    log("Root directory does not exist.");
  }

  setState(() {
    audioPaths = folderPaths;
    isLoading = false;
  });

    return folderPaths;
  }
  bool isAudioFile(String path) {
  final audioExtensions = ['.mp3', '.wav', '.m4a', '.ogg', '.flac'];
  return audioExtensions.any((ext) => path.toLowerCase().endsWith(ext));
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // backgroundColor: ,
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
                      return Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 36, 35, 35), // Background color
                          borderRadius:
                              BorderRadius.circular(0), // Rounded corners
                          border: Border.all(
                              // Border color
                              width: 0 // Border width
                              ),
                        ),
                        child: ListTile(
                          title: Text(
                            path.split('/').last,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // subtitle: Text(path),
                          trailing: const Icon(
                            Icons.more_vert_outlined,
                            color: Colors.white,
                          ),
                          onTap: () {
                            // Handle audio file tap (e.g., play the audio)
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
