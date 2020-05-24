import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dzclient/bi/CheckNetwork.dart';
import 'package:dzclient/bi/CodeHandle.dart';
import 'package:dzclient/bi/SP.dart';
import 'package:dzclient/person/LoginPage.dart';
import 'package:flutter/material.dart';

class SendRequest {
  static Map<String, bool> _bindLineMap = {};

  static Dio _dio;
  static String _url = "http://10.128.71.43:8081";
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

  static Future<void> request({
    @required BuildContext context,
    @required String method,
    @required String route,
    Map<dynamic, dynamic> data,
    Map<String, dynamic> query,
    @required Function(String, Response<dynamic>) responseValue,
    String bindLine,
    bool isLoading = false,
  }) async {
    ///检查网络
    if (!_hasNetwork()) {
      return;
    }

    //绑定线路
    if (bindLine != null) {
      if (_bindLineMap[bindLine] == true) {
        BotToast.showNotification(title: (_) => Text("请求过于频繁"));
        return;
      }
      //注意要让 _bindLineMap[bindLine] = false
      _bindLineMap[bindLine] = true;
    }

    ///显示loading
    OverlayEntry entry = isLoading ? _requestLoading(context) : null;

    ///发送请求
    BotToast.showNotification(title: (_) => Text("正在发送..."));

    ///TODO: 耗时测试，可移除
    await Future.delayed(Duration(seconds: 2));

    await _dio
        .request(
      route,
      data: data,
      queryParameters: query,
      options: Options(method: method, headers: {"token": SP.sp?.getString("token")}),
    )
        .then(
      (onValue) {
        String code = onValue.data["code"];
        code = code ?? "null";
        codeHandles(
          code,
          [
            codeHandle(code, ["2001", "2002", "2003"], () {
              //检查是否登陆过
              if (SP.sp.getString("token") == null) {
                BotToast.showNotification(title: (_) => Text("请先登陆"));
                showLoginPage(context);
              } else {
                BotToast.showNotification(title: (_) => Text("登陆已过期，请重新登陆$code"));
                showLoginPage(context);
              }
            }),
            codeHandle(code, ["2004"], () {
              BotToast.showNotification(title: (_) => Text("服务器端异常，请重试$code"));
            }),
            codeHandle(code, ["2005"], () {
              BotToast.showNotification(
                //TODO: 这里要将用户名存储本地，然后在这里获取
                title: (_) => Text(
                  "数据库丢失该 @XXX 用户$code，请记住您的用户名，并及时联系管理员!\n\n已自动复制您的用户名。",
                ),
              );
            })
          ],
          elseHandle: () {
            responseValue(code, onValue);
          },
        );
      },
    ).catchError(
      (onError) {
        ///综合异常处理
        if (onError.runtimeType == DioError) {
          switch (onError.type) {
            case DioErrorType.CONNECT_TIMEOUT:
              //连接超时=请求时间+响应时间，没有响应的话，客户端是无法判断是否超时的。
              BotToast.showNotification(title: (_) => Text("err:连接服务器超时\n$route"));
              break;
            default:
              BotToast.showNotification(title: (_) => Text("err:请求或响应异常\n$route\n${onError.type}"));
          }
        } else {
          BotToast.showNotification(title: (_) => Text("err:请求或响应异常\n$route\n$onError"));
          print(onError);
        }
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
