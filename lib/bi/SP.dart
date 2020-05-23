import 'package:shared_preferences/shared_preferences.dart';

class SP {
  static SharedPreferences sp;
  static Future initInMain() async {
    sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}
