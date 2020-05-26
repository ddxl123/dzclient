import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/SP.dart';
import 'package:dzclient/person/LoginPage.dart';
import 'package:flutter/material.dart';

void codeHandles({
  @required BuildContext context,
  @required String code,
  @required List<bool> handles,
  @required Function otherCodeHandle,
}) {
  if (!handles.contains(true)) {
    otherCodeHandle();
    if (code == "2001" || code == "2002" || code == "2003") {
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
          "数据库丢失该 @XXX 用户$code，请记住您的用户名，并及时联系管理员!\n\n已自动复制您的用户名。",
        ),
      );
    } else {
      BotToast.showNotification(title: (_) => Text("未知code:$code"));
    }
  }
}

bool codeHandle(String code, List<String> codes, Function() callback) {
  if (codes.contains(code)) {
    callback();
    return true;
  } else {
    return false;
  }
}
