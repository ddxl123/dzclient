import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

void codeHandles(String code, List<bool> handles, {Function() elseHandle}) {
  if (!handles.contains(true)) {
    if (elseHandle == null) {
      BotToast.showNotification(title: (_) => Text("未知code:$code"));
    } else {
      elseHandle();
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
