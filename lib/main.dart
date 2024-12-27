import 'package:audiotagger/audiotagger.dart';
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
  Future<String> getArtist(String filePath) async {
  final tagger = Audiotagger();

  try {
    Map<String, String>? tags = (await tagger.readTags(path: filePath)) as Map<String, String>?;
    String artist = tags?['artist'] ?? "Unknown Artist";
    if (artist.isEmpty || artist.toLowerCase() == "unknown") {
      artist = "Unknown Artist";
    }
    return artist;
  } catch (e) {
    return "Unknown Artist";
  }
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
                      return Container(
                        margin: const EdgeInsets.all(0),
                        padding: const EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 36, 35, 35), // Background color
                          borderRadius:
                              BorderRadius.circular(0), // Rounded corners
                          border: Border.all(
                              color: Colors.white, // Border color
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
                          trailing: const Icon(Icons.more_vert_outlined,color: Colors.white,),
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
