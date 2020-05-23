import 'package:connectivity/connectivity.dart';

class CheckNetwork {
  ///监听是异步的，若初始化后result被立即调用会报null，因此要在main里的init进行初始化
  static ConnectivityResult result;
  static void initInMain() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      result = connectivityResult;
    });
  }
}
