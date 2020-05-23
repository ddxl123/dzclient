import 'package:flutter/material.dart';

class HomePageProvider extends ChangeNotifier {
  String _sortMethod = "随机";
  String get sortMethod => _sortMethod;
  set sortMethod(value) {
    _sortMethod = value;
    notifyListeners();
  }

  ScrollController scrollController = ScrollController();
}
