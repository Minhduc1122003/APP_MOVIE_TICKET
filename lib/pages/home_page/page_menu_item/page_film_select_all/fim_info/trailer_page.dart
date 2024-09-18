// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class TrailerPage extends StatelessWidget {
//   final String videoUrl;
//
//   TrailerPage({required this.videoUrl});
//
//   @override
//   Widget build(BuildContext context) {
//     // Lấy ID video từ URL YouTube
//     final videoId = YoutubePlayer.convertUrlToId(videoUrl);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Trailer'),
//       ),
//       body: Center(
//         child: kIsWeb
//             ? Text('YouTube Player không hỗ trợ trên Web.')
//             : YoutubePlayer(
//                 controller: YoutubePlayerController(
//                   initialVideoId: videoId!,
//                   flags: YoutubePlayerFlags(
//                     autoPlay: true,
//                     mute: false,
//                   ),
//                 ),
//                 showVideoProgressIndicator: true,
//               ),
//       ),
//     );
//   }
// }
