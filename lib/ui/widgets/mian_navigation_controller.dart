import 'package:flutter/material.dart';

class MainNavigationController extends ChangeNotifier {
  static final MainNavigationController _instance =
  MainNavigationController._internal();

  factory MainNavigationController() => _instance;

  MainNavigationController._internal();

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToProfile() {
    changeIndex(3); // Profile index
  }
}
