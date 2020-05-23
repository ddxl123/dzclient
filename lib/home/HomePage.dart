import 'dart:ui';
import 'package:dzclient/dz_card/BuildDZ.dart';
import 'package:dzclient/dz_card/CreateDZPage.dart';
import 'package:dzclient/home/HomePageProvider.dart';
import 'package:dzclient/person/LeftDrawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomePageProvider>(create: (_) => HomePageProvider()),
      ],
      child: HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageContent();
  }
}

class _HomePageContent extends State<HomePageContent> {
  List _item1 = [Colors.orange];
  List _item2 = ["最新", Colors.black];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Text("write"),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => CreateDZPage()));
        },
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (_) {
            return IconButton(
              icon: Icon(Icons.fiber_manual_record),
              onPressed: () {
                Scaffold.of(_).openDrawer();
              },
            );
          },
        ),
        actions: <Widget>[
          toShowMenu(),
        ],
      ),
      body: BuildDZ(),
    );
  }

  Widget toShowMenu() {
    HomePageProvider _homePageProvider = Provider.of<HomePageProvider>(context, listen: false);
    return FlatButton(
      child: Selector(
        builder: (_, String value, ___) {
          return Text(value);
        },
        selector: (_, HomePageProvider provider) {
          return provider.sortMethod;
        },
      ),
      onPressed: () {
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(1, MediaQuery.of(context).padding.top, 0, 0),
          items: <PopupMenuEntry>[
            PopupMenuItem(child: Text("排序"), enabled: false),
            PopupMenuItem(child: Text("随机", style: TextStyle(color: _item1[0])), value: "1"),
            PopupMenuItem(child: Text(_item2[0], style: TextStyle(color: _item2[1])), value: "2"),
          ],
        ).then((onValue) {
          switch (onValue) {
            case "1":
              _item1[0] = Colors.orange;
              _item2 = ["最新", Colors.black];
              _homePageProvider.sortMethod = "随机";
              _homePageProvider.scrollController.jumpTo(-150);
              break;
            case "2":
              _item1[0] = Colors.black;
              _item2 = ["最新", Colors.orange];
              _homePageProvider.sortMethod = "最新";
              _homePageProvider.scrollController.jumpTo(-150);
              break;
          }
        });
      },
    );
  }
}
