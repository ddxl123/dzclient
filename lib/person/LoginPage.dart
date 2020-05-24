import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:dzclient/bi/CodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SP.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:flutter/material.dart';

String usernameValue = "";
String passwordValue = "";

Widget showLoginPage(BuildContext context, {bool isWidget}) {
  if (isWidget == true) {
    return Builder(
      builder: (loginContext) {
        return loginMian(loginContext);
      },
    );
  }
  showDialog(
    context: context,
    builder: (loginContext) {
      return loginMian(loginContext);
    },
  );
  return null;
}

Widget loginMian(loginContext) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      Navigator.pop(loginContext);
    },
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: loginTypesetting(loginContext),
    ),
  );
}

Widget loginTypesetting(loginContext) {
  return Container(
    //让整体居中
    alignment: Alignment.center,
    child: GestureDetector(
      onTap: () {},
      child: Container(
        //内容背景
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          //内容:当前默认上下居中对齐，左右居中对齐
          mainAxisSize: MainAxisSize.min,
          children: loginContent(loginContext),
        ),
      ),
    ),
  );
}

List<Widget> loginContent(loginContext) {
  return <Widget>[
    //使用Column进行包裹且CrossAxisAlignment.start，可将Column的内容进行靠左对齐
    Text("您需要先登陆"),
    SizedBox(height: 10),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 150,
              color: Colors.white,
              child: TextField(
                onChanged: (value) {
                  usernameValue = value;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
                  isDense: true,
                  contentPadding: EdgeInsets.all(1),
                  hintText: "用户名",
                  suffix: Theme(
                    data: ThemeData(
                      buttonTheme: ButtonThemeData(
                        height: 0,
                        minWidth: 0,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    child: FlatButton(
                      onPressed: () {},
                      child: Text("随机"),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2),
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: 150,
          color: Colors.white,
          child: TextField(
            onChanged: (value) {
              passwordValue = value;
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(1),
              border: OutlineInputBorder(borderSide: BorderSide(width: 2)),
              hintText: "密码",
            ),
          ),
        ),
      ],
    ),
    SizedBox(height: 5),
    Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Theme(
          data: ThemeData(
            buttonTheme: ButtonThemeData(
              height: 0,
              minWidth: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          child: FlatButton(
            child: Text("登陆"),
            onPressed: () {
              //TODO: 先检验用户名和密码的合法性
              SendRequest.request(
                method: "POST",
                context: loginContext,
                route: RouteName.mainRoutes.login,
                data: {
                  "username": usernameValue,
                  "password": passwordValue,
                },
                responseValue: (code, responseData) {
                  handleLoginResponse(loginContext, code, responseData);
                },
                isLoading: true,
              );
            },
          ),
        ),
        Theme(
          data: ThemeData(
            buttonTheme: ButtonThemeData(
              height: 0,
              minWidth: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          child: FlatButton(
            child: Text("注册"),
            onPressed: () {
              //TODO: 先检验用户名和密码的合法性
              SendRequest.request(
                method: "POST",
                context: loginContext,
                route: RouteName.mainRoutes.register,
                data: {
                  "username": usernameValue,
                  "password": passwordValue,
                },
                responseValue: (code, responseData) {
                  handleRegisterResponse(loginContext, code, responseData);
                },
                isLoading: true,
              );
            },
          ),
        ),
      ],
    )
  ];
}

void handleLoginResponse(BuildContext loginContext, String code, Response<dynamic> responseData) {
  codeHandles(
    code,
    [
      codeHandle(code, ["1001", "1002", "1003", "1005", "1006"], () {
        BotToast.showNotification(title: (_) => Text("服务器端错误$code，请联系管理员"));
      }),
      codeHandle(code, ["1004"], () {
        BotToast.showNotification(title: (_) => Text("该用户未被注册过"));
      }),
      codeHandle(code, ["1007"], () {
        toSetTokenLocal(loginContext, responseData, true);
      }),
      codeHandle(code, ["1008"], () {
        BotToast.showNotification(title: (_) => Text("密码错误"));
      }),
      codeHandle(code, ["1009"], () {
        BotToast.showNotification(title: (_) => Text("数据库存在重复的用户账号$code，请联系管理员"));
      }),
    ],
  );
}

void handleRegisterResponse(BuildContext loginContext, String code, Response<dynamic> responseData) {
  codeHandles(
    code,
    [
      codeHandle(code, ["3001", "3002", "3003", "3004"], () {
        BotToast.showNotification(title: (_) => Text("服务器端错误$code，请联系管理员"));
      }),
      codeHandle(code, ["3005", "3006"], () {
        BotToast.showNotification(title: (_) => Text("注册成功，但登陆失败$code"));
      }),
      codeHandle(code, ["3007"], () {
        toSetTokenLocal(loginContext, responseData, false);
      }),
      codeHandle(code, ["3008"], () {
        BotToast.showNotification(title: (_) => Text("该用户已存在"));
      }),
      codeHandle(code, ["3009"], () {
        BotToast.showNotification(title: (_) => Text("数据库存在重复的用户账号$code，请联系管理员"));
      })
    ],
  );
}

void toSetTokenLocal(BuildContext context, Response<dynamic> responseData, bool isLogin) {
  SP.sp.setString("token", responseData.headers["token"][0].toString()).then((onValue) {
    Navigator.pop(context);
    BotToast.showNotification(title: (_) => Text(isLogin ? "登陆成功" : "注册成功"));
  }).catchError((onError) {
    BotToast.showNotification(title: (_) => Text(isLogin ? "登陆失败" : "注册失败"));
  });
}
