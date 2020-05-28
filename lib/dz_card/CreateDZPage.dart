import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/ResponseCodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:flutter/material.dart';

class CreateDZPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateDZPage();
  }
}

class _CreateDZPage extends State<CreateDZPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //下拉栏占位
          Container(
            height: MediaQueryData.fromWindow(window).padding.top,
            color: Colors.yellow,
          ),
          top(),
          body(),
          Text("底部底部底部底部底部底部底部底部底部底部"),
        ],
      ),
    );
  }

  Widget top() {
    return Container(
      color: Colors.yellow,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              boxShadow: <BoxShadow>[
                BoxShadow(offset: Offset(0, 5), blurRadius: 5, spreadRadius: -5),
              ],
            ),
            child: Row(
              children: <Widget>[
                Theme(
                  data: ThemeData(
                    buttonTheme: ButtonThemeData(
                      minWidth: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  child: FlatButton(
                    child: Text("取消"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(child: Container()),
                Theme(
                  data: ThemeData(
                    buttonTheme: ButtonThemeData(
                      minWidth: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  child: FlatButton(
                    child: Text("发布"),
                    onPressed: () {
                      publish();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void publish() {
    showDialog(
      context: context,
      child: AlertDialog(
        content: Text("确认发布？"),
        actions: <Widget>[
          FlatButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("确认", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              SendRequest.request(
                method: "POST",
                context: context,
                route: RouteName.needIdRoutes.createDzPage.createDz,
                data: {
                  "title": _titleController.text,
                  "content": _contentController.text,
                },
                toCodeHandles: (code, response) {
                  return [
                    codeHandles(code, ["4001", "4002"], () {
                      BotToast.showNotification(title: (_) => Text("服务器端异常$code,请联系管理员!"));
                    }),
                    codeHandles(code, ["4003"], () {
                      BotToast.showNotification(title: (_) => Text("发布成功"));
                      Navigator.pop(context);
                    }),
                  ];
                },
                toOtherCodeHandles: () {},
                bindLine: "CreateDZPage",
                isLoading: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget body() {
    return //使用ListView必须有宽高，添加Expanded是为了自动计算宽高
        Expanded(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: "输入标题",
              hintStyle: TextStyle(fontWeight: FontWeight.bold),
              contentPadding: EdgeInsets.all(10),
            ),
            style: TextStyle(fontWeight: FontWeight.w600),
            minLines: 1,
            maxLines: 3,
            maxLength: 50,
          ),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              hintText: "输入内容",
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            ),
            style: TextStyle(fontSize: 14, height: 1.5),
            maxLines: null,
            scrollPhysics: NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }
}
