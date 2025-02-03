import 'package:animated_movies_app/constants/images_path.dart';
import 'package:animated_movies_app/screens/detail_screen/widgets/cast_widget.dart';
import 'package:flutter/material.dart';

class MoviesCast extends StatelessWidget {
  const MoviesCast({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            "Cast",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Row(
          children: [
            CastWidget(
              name: "Yuvaraj",
              role: "Flutter Developer",
              imgUrl: ImagePath.yuvarajpic,
            ),
            CastWidget(
              name: "Imran",
              role: "Mobility Team Lead",
              imgUrl: ImagePath.person2,
            ),
          ],
        ),
        Row(
          children: [
            CastWidget(
              name: "Upendra",
              role: "Junior Developer ",
              imgUrl: ImagePath.person3,
            ),
            CastWidget(
              name: "Premika ",
              role: "Full Stack Developer",
              imgUrl: ImagePath.person4,
            ),
          ],
        ),
      ],
    );
  }
}
