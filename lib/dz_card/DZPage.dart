import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/ResponseCodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:dzclient/handles/UserIcons.dart';
import 'package:dzclient/tools/ShowReview.dart';
import 'package:flutter/material.dart';
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
  Map _dzContentData = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future(),
      builder: _builder,
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
      toCodeHandles: (code, response) {
        return [
          codeHandles(code, ["6001", "6003"], () {
            BotToast.showNotification(title: (_) => Text("服务端异常:$code"));
          }),
          codeHandles(code, ["6002"], () {
            _dzContentData = response.data["data"];
          }),
        ];
      },
      toOtherCodeHandles: () {},
      bindLine: "DzContent",
      isLoading: false,
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
        return StatefulBuilder(
          builder: (_, rebuild) {
            initDzContentData();
            return DzContentBuilder(
              dzContentData: _dzContentData,
              reloadDzContent: () async {
                await _future();
                rebuild(() {});
              },
            );
          },
        );
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

  void initDzContentData() {
    _dzContentData["dz_id"] ??= "获取失败";
    _dzContentData["username"] ??= "获取失败";
    _dzContentData["user_icon"] ??= 0;
    _dzContentData["title"] ??= "获取失败";
    _dzContentData["content"] ??= "获取失败";
    _dzContentData["update_time"] ??= 0;
  }
}

class DzContentBuilder extends StatefulWidget {
  DzContentBuilder({this.dzContentData, this.reloadDzContent});
  // widget.data不会为null,因为已经有默认值{}了
  final Map dzContentData;
  //要用reloadDzContent替代当前类的setState，因为需要data重新初始化
  final Function reloadDzContent;

  @override
  State<StatefulWidget> createState() {
    return _DzContentBuilder();
  }
}

class _DzContentBuilder extends State<DzContentBuilder> {
  RefreshController _refreshController = RefreshController();
  TextEditingController _textEditingController = TextEditingController();

  double _bottomHeight = 40;

  ///必须默认为true
  bool _isMainEvent = true;

  ///
  bool _isShowModalBottomSheet = false;

