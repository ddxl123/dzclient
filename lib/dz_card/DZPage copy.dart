import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/CodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:dzclient/tools/BButton.dart';
import 'package:dzclient/tools/ShowReview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DZPage extends StatefulWidget {
  DZPage(this.dzId);
  final String dzId;

  @override
  State<StatefulWidget> createState() {
    return _DZPage();
  }
}

//加载模块
class _DZPage extends State<DZPage> {
  Map<dynamic, dynamic> _data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _future(),
        builder: _builder,
      ),
    );
  }

  Future _future() {
    return SendRequest.request(
      context: context,
      method: "GET",
      route: RouteName.enterDZ,
      query: {
        "dz_id": widget.dzId,
      },
      responseValue: (code, response) {
        codeHandles(
          code,
          [
            codeHandle(code, ["6001", "6003"], () {
              BotToast.showNotification(title: (_) => Text("服务端异常:$code"));
            }),
            codeHandle(code, ["6002"], () {
              _data = response.data["data"];
            }),
          ],
        );
      },
    );
  }

  Widget _builder(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text("加载中..."),
              ],
            ),
          ),
        );
        break;
      case ConnectionState.done:
        initData();
        return DZPageContent(_data);
        break;
      default:
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Text("异常snapshot，请重新尝试"),
          ),
        );
    }
  }

  void initData() {
    print(_data);
    _data["dz_id"] ??= "";
    _data["username"] ??= "获取失败";
    if (_data["user_icon"] == null) {
      _data["user_icon"] = -1;
      switch (_data["user_icon"]) {
        case 0:
          _data["user_icon"] = Icon(Icons.assistant_photo);
          break;
        default:
          _data["user_icon"] = Icon(Icons.ac_unit);
      }
    } else if (_data["user_icon"].runtimeType == int) {
      switch (_data["user_icon"]) {
        case 0:
          _data["user_icon"] = Icon(Icons.assistant_photo);
          break;
        default:
          _data["user_icon"] = Icon(Icons.ac_unit);
      }
    } else {}
    _data["title"] ??= "获取失败";
    _data["content"] ??= "获取失败";
    _data["create_time"] ??= "-1";
    _data["update_time"] ??= "-1";
  }
}

class DZPageContent extends StatefulWidget {
  DZPageContent(this._data);
  final Map _data;
  @override
  State<StatefulWidget> createState() {
    return _DZPageContent();
  }
}

