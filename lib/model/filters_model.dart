import 'package:flutter/widgets.dart';

class FilterModel {
  String icon;
  // Icon icon;
  String name;
  Widget? screen; // Updated to Widget type

  FilterModel({
    required this.icon,
    required this.name,
    required this.screen,
  });
}
