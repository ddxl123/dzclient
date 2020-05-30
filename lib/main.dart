import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/CheckNetwork.dart';
import 'package:dzclient/bi/SP.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:dzclient/home/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  // debugPaintSizeEnabled = true;
  runApp(MyApp());
  init();
}

void init() {
  CheckNetwork.initInMain();
  SendRequest.initInMain();
  SP.initInMain();
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return BotToastInit(
      child: MaterialApp(
        // navigatorKey: MK._navigatorKey,
        initialRoute: "/",
        routes: {
          "/": (_) => HomePage(),
        },
        navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}

class TestDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestDemo();
  }
}

class _TestDemo extends State<TestDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: LayoutBuilder(
          builder: (_, constraint) {
            return Container(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: <Widget>[
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BBB extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BBB();
  }
}

class _BBB extends State<BBB> {
  @override
  void initState() {
    super.initState();
    print("init");
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Text("data");
  }
}