class _DZPageContent extends State<DZPageContent> with TickerProviderStateMixin {
  TextEditingController _textEditingController = TextEditingController();
  RefreshController _refreshController = RefreshController();
  int _initIndex = 1;
  //防止同时触发父组件的onPanDown事件
  bool _isChildOnPanDown = false;
  Color _mainc = Colors.white;
  Color _bc1;
  Color _bc2;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget._data["user_icon"],
              Text(widget._data["username"]),
            ],
          ),
          onTap: () {},
        ),
      ),
      body: SmartRefresher(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: ClassicFooter(),
        controller: _refreshController,
        onRefresh: () {
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await Future.delayed(Duration(seconds: 1));
          _refreshController.loadComplete();
        },
        child: CustomScrollView(
          slivers: <Widget>[
            FutureBuilder(
              future: Future.delayed(Duration(seconds: 2)),
              builder: (_, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return SliverToBoxAdapter(child: Text("加载中..."));
                    break;
                  case ConnectionState.active:
                    return SliverToBoxAdapter(child: Text("加载中..."));
                    break;
                  case ConnectionState.done:
                    return body();
                    break;
                  default:
                    return SliverToBoxAdapter(child: Text("加载中..."));
                }
              },
            ),
            //评论导航栏
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              snap: true,
              floating: true,
              centerTitle: true,
              actions: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("收藏 · 99+", style: TextStyle(fontSize: 15)),
                  ),
                  onTap: () {
                    _initIndex = 1;
                    setState(() {});
                  },
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("评论 · 99+", style: TextStyle(fontSize: 15)),
                  ),
                  onTap: () {
                    _initIndex = 2;
                    setState(() {});
                  },
                ),
                Expanded(child: Container()),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text("喜欢 · 99+", style: TextStyle(fontSize: 15)),
                  ),
                  onTap: () {
                    _initIndex = 3;
                    setState(() {});
                  },
                ),
              ],
            ),
            builderUp(),
            builderBody(),
          ],
        ),
      ),
      bottomNavigationBar: bottom(),
    );
  }

  Widget body() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          //标题
          Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            alignment: Alignment.centerLeft,
            child: Text(
              widget._data["title"],
              style: TextStyle(fontSize: 18),
            ),
          ),
          //内容
          Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            child: Text(
              "https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsw.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1https://www.baidu.com/s?wd=LayoutBuilder&rsv_spt=1&rsv_iqid=0xf822407c00061324&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&tn=baiduhome_pg&rsv_enter=1&rsv_dl=tb&rsv_sug3=14&rsv_sug1=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=v_sug4=12812=9&rsv_sug7=101&rsv_sug2=0&rsv_btype=i&inputT=10074&rsv_sug4=12812",
              style: TextStyle(fontSize: 14, height: 1.8),
            ),
          ),
          //时间栏
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              "发布于 ${widget._data["update_time"]}",
              style: TextStyle(
                fontSize: 12,
                height: 2,
                color: Colors.grey[600],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget builderUp() {
    if (_initIndex == 2) {
      return SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            StatefulBuilder(
              builder: (_, rebuild) {
                return BButton(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Text("最新", style: TextStyle(color: Colors.blue)),
                  ),
                  onTap: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        1,
                        (_.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy,
                        0,
                        0,
                      ),
                      items: <PopupMenuEntry<dynamic>>[
                        PopupMenuItem(
                          value: 0,
                          enabled: false,
                          child: Text("排序"),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Text("最新", style: TextStyle(color: Colors.blue)),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text("热度", style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ).then((value) {
                      switch (value) {
                        case 1:
                          break;
                        case 2:
                          break;
                        default:
                      }
                    });
                  },
                );
              },
            ),
          ],
        ),
      );
    } else {
      return SliverToBoxAdapter();
    }
  }

  Widget builderBody() {
    if (_initIndex == 0) {
      return index0();
    } else if (_initIndex == 1) {
      return index1();
    } else if (_initIndex == 2) {
      return index2();
    } else if (_initIndex == 3) {
      return index3();
    } else {
      return index2();
    }
  }

  Widget index0() {
    return CircularProgressIndicator();
  }

  Widget index1() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          return Text("00000000000000000");
        },
        childCount: 80,
      ),
    );
  }

  Widget index2() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          return StatefulBuilder(
            builder: (_, rebuild) {
              return GestureDetector(
                onPanDown: (_) {
                  if (!_isChildOnPanDown) {
                    _mainc = Colors.grey[300];
                    rebuild(() {});
                  }
                },
                onPanCancel: () {
                  _mainc = Colors.white;
                  rebuild(() {});
                },
                onPanEnd: (_) {
                  _mainc = Colors.white;
                  rebuild(() {});
                },
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: _mainc,
                    border: Border(bottom: BorderSide(color: Colors.blue[100], width: 0.5)),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.ac_unit,
                            color: Colors.blue,
                            size: 26,
                          ),
                          SizedBox(width: 10),
                          //这里必须是Expanded
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      "更多Greg",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Expanded(child: Container()),
                                  ],
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "大赛分为公尺反反馈d大赛分为公尺上帝发布微博反反反反反馈d大赛分为公尺上帝发布微博反反反反反馈d大赛分为公尺上帝发布微博反反反反反馈d大赛分为公尺上帝发布微博反反反反反馈d.反反反馈d.反反反馈d.反反反馈d.",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          height: 1.6,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " 10:30",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.grey[100],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        child: StatefulBuilder(
                                          builder: (_, rebuildIn) {
                                            return RichText(
                                              text: TextSpan(
                                                children: <InlineSpan>[
                                                  WidgetSpan(
                                                    child: GestureDetector(
                                                      child: Text(
                                                        "aaaaaa",
                                                        style: TextStyle(color: Colors.blue, backgroundColor: _bc1),
                                                      ),
                                                      onPanDown: (_) {
                                                        _bc1 = Colors.grey[300];
                                                        rebuildIn(() {});
                                                        _isChildOnPanDown = true;
                                                      },
                                                      onPanCancel: () {
                                                        _bc1 = null;
                                                        rebuildIn(() {});
                                                        _isChildOnPanDown = false;
                                                      },
                                                      onPanEnd: (_) {
                                                        _bc1 = null;
                                                        rebuildIn(() {});
                                                        _isChildOnPanDown = false;
                                                      },
                                                      onTap: () {
                                                        //TODO: 跳转到对方个人中心
                                                      },
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ":" + "vvvvv",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                        child: StatefulBuilder(
                                          builder: (_, rebuildIn) {
                                            return RichText(
                                              text: TextSpan(
                                                children: <InlineSpan>[
                                                  WidgetSpan(
                                                    child: GestureDetector(
                                                      child: Text(
                                                        "bbbbbb",
                                                        style: TextStyle(color: Colors.blue, backgroundColor: _bc2),
                                                      ),
                                                      onPanDown: (_) {
                                                        _bc2 = Colors.grey[300];
                                                        rebuildIn(() {});
                                                        _isChildOnPanDown = true;
                                                      },
                                                      onPanCancel: () {
                                                        _bc2 = null;
                                                        rebuildIn(() {});
                                                        _isChildOnPanDown = false;
                                                      },
                                                      onPanEnd: (_) {
                                                        _bc2 = null;
                                                        rebuildIn(() {});
                                                        _isChildOnPanDown = false;
                                                      },
                                                      onTap: () {
                                                        //TODO: 跳转到对方个人中心
                                                      },
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ": ",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            children: <Widget>[
                              SizedBox(height: 20),
                              Icon(
                                Icons.thumb_up,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              Text(
                                "99+",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        childCount: 10,
      ),
    );
  }

  Widget index3() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          return Text("2222222222222222");
        },
        childCount: 10,
      ),
    );
  }

  Widget bottom() {
    return Container(
      color: Colors.blue,
      child: Row(
        children: <Widget>[
          //收藏按钮
          Expanded(
            child: FlatButton(
              onPressed: () {},
              child: Icon(Icons.star_border),
            ),
          ),
          //评论按钮
          Expanded(
            child: FlatButton(
                child: Icon(Icons.comment),
                onPressed: () {
                  showReview(
                    context: context,
                    textEditingController: _textEditingController,
                    speakToWho: widget._data["username"],
                    onSend: () {
                      SendRequest.request(
                        context: context,
                        method: "POST",
                        data: {
                          "dz_id": widget._data["dz_id"],
                          "content": _textEditingController.value.text,
                        },
                        route: RouteName.sendReview,
                        responseValue: (code, response) {
                          codeHandles(
                            code,
                            [
                              codeHandle(code, ["7001", "7002"], () {
                                BotToast.showNotification(title: (_) => Text("服务端错误,请重试,或联系管理员$code"));
                              }),
                              codeHandle(code, ["7003"], () {
                                BotToast.showNotification(title: (_) => Text("发表成功"));
                                Navigator.of(context).pop();
                              }),
                            ],
                          );
                        },
                        isLoading: true,
                      );
                    },
                  );
                }),
          ),
          //赞同按钮
          Expanded(
            child: FlatButton(
              onPressed: () {},
              child: Icon(Icons.favorite_border),
            ),
          ),
        ],
      ),
    );
  }
}
