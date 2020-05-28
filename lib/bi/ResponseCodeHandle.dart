import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:dzclient/bi/SP.dart';
import 'package:dzclient/person/LoginPage.dart';
import 'package:flutter/material.dart';

bool codeHandles(String code, List<String> codes, Function() callback) {
  if (codes.contains(code)) {
    callback();
    return true;
  } else {
    return false;
  }
}

Function otherCodeHandles({
  @required String code,
  @required BuildContext context,
  @required dynamic onError,
  @required String route,
}) {
  ///异常捕获问题
  return () {
    if (code == "0") {
      BotToast.showNotification(title: (_) => Text("err:网络连接异常\n$route"));
    } else if (code == "1") {
      BotToast.showNotification(title: (_) => Text("请求过于频繁\n$route"));
    } else if (code == "2") {
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
    }

    ///未登陆code问题
    else if (code == "2001" || code == "2002" || code == "2003") {
      if (SP.sp.getString("token") == null) {
        BotToast.showNotification(title: (_) => Text("请先登陆"));
        showLoginPage(context);
      } else {
        BotToast.showNotification(title: (_) => Text("登陆已过期，请重新登陆$code"));
        showLoginPage(context);
      }
    } else if (code == "2004") {
      BotToast.showNotification(title: (_) => Text("服务器端异常，请重试$code"));
    } else if (code == "2005") {
      BotToast.showNotification(
        //TODO: 这里要将用户名存储本地，然后在这里获取
        title: (_) => Text(
          "数据库丢失该 @XXX 用户$code，请记住您的用户名，并及时联系管理员!\n\n已自动复制您的用户名。\n$route",
        ),
      );
    }

    ///
    else if (code == null) {
      BotToast.showNotification(title: (_) => Text("err:code为null\n$route"));
    }

    ///
    else {
      BotToast.showNotification(title: (_) => Text("未知code:$code\n$route"));
    }
  };
}

void responseCodeHandles({
  @required List<bool> toCodeHandles,
  @required Function toOtherCodeHandles,
  @required Function otherCodeHandles,
}) {
  if (!toCodeHandles.contains(true)) {
    toOtherCodeHandles();
    otherCodeHandles();
  }
}
