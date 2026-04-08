// // Dummy movies data
// import 'package:animated_movies_app/constants/images_path.dart';
// import 'package:animated_movies_app/model/movies_model.dart';

// class ApacheData {
//   static List<ApacheModel> apacheList = [
//     ApacheModel(
//       id: "1",
//       name: "Appache Fopotwear Pvt Ltd",
//       movieTypeAndEpisode: "2026 | Addidas Shoes|",
//       rating: 5,
//       coverImage: ImagePath.appache,
//       plot:
//           "We Supply Most Beautiful Sports Product for the World's Best Brand adidas. Apache Serving as an Official Partner & Supply shoes for adidas Exclusively.",
//     ),
//     // ApacheModel(
//     //   id: "2",
//     //   name: "PayRoll Team",
//     //   movieTypeAndEpisode: "PayRoll Team",
//     //   rating: 4,
//     //   coverImage: ImagePath.payroll,
//     //   plot:
//     //       "A payroll department takes care of all aspects of payroll, from finalizing tax deductions and gathering attendance information to calculating wages and managing records. Decides benefits such as pay increments, bonuses, overtime pay, etc.",
//     // ),
//     // ApacheModel(
//     //   id: "3",
//     //   name: "Appache Mambattu",
//     //   movieTypeAndEpisode: "2024 | Addidas Shoes|",
//     //   rating: 5,
//     //   coverImage: ImagePath.app,
//     //   plot:
//     //       "We Supply Most Beautiful Sports Product for the World's Best Brand adidas. Apache Serving as an Official Partner & Supply shoes for adidas Exclusively.",
//     // ),

//     ApacheModel(
//         id: "2",
//         name: "Appache Fopotwear Pvt Ltd",
//         movieTypeAndEpisode: "2026 | Addidas Shoes|",
//         rating: 5,
//         coverImage: ImagePath.app,
//         plot:
//             "We supply high-quality sports products for Adidas as an official partner."),
//     ApacheModel(
//         id: "3",
//         name: "IT Team",
//         movieTypeAndEpisode: "IT Team",
//         rating: 5,
//         coverImage: ImagePath.itTeam,
//         plot:
//             "Responsible for managing systems, infrastructure, and technical support."),
//   ];
// }

import 'package:animated_movies_app/constants/images_path.dart';
import 'package:animated_movies_app/model/movies_model.dart';

class ApacheData {
  static List<ApacheModel> apacheList = [
    ApacheModel(
      id: "1",
      name: "Apache Footwear Pvt Ltd",
      department: "Adidas Manufacturing",
      rating: 5,
      image: ImagePath.appache,
      description:
          "We supply high-quality sports products for Adidas as an official partner.",
    ),
    ApacheModel(
      id: "2",
      name: "Apache Footwear Pvt Ltd",
      department: "Production Unit",
      rating: 5,
      image: ImagePath.addidas,
      description:
          "Handles large-scale footwear manufacturing and production processes.",
    ),
    ApacheModel(
      id: "3",
      name: "IT Team",
      department: "Technology",
      rating: 5,
      image: ImagePath.itTeam,
      description:
          "Responsible for managing systems, infrastructure, and technical support.",
    ),
  ];
}
