import 'package:flutter/material.dart';

class UserIcons {
  static Icon getUserIconWidget(int iconNum) {
    switch (iconNum) {
      case 1:
        return Icon(Icons.assistant_photo);
        break;
      default:
        return Icon(Icons.ac_unit);
        break;
    }
  }
}
