import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  final Map<String, String> _responses = {};

  Map<String, String> get responses => _responses;

  void setResponse(String question, String response) {
    _responses[question] = response;
    notifyListeners();
  }
    // ✅ This will clear all responses when the screen is closed
  void clearResponses() {
    responses.clear();
    notifyListeners();
  }
}
