import 'package:animated_movies_app/constants/images_path.dart';
import 'package:animated_movies_app/model/filters_model.dart';

class FiltersData {
  static List<FilterModel> listOfFilters = [
    FilterModel(name: "Shoes", icon: ImagePath.genreIcon),
    FilterModel(name: "Ratings", icon: ImagePath.starIcon),
    FilterModel(name: "Language", icon: ImagePath.globeIcon),
    FilterModel(name: "My Cart", icon: ImagePath.movieReelIcon),
  ];
}