  @override
  void dispose() {
    _refreshController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _appBar(),
      body: _allBody(),
      bottomSheet: _bottomNavigationBar(),
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      height: _bottomHeight,
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
                    speakToWho: widget.dzContentData["username"],
                    onSend: () {
                      SendRequest.request(
                        context: context,
                        method: "POST",
                        data: {
                          //给谁评论
                          "dz_id": widget.dzContentData["dz_id"],
                          "content": _textEditingController.value.text,
                        },
                        route: RouteName.needIdRoutes.dzPage.sendReview,
                        toCodeHandles: (code, response) {
                          return [
                            codeHandles(code, ["7001", "7002"], () {
                              BotToast.showNotification(title: (_) => Text("服务端错误,请重试,或联系管理员$code"));
                            }),
                            codeHandles(code, ["7003"], () {
                              BotToast.showNotification(title: (_) => Text("发表成功"));
                              Navigator.of(context).pop();
                            }),
                          ];
                        },
                        toOtherCodeHandles: () {},
                        isLoading: true,
                        bindLine: "SendReview",
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
            UserIcons.getUserIconWidget(widget.dzContentData["user_icon"]),
            Text(widget.dzContentData["username"]),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _allBody() {
    return SmartRefresher(
      physics: AlwaysScrollableScrollPhysics(),
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: CustomFooter(
        height: 100,
        loadStyle: LoadStyle.HideAlways,
        builder: (_, __) {
          return Text("");
        },
      ),
      controller: _refreshController,
      onRefresh: () async {
        await widget.reloadDzContent();
        _refreshController.refreshCompleted();
      },
      onOffsetChange: (up, offset) async {
        if (!up && offset > 80 && _isShowModalBottomSheet == false) {
          _isShowModalBottomSheet = true;
          await showModalBottomSheet(
            //这里必须要透明
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            context: context,
            builder: (_) {
              return Container(
                height: MediaQueryData.fromWindow(window).size.height - MediaQueryData.fromWindow(window).padding.top - kToolbarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      singleReview(),
                      singleReview(),
                      singleReview(),
                    ],
                  ),
                ),
              );
            },
          );
          _isShowModalBottomSheet = false;
        }
      },
      child: CustomScrollView(
        slivers: <Widget>[
          ///dz内容
          _dzContentSliver(),

          SliverToBoxAdapter(
            child: Center(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "上拉查看全部99条评论",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: Container(
                height: _bottomHeight,
                padding: EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///dz内容
  Widget _dzContentSliver() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            //标题
            Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.dzContentData["title"],
                style: TextStyle(fontSize: 18),
              ),
            ),
            //内容
            Container(
              padding: EdgeInsets.all(15),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.dzContentData["content"],
                style: TextStyle(fontSize: 14, height: 1.8),
              ),
            ),
            //时间栏
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              child: Text(
                "发布于 " + widget.dzContentData["update_time"].toString(),
                style: TextStyle(
                  fontSize: 12,
                  height: 2,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Container(
              color: Colors.grey[100],
              height: 10,
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text(
                "评论",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            singleReview(),
            singleReview(),
          ],
        ),
      ),
    );
  }

  Widget singleReview() {
    Color mainColor = Colors.white;

    return StatefulBuilder(
      builder: (_, rebuild) {
        return GestureDetector(
          onPanDown: (_) {
            if (_isMainEvent == true) {
              mainColor = Colors.grey[300];
              rebuild(() {});
            }
          },
          onPanCancel: () {
            if (_isMainEvent == true) {
              mainColor = Colors.white;
              rebuild(() {});
            }
          },
          onPanEnd: (_) {
            if (_isMainEvent == true) {
              mainColor = Colors.white;
              rebuild(() {});
            }
          },
          onTap: () {
            if (_isMainEvent == true) {}
          },
          child: Container(
            decoration: BoxDecoration(
              color: mainColor,
              border: Border(bottom: BorderSide(color: Colors.blue[100], width: 0.5)),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ///左
                    Icon(
                      Icons.ac_unit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    SizedBox(width: 10),

                    ///中
                    //这里必须是Expanded
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ///评论者姓名
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

                          ///评论内容
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
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          ///评论的评论
                          Container(
                            alignment: Alignment.centerLeft,
                            color: Colors.grey[100],
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                shortReview(),
                                shortReview(),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),

                          ///赞数
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ///评论时间
                              Text(
                                "10:30",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(child: Container()),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.thumb_up,
                                    color: Colors.grey[600],
                                  ),
                                  Text(
                                    " 9999",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 10),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.rate_review,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget shortReview() {
    Color nameColor;
    Color containerColor;

    ///必须默认为true
    bool isContainerEvent = true;

    return StatefulBuilder(
      builder: (_, rebuildIn) {
        return GestureDetector(
          //让margin的边缘也可点击
          behavior: HitTestBehavior.translucent,
          onPanDown: (_) {
            if (isContainerEvent == true) {
              containerColor = Colors.grey[300];
              _isMainEvent = false;
              rebuildIn(() {});
            }
          },
          onPanCancel: () {
            if (isContainerEvent == true) {
              containerColor = null;
              _isMainEvent = true;
              rebuildIn(() {});
            }
          },
          onPanEnd: (_) {
            if (isContainerEvent == true) {
              containerColor = null;
              _isMainEvent = true;
              rebuildIn(() {});
            }
          },
          onTap: () {
            //TODO: 跳转到对方个人中心
            if (isContainerEvent == true) {}
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            color: containerColor,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: <InlineSpan>[
                        WidgetSpan(
                          child: GestureDetector(
                            child: Container(
                              color: nameColor,
                              child: Text(
                                "aaad的撒大a",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            onPanDown: (_) {
                              nameColor = Colors.grey[300];
                              _isMainEvent = false;
                              isContainerEvent = false;
                              rebuildIn(() {});
                            },
                            onPanCancel: () {
                              nameColor = null;
                              _isMainEvent = true;
                              isContainerEvent = true;
                              rebuildIn(() {});
                            },
                            onPanEnd: (_) {
                              nameColor = null;
                              _isMainEvent = true;
                              isContainerEvent = true;
                              rebuildIn(() {});
                            },
                            onTap: () {
                              //TODO: 跳转到对方个人中心
                            },
                          ),
                        ),
                        TextSpan(
                          text: ":" + "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv",
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
