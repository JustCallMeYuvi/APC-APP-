// To parse this JSON data, do
//
//     final userAccess = userAccessFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

const targetOutputReportIcon = Symbols.add_task; // Use IconData directly
const skillMappingRequestIcon = Symbols.skillet_sharp; // Use IconData directly
const punchIcon = Symbols.fingerprint_rounded; // Use IconData directly

List<UserAccess> userAccessFromJson(String str) =>
    List<UserAccess>.from(json.decode(str).map((x) => UserAccess.fromJson(x)));

String userAccessToJson(List<UserAccess> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserAccess {
  int tabId;
  String tabName;
  String tabRoute;
  dynamic icon;
  List<Page> pages;

  UserAccess({
    required this.tabId,
    required this.tabName,
    required this.tabRoute,
    required this.icon,
    required this.pages,
  });

  factory UserAccess.fromJson(Map<String, dynamic> json) => UserAccess(
        tabId: json["tabId"],
        tabName: json["tabName"],
        tabRoute: json["tabRoute"],
        icon: json["icon"],
        pages: List<Page>.from(json["pages"].map((x) => Page.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "tabId": tabId,
        "tabName": tabName,
        "tabRoute": tabRoute,
        "icon": icon,
        "pages": List<dynamic>.from(pages.map((x) => x.toJson())),
      };
}

class Page {
  int pageId;
  String pageName;
  String pageRoute;

  Page({
    required this.pageId,
    required this.pageName,
    required this.pageRoute,
  });

  factory Page.fromJson(Map<String, dynamic> json) => Page(
        pageId: json["pageId"],
        pageName: json["pageName"],
        pageRoute: json["pageRoute"],
      );

  Map<String, dynamic> toJson() => {
        "pageId": pageId,
        "pageName": pageName,
        "pageRoute": pageRoute,
      };
}

// Method to map a page name to an icon
IconData getIconForPage(Page page) {
  switch (page.pageName) {
    case 'Target Output Report':
      // return Icons.poll_rounded;
      return targetOutputReportIcon; // Correct usage

    case 'Efficiency Report':
      return Icons.report;
    case 'RFT Report':
      return Icons.report;
    case 'Notification':
      return Icons.notifications;
    case 'Skill Mapping Request':
      return Icons.work;
    // return skillMappingRequestIcon;
    case 'Skill Mapping Approval':
      return Icons.work_history;
    case 'GMS Export':
      return Icons.fire_truck;
    case 'GMS Tracking':
      return Icons.location_on;
    case 'GMS Charts':
      return Icons.bar_chart_rounded;
    case 'Search':
      return Icons.search;
    case 'Patrolling':
      return Icons.security;
    case 'Export Approvals':
      return Icons.approval;

    case 'Feedback':
      return Icons.feedback_outlined;

    case 'Maxking GMS':
      return Icons.fire_truck;
    case 'Tracking':
      return Icons.location_on;
    case 'Charts':
      return Icons.bar_chart_rounded;
    case 'Punching':
      return punchIcon; // Use Material Symbol for punch clock
    case 'Remove Vehicle ID':
      return Icons.remove_circle_outline;
    case 'Assembly Output':
      return Icons.output;
    case 'Reports':
      return Icons.production_quantity_limits;
    case 'Asset Management':
      return Icons.store;
    case 'Bussiness Info':
      return Icons.business_center;
    case 'Order Info':
      return Icons.factory;
    case 'Out Vehicles':
      return Icons.fire_truck_outlined;
    case 'Gate Out Vehicles':
      return Icons.fire_truck_outlined;
    case 'Remove Vehicle':
      return Icons.remove_circle_outline_sharp;
    case 'Car Approval':
      return Icons.car_crash_outlined;
    case 'Incharges Add':
      return Icons.add_box;
    case 'In & Out':
      return Icons.outbond;
    case 'Cars Add':
      return Icons.car_crash_sharp;
    case 'Car Availability':
      return Icons.assistant_navigation;
    case 'Car Conveyance Charts':
      return Icons.graphic_eq_sharp;
    default:
      return Icons.help_outline; // Fallback icon
  }
}
