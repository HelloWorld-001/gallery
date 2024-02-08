import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_player/video_player.dart';

class VideoProvider extends StatefulWidget {
  final String mediumId;

  const VideoProvider({super.key, required this.mediumId});

  @override
  State<VideoProvider> createState() => _VideoProviderState();
}

class _VideoProviderState extends State<VideoProvider> {
  late VideoPlayerController controller;
  File? _file;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await PhotoGallery.getFile(mediumId: widget.mediumId);
      controller = VideoPlayerController.file(_file!);
      controller.initialize().then((_) {
        setState(() {});
      });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return !controller.value.isInitialized
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    controller.value.isPlaying ? controller.pause() : controller.play();
                  });
                },
                child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ],
          );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}