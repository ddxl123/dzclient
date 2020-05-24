import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/CodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:dzclient/handles/UserIcons.dart';
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

class _DZPage extends State<DZPage> {
  Map _data = {};

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
      route: RouteName.noIdRoutes.dzPage.enterDz,
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
        return DzContentBuilder(data: _data);
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
}

///
///
///
///
///
///
///
///
///
///
class DzContentBuilder extends StatefulWidget {
  DzContentBuilder({this.data});
  // widget.data不会为null,因为已经有默认值{}了
  final Map data;
  @override
  State<StatefulWidget> createState() {
    return _DzContentBuilder();
  }
}

class _DzContentBuilder extends State<DzContentBuilder> {
  TextEditingController _textEditingController = TextEditingController();
  RefreshController _refreshController = RefreshController();

  List<Function(bool)> _hasPullUpFunc = [(bool) {}];
  List<Function(bool)> _hasSortButtonFunc = [(bool) {}];
  List<Function(bool)> _hasFailPromptFunc = [(bool) {}];

  GlobalKey<_AllListBuilderSliver> _allListBuilderSliverGlobalKey = GlobalKey<_AllListBuilderSliver>();

  @override
  void dispose() {
    _refreshController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return Scaffold(
      appBar: _appBar(),
      body: _allBody(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  void initData() {
    widget.data["dz_id"] ??= "获取失败";
    widget.data["username"] ??= "获取失败";
    widget.data["user_icon"] ??= 0;
    widget.data["title"] ??= "获取失败";
    widget.data["content"] ??= "获取失败";
    widget.data["update_time"] ??= 0;
    widget.data["star_count"] ??= 0;
    widget.data["like_count"] ??= 0;
    widget.data["review_count"] ??= 0;
  }

  ///TODO: 点击后会报错
  Widget _bottomNavigationBar() {
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
                    speakToWho: "???",
                    onSend: () {
                      SendRequest.request(
                        context: context,
                        method: "POST",
                        data: {
                          //给谁评论
                          "dz_id": "???",
                          "content": _textEditingController.value.text,
                        },
                        route: RouteName.needIdRoutes.dzPage.sendReview,
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

  Widget _appBar() {
    return AppBar(
      title: GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            UserIcons.getUserIconWidget(widget.data["user_icon"]),
            Text(widget.data["username"]),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _allBody() {
    return SmartRefresher(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: _footer(),
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
          ///dz内容
          _dzContentSliver(),

          ///list导航栏
          _centerBarSliver(),

          ///失败提示栏
          _failPromptSliver(),

          ///sort栏
          _sortButtonSliver(),

          ///AllListBuilder
          _allListBuilderSliver(
            hasPullUpFunc: _hasPullUpFunc,
            hasSortButtonFunc: _hasSortButtonFunc,
            hasFailPromptFunc: _hasFailPromptFunc,
          )
        ],
      ),
    );
  }

  Widget _footer() {
    ///默认值false
    bool _hasPullUp = false;
    return CustomFooter(
      loadStyle: LoadStyle.ShowWhenLoading,
      builder: (_, LoadStatus loadStatus) {
        Widget _pullUpTrueWidget;
        Widget _pullUpWidget;
        if (loadStatus == LoadStatus.idle) {
          _pullUpTrueWidget = Text("上拉加载");
        } else if (loadStatus == LoadStatus.loading) {
          _pullUpTrueWidget = CircularProgressIndicator();
        } else if (loadStatus == LoadStatus.failed) {
          _pullUpTrueWidget = Text("加载失败！点击重试！");
        } else if (loadStatus == LoadStatus.canLoading) {
          _pullUpTrueWidget = Text("松手,加载更多!");
        } else {
          _pullUpTrueWidget = Text("没有更多数据了!");
        }

        return StatefulBuilder(
          builder: (_, _footerRebuild) {
            _hasPullUpFunc[0] = (bool hasPU) {
              _hasPullUp = hasPU;
              _footerRebuild(() {});
            };
            if (_hasPullUp == true) {
              _pullUpWidget = _pullUpTrueWidget;
            } else {
              _pullUpWidget = Container();
              //写上这一句，防止在false的时候出现空占位
              _refreshController.loadComplete();
            }
            return Container(
              child: Center(
                child: _pullUpWidget,
              ),
            );
          },
        );
      },
    );
  }

  ///dz内容
  Widget _dzContentSliver() {
    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          //标题
          Container(
            padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.data["title"],
              style: TextStyle(fontSize: 18),
            ),
          ),
          //内容
          Container(
            padding: EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.data["content"],
              style: TextStyle(fontSize: 14, height: 1.8),
            ),
          ),
          //时间栏
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Text(
              "发布于 " + widget.data["update_time"].toString(),
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

  ///centerBar
  Widget _centerBarSliver() {
    return SliverAppBar(
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
            child: Text(
              "收藏 · " + (widget.data["star_count"] > 99 ? "99+" : widget.data["star_count"].toString()),
              style: TextStyle(fontSize: 15),
            ),
          ),
          onTap: () {
            _allListBuilderSliverGlobalKey.currentState.toTab(0);
          },
        ),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              "评论 · " + (widget.data["review_count"] > 99 ? "99+" : widget.data["review_count"].toString()),
              style: TextStyle(fontSize: 15),
            ),
          ),
          onTap: () {
            _allListBuilderSliverGlobalKey.currentState.toTab(1);
          },
        ),
        Expanded(child: Container()),
        GestureDetector(
          child: Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              "喜欢 · " + (widget.data["like_count"] > 99 ? "99+" : widget.data["like_count"].toString()),
              style: TextStyle(fontSize: 15),
            ),
          ),
          onTap: () {
            _allListBuilderSliverGlobalKey.currentState.toTab(2);
          },
        ),
      ],
    );
  }

  ///失败提示栏
  Widget _failPromptSliver() {
    ///默认值false
    bool _hasFailPrompt = false;
    return SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (_, failPromptRebuild) {
          _hasFailPromptFunc[0] = (bool hasFP) {
            _hasFailPrompt = hasFP;
            failPromptRebuild(() {});
          };
          if (_hasFailPrompt == false) {
            return Container();
          }
          return Text("失败");
        },
      ),
    );
  }

  ///sort栏
  Widget _sortButtonSliver() {
    ///默认值false
    bool _hasSortButton = false;
    return SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (adapterContext, adapterRebuild) {
          _hasSortButtonFunc[0] = (bool hasSB) {
            _hasSortButton = hasSB;
            adapterRebuild(() {});
          };
          if (_hasSortButton == false) {
            return Container();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              StatefulBuilder(
                builder: (sortButtonContext, sortButtonRebuild) {
                  return BButton(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text("最新", style: TextStyle(color: Colors.blue)),
                    ),
                    onTap: () {
                      showMenu(
                        context: sortButtonContext,
                        position: RelativeRect.fromLTRB(
                          1,
                          (sortButtonContext.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy,
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
          );
        },
      ),
    );
  }

  //AllListBuilder
  Widget _allListBuilderSliver({
    @required List<Function(bool)> hasPullUpFunc,
    @required List<Function(bool)> hasSortButtonFunc,
    @required List<Function(bool)> hasFailPromptFunc,
  }) {
    return AllListBuilderSliver(
      hasPullUpFunc: hasPullUpFunc,
      hasSortButtonFunc: hasSortButtonFunc,
      hasFailPromptFunc: hasFailPromptFunc,
      key: _allListBuilderSliverGlobalKey,
    );
  }
}

///
///
///
///
///
///
///
///
///
///
class AllListBuilderSliver extends StatefulWidget {
  AllListBuilderSliver({
    @required this.hasPullUpFunc,
    @required this.hasSortButtonFunc,
    @required this.hasFailPromptFunc,
    @required Key key,
  }) : super(key: key);
  final List<Function(bool)> hasPullUpFunc;
  final List<Function(bool)> hasSortButtonFunc;
  final List<Function(bool)> hasFailPromptFunc;
  @override
  State<StatefulWidget> createState() {
    return _AllListBuilderSliver();
  }
}

class _AllListBuilderSliver extends State<AllListBuilderSliver> {
  int _tabIndex = 1;
  void toTab(int index) {
    _tabIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future(),
      builder: _builder,
    );
  }

  ///失败返回false，成功则返回其数据
  Future _future() {
    if (_tabIndex == 1) {
      return SendRequest.request(
        context: context,
        method: "GET",
        route: null,
        responseValue: (code, response) {},
      );
    }
  }

  Widget _builder(_, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        _futureWaiting();
        return SliverToBoxAdapter(
          child: Column(
            children: <Widget>[
              CircularProgressIndicator(),
              Text("加载中..."),
            ],
          ),
        );
        break;
      case ConnectionState.done:
        if (snapshot.data == false) {
          _futureFail();
        } else {
          _futureSuccess();
        }
        return ReviewBuilder();
      default:
        print("default");
        _futureFail();
        return SliverToBoxAdapter(
          child: Container(),
        );
    }
  }

  void _futureWaiting() {
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((timeStamp) {
      widget.hasPullUpFunc[0](false);
      widget.hasSortButtonFunc[0](false);
      widget.hasFailPromptFunc[0](false);
    });
  }

  void _futureSuccess() {
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((timeStamp) {
      if (_tabIndex == 0) {
        widget.hasPullUpFunc[0](true);
        widget.hasSortButtonFunc[0](false);
        widget.hasFailPromptFunc[0](false);
      } else if (_tabIndex == 2) {
        widget.hasPullUpFunc[0](true);
        widget.hasSortButtonFunc[0](false);
        widget.hasFailPromptFunc[0](false);
      } else {
        widget.hasPullUpFunc[0](true);
        widget.hasSortButtonFunc[0](true);
        widget.hasFailPromptFunc[0](false);
      }
    });
  }

  void _futureFail() {
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((timeStamp) {
      widget.hasPullUpFunc[0](false);
      widget.hasSortButtonFunc[0](false);
      widget.hasFailPromptFunc[0](true);
    });
  }
}

class ReviewBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReviewBuilder();
  }
}

class _ReviewBuilder extends State<ReviewBuilder> {
  //防止同时触发父组件的onPanDown事件
  bool _isChildOnPanDown = false;
  Color _mainc = Colors.white;
  Color _bc1;
  Color _bc2;

  @override
  Widget build(BuildContext context) {
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
}
