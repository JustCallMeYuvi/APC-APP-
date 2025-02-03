import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerWidget extends StatefulWidget {
  final String filePath;

  const CustomVideoPlayerWidget({Key? key, required this.filePath}) : super(key: key);

  @override
  _CustomVideoPlayerWidgetState createState() => _CustomVideoPlayerWidgetState();
}

class _CustomVideoPlayerWidgetState extends State<CustomVideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerController.value.isInitialized
        ? AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}
