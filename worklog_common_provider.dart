import 'package:flutter/material.dart';

class WorklogCommonProvider extends ChangeNotifier {
  Locale language = const Locale("en");
  bool isErrorfound = false;
  void onError() {
    isErrorfound = true;
    notifyListeners();
  }

  void onErrorCanceled() {
    isErrorfound = false;
    notifyListeners();
  }

  List<String> companyes = [];
  List<String> employees = [];
  List<String> clients = [];
  List<String> workTypes = [];

  List<String> workTitle = [
    "TESTING",
    "UI DESIGN",
    "BACKEND",
    "BUG FIX",
    "R&D",
    "FRONT END",
    "SUPPORT",
    "GENERAL",
    "CUSTOM"
  ];
  void clear() {
    companyes = [];
    employees = [];
    clients = [];
    workTypes = [];
  }

  void rebuild() {
    notifyListeners();
  }
}
