// import 'package:animated_movies_app/constants/ui_constant.dart';
// import 'package:animated_movies_app/data/filters.dart';
// import 'package:flutter/material.dart';

// class FiltersWidget extends StatelessWidget {
//   const FiltersWidget({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Our Products",
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Colors.white,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 18),
//           child: SizedBox(
//             height: 100,
//             child: ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemCount: FiltersData.listOfFilters.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     if (FiltersData.listOfFilters[index].screen != null) {
//                       print(
//                           "Navigating to: ${FiltersData.listOfFilters[index].name}");
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               FiltersData.listOfFilters[index].screen!,
//                         ),
//                       );
//                     } else {
//                       print(
//                           "Screen for ${FiltersData.listOfFilters[index].name} is not defined.");
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 30),
//                     child: Column(
//                       children: [
//                         Container(
//                           height: 52,
//                           width: 52,
//                           decoration: BoxDecoration(
//                             color: const Color(0xff51535E),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Center(
//                             child: UiConstants.image(
//                               path: FiltersData.listOfFilters[index].icon,
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Text(
//                             FiltersData.listOfFilters[index].name,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.normal,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }






import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/data/filters.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';

class FiltersWidget extends StatelessWidget {
  final LoginModelApi userData; // Add this parameter to receive userData

  const FiltersWidget({
    Key? key,
    required this.userData, // Ensure you pass userData to the widget
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the method getListOfFilters to retrieve the list of filters
    final filters = FiltersData.getListOfFilters(userData);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Our Products",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18),
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                return GestureDetector(
                  onTap: () {
                    final screenFunction = filter.screen;
                    if (screenFunction != null) {
                      print("Navigating to: ${filter.name}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => screenFunction(),
                        ),
                      );
                    } else {
                      print("Screen for ${filter.name} is not defined.");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 30),
                    child: Column(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xff51535E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: UiConstants.image(
                              path: filter.icon,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            filter.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
