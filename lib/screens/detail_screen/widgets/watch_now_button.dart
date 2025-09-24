import 'package:animated_movies_app/constants/images_path.dart';

import 'package:flutter/material.dart';

// For using launchUrlString
// Watch now button in detail screen
class WatchNowButton extends StatefulWidget {
  const WatchNowButton({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  State<WatchNowButton> createState() => _WatchNowButtonState();
}

class _WatchNowButtonState extends State<WatchNowButton> {
  //  late YoutubePlayerController _controller;
  // final String videoUrl = 'https://www.youtube.com/watch?v=vebF0NZfPVY'; // Example URL
  //   @override
  // void initState() {
  //   super.initState();
  //   String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
  //   _controller = YoutubePlayerController(
  //     initialVideoId: videoId,
  //     flags: YoutubePlayerFlags(
  //       autoPlay: true,
  //       mute: false,
  //     ),
  //   );
  // }
  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //   showDialog(
        //     context: context,
        //     builder: (BuildContext context) => AlertDialog(
        //       content: Container(
        //         width: MediaQuery.of(context).size.width * 0.8,
        //         child: YoutubePlayer(
        //           controller: _controller,
        //           showVideoProgressIndicator: true,
        //           progressIndicatorColor: Colors.blueAccent,
        //           progressColors: ProgressBarColors(
        //             playedColor: Colors.blue,
        //             handleColor: Colors.blueAccent,
        //           ),
        //           onReady: () {
        //             // Perform actions when player is ready
        //           },
        //           onEnded: (metaData) {
        //             // Perform actions when video ends
        //           },
        //         ),
        //       ),
        //     ),
        //   );
      },
      child: Container(
        height: 85,
        color: Colors.black,
        child: Stack(
          children: [
            const Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "IT Staffs",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 140,
                width: widget.size.width * 0.7,
                child: Image.asset(
                  ImagePath.glowingButton,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
