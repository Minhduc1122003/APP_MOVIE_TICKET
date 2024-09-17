import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerPage extends StatelessWidget {
  final String videoUrl;

  TrailerPage({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    // Lấy ID video từ URL YouTube
    final videoId = YoutubePlayer.convertUrlToId(videoUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trailer'),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId!,
            flags: YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
            ),
          ),
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}
