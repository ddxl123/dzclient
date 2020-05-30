import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dzclient/bi/CheckNetwork.dart';
import 'package:dzclient/bi/ResponseCodeHandle.dart';
import 'package:dzclient/bi/SP.dart';
import 'package:flutter/material.dart';

class SendRequest {
  static Map<String, bool> _bindLineMap = {};

  static Dio _dio;
  static String _url = "http://10.128.248.169:8081";
  static void initInMain() {
    _dio = Dio();
    _dio.options.baseUrl = _url;
    _dio.options.connectTimeout = 5000; //连接服务器超时
  }

  ///每次请求都需要先检测网络
  static bool _hasNetwork() {
    //客户端网络连接异常拦截
    if (CheckNetwork.result == ConnectivityResult.none) {
      BotToast.showNotification(title: (_) => Text("网络连接异常，请检查您的网络!"));
      return false;
    }
    return true;
  }

  static Future request({
    @required BuildContext context,
    @required String method,
    @required String route,
    Map<dynamic, dynamic> data,
    Map<String, dynamic> query,
    @required List<bool> Function(String code, Response<dynamic> response) toCodeHandles,
    @required Function toOtherCodeHandles,
    @required String bindLine,
    @required bool isLoading,
  }) async {
    ///检查网络
    if (!_hasNetwork()) {
      await Future(() {}).whenComplete(() {
        responseCodeHandles(
          toCodeHandles: toCodeHandles("0", null),
          toOtherCodeHandles: toOtherCodeHandles,
          otherCodeHandles: otherCodeHandles(code: "0", context: context, onError: null, route: route),
        );
      });
      return;
    }

    ///TODO: 中断上次请求的回调 和 中断第二次请求的回调
    ///绑定线路
    if (bindLine != null) {
      if (_bindLineMap[bindLine] == true) {
        await Future(() {}).whenComplete(() {
          print(["toOtherCodeHandles", toOtherCodeHandles]);
          responseCodeHandles(
            toCodeHandles: toCodeHandles("1", null),
            toOtherCodeHandles: toOtherCodeHandles,
            otherCodeHandles: otherCodeHandles(code: "1", context: context, onError: null, route: route),
          );
        });
        return;
      }

      ///注意要让 _bindLineMap[bindLine] = false
      _bindLineMap[bindLine] = true;
    }

    ///显示loading
    OverlayEntry entry = isLoading ? _requestLoading(context) : null;

    ///发送请求
    // BotToast.showNotification(title: (_) => Text("正在发送..."));

    ///TODO: 耗时测试，可移除
    // await Future.delayed(Duration(seconds: 2));

    await _dio
        .request(
      route,
      data: data,
      queryParameters: query,
      options: Options(method: method, headers: {"token": SP.sp?.getString("token")}),
    )
        .then(
      (onValue) {
        responseCodeHandles(
          toCodeHandles: toCodeHandles(onValue.data["code"], onValue),
          toOtherCodeHandles: toOtherCodeHandles,
          otherCodeHandles: otherCodeHandles(code: onValue.data["code"], context: context, onError: null, route: route),
        );
      },
    ).catchError(
      (onError) {
        ///综合异常处理
        responseCodeHandles(
          toCodeHandles: toCodeHandles("2", null),
          toOtherCodeHandles: toOtherCodeHandles,
          otherCodeHandles: otherCodeHandles(code: "2", context: context, onError: onError, route: route),
        );
      },
    );

    entry?.remove();
    if (bindLine != null) {
      _bindLineMap[bindLine] = false;
    }
  }

  static OverlayEntry _requestLoading(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (_) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  child: Container(
                    color: Colors.green,
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Text("请求中..."),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    overlayState.insert(overlayEntry);
    return overlayEntry;
  }
}
