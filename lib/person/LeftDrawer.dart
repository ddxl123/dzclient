import 'dart:convert';
import 'package:dzclient/bi/SP.dart';
import 'package:dzclient/person/LoginPage.dart';
import 'package:flutter/material.dart';

class LeftDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LeftDrawer();
  }
}

class _LeftDrawer extends State<LeftDrawer> {
  @override
  Widget build(BuildContext context) {
    if (SP.sp.getString("token") == null) {
      return showLoginPage(context, isWidget: true);
    }
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {},
                    child: Icon(
                      jsonDecode(SP.sp.getString("user_info") ?? "{}")["user_icon"] == 0 ? Icons.ac_unit : Icons.access_alarm,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text(jsonDecode(SP.sp.getString("user_info") ?? "{}")["username"] ?? "?"),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 150,
                      child: Text("我的中心"),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 150,
                      child: Text("联系客服"),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 150,
                      child: Text("修改密码"),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: 150,
                      child: Text("退出登陆"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
