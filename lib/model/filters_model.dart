// import 'package:flutter/widgets.dart';

// class FilterModel {
//   String icon;
//   // Icon icon;
//   String name;
//   Widget? screen; // Updated to Widget type

//   FilterModel({
//     required this.icon,
//     required this.name,
//     required this.screen,
//   });
// }




import 'package:flutter/material.dart';

class FilterModel {
  final String name;
  final String icon;
  final Widget Function()? screen; // Function to return Widget

  FilterModel({
    required this.name,
    required this.icon,
    this.screen, // Function to return Widget
  });
}
