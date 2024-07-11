import 'package:animated_movies_app/constants/images_path.dart';
import 'package:animated_movies_app/model/filters_model.dart';
import 'package:animated_movies_app/screens/home_screen/charts_screen.dart';
import 'package:animated_movies_app/screens/home_screen/shoes_screen.dart';

class FiltersData {
  static List<FilterModel> listOfFilters = [
    FilterModel(name: "Shoes", icon: ImagePath.genreIcon, screen: null),
    FilterModel(
        name: "Reviews", icon: ImagePath.starIcon, screen: const ChartsScreen()),
    FilterModel(name: "Language", icon: ImagePath.globeIcon, screen: null),
    FilterModel(name: "My Cart", icon: ImagePath.movieReelIcon, screen: null),
  ];
}
