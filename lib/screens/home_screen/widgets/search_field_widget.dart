import 'package:animated_movies_app/constants/images_path.dart';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: size.width * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: UiConstants.image(
              path: ImagePath.searchIcon,
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 8,
              ),
              child: Text(
                "Search",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
            child: VerticalDivider(
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: UiConstants.image(
              path: ImagePath.micIcon,
            ),
          ),
        ],
      ),
    );
  }
}

// search text field

// import 'package:animated_movies_app/constants/images_path.dart';
// import 'package:animated_movies_app/constants/ui_constant.dart';
// import 'package:flutter/material.dart';

// class SearchField extends StatefulWidget {
//   const SearchField({
//     Key? key,
//     required this.size,
//   }) : super(key: key);

//   final Size size;

//   @override
//   _SearchFieldState createState() => _SearchFieldState();
// }

// class _SearchFieldState extends State<SearchField> {
//   // TextEditingController _controller = TextEditingController();

//   @override
//   void dispose() {
//     // _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       //  height: MediaQuery.of(context).size.height ,
//       height: 50,
//       width: widget.size.width * 0.85,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center, // Adjusted alignment
//         children: [
//           SizedBox(
//             height: 24,
//             width: 24,
//             child: UiConstants.image(
//               path: ImagePath.searchIcon,
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8),
//               child: TextField(
//                 // controller: _controller,
//                 decoration: InputDecoration(
//                   hintText: "Search",
//                   hintStyle: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.normal,
//                     color: Colors.grey,
//                   ),
//                   border: InputBorder.none,
//                 ),
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.white, // Adjusted text color
//                 ),
//                 onChanged: (value) {
//                   // Handle search query changes here
//                   // You can use the value from _controller.text
//                 },
//               ),
//             ),
//           ),
//           SizedBox(
//             height: 24,
//             child: VerticalDivider(
//               color: Colors.grey,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 8),
//             child: UiConstants.image(
//               path: ImagePath.micIcon,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
