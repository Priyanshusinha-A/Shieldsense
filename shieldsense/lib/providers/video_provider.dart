import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProvider with ChangeNotifier {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  VideoPlayerController get controller => _controller;
  bool get isVideoInitialized => _isVideoInitialized;

  VideoProvider() {
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/wallpapers/wallpaper.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        _isVideoInitialized = true;
        notifyListeners();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
