import 'dart:async';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/ResponseCodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:dzclient/handles/UserIcons.dart';
import 'package:dzclient/tools/BButton.dart';
import 'package:dzclient/tools/ShowReview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

enum CenterTabBarType { star, review, like }

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
  TextEditingController _textEditingController = TextEditingController();
  RefreshController _refreshController = RefreshController();

  //初始值是review
  CenterTabBarType _currentCenterTabBarType = CenterTabBarType.review;

  Function(Function()) _sortButtonRebuild;
  Function(Function()) _footerRebuild;
  Function(Function()) _centerTabBarRebuild;
  Function(Function()) _loadPromptRebuild;
  Function(Function()) _allListBuilderRebuild;

  bool _isLoadPromptDisplay = false;

  Map _centerTabBarData = {};
  Map _starData = {};
  Map _reviewData = {};
  Map _likeData = {};

  void _initCenterTabBarData() {
    _centerTabBarData["star_count"] ??= 0;
    _centerTabBarData["review_count"] ??= 0;
    _centerTabBarData["like_count"] ??= 0;
  }

  void _initStarData() {}
  void _initReviewData() {}
  void _initLikeData() {}

  @override
  void dispose() {
    _refreshController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _allBody(),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

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
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      footer: _footer(),
      controller: _refreshController,
      onRefresh: () async {
        await widget.reloadDzContent();
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        _refreshController.loadComplete();
      },
      child: CustomScrollView(
        slivers: <Widget>[
          ///dz内容
          _dzContentSliver(),

          ///centerBar
          _centerTabBarSliver(),

          ///加载栏
          _loadPromptSliver(),

          ///sort栏
          _sortButtonSliver(),

          ///AllListBuilder
          // _allListBuilderSliver()
        ],
      ),
    );
  }

  Widget _footer() {
    return CustomFooter(
      loadStyle: LoadStyle.ShowWhenLoading,
      builder: (_, LoadStatus loadStatus) {
        Widget pullUpWidget;
        if (loadStatus == LoadStatus.idle) {
          pullUpWidget = Text("上拉加载");
        } else if (loadStatus == LoadStatus.loading) {
          pullUpWidget = CircularProgressIndicator();
        } else if (loadStatus == LoadStatus.failed) {
          pullUpWidget = Text("加载失败！点击重试！");
        } else if (loadStatus == LoadStatus.canLoading) {
          pullUpWidget = Text("松手,加载更多!");
        } else {
          pullUpWidget = Text("没有更多数据了!");
        }

        return StatefulBuilder(
          builder: (_, footerRebuild) {
            _footerRebuild = footerRebuild;
            //写上这一句，防止在false的时候出现空占位
            _refreshController.loadComplete();
            return Container(
              child: Center(
                child: pullUpWidget,
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
          )
        ],
      ),
    );
  }

  ///centerTabBar
  Widget _centerTabBarSliver() {
    return StatefulBuilder(
      builder: (_, centerTabBarRebuild) {
        _centerTabBarRebuild = centerTabBarRebuild;

        ///每次被rebuild,都要重新初始化一次数据
        _initCenterTabBarData();

        ///无需判断_tabIndex
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
                  "收藏 · " + (_centerTabBarData["star_count"] > 99 ? "99+" : _centerTabBarData["star_count"].toString()),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              onTap: () {
                _toTabBar(CenterTabBarType.star);
              },
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  "评论 · " + (_centerTabBarData["review_count"] > 99 ? "99+" : _centerTabBarData["review_count"].toString()),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              onTap: () {
                _toTabBar(CenterTabBarType.review);
              },
            ),
            Expanded(child: Container()),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Text(
                  "喜欢 · " + (_centerTabBarData["like_count"] > 99 ? "99+" : _centerTabBarData["like_count"].toString()),
                  style: TextStyle(fontSize: 15),
                ),
              ),
              onTap: () {
                _toTabBar(CenterTabBarType.like);
              },
            ),
          ],
        );
      },
    );
  }

  ///点击后先rebuild切换，切换后再获取data再重新rebuild
  ///原因一：可以快速切换
  ///原因二：防止连续不同的index请求导致延迟切换
  void _toTabBar(CenterTabBarType type) {
    _currentCenterTabBarType = type;
    _centerTabBarRebuild(() {});
    _footerRebuild(() {});

    ///rebuild内容 TODO:

    _sortButtonRebuild(() {});

    _loadPromptRebuild(() {
      _isLoadPromptDisplay = true;
    });

    ///虽然setState是同步的，但最好还是放在最后
    _tabBarViewFuture();
  }

  ///加载提示栏
  Widget _loadPromptSliver() {
    return SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (_, loadPromptRebuild) {
          _loadPromptRebuild = loadPromptRebuild;

          if (_isLoadPromptDisplay == true) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Container();
          }
        },
      ),
    );
  }

  ///sort栏
  Widget _sortButtonSliver() {
    return SliverToBoxAdapter(
      child: StatefulBuilder(
        builder: (_, sortButtonRebuild) {
          _sortButtonRebuild = sortButtonRebuild;
          if (_currentCenterTabBarType == CenterTabBarType.like || _currentCenterTabBarType == CenterTabBarType.star) {
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

  Future _tabBarViewFuture() async {
    ///若有新数据，则更新data，否则保持旧数据
    if (_currentCenterTabBarType == CenterTabBarType.star) {
      await SendRequest.request(
        context: context,
        method: "GET",
        route: RouteName.noIdRoutes.dzPage.getStar,
        toCodeHandles: (code, response) {
          return [];
        },
        toOtherCodeHandles: () {},
        bindLine: "CenterTabBarType.star",
        isLoading: false,
      );
    } else if (_currentCenterTabBarType == CenterTabBarType.like) {
      await SendRequest.request(
        context: context,
        method: "GET",
        route: RouteName.noIdRoutes.dzPage.getLike,
        toCodeHandles: (code, response) {
          return [];
        },
        toOtherCodeHandles: () {},
        bindLine: "CenterTabBarType.like",
        isLoading: false,
      );
    } else {
      await SendRequest.request(
        context: context,
        method: "GET",
        route: RouteName.noIdRoutes.dzPage.getReview1,
        toCodeHandles: (code, response) {
          return [];
        },
        toOtherCodeHandles: () {},
        bindLine: "CenterTabBarType.review",
        isLoading: false,
      );
    }
    _centerTabBarRebuild(() {});
    _sortButtonRebuild(() {});
    _loadPromptRebuild(() {
      _isLoadPromptDisplay = false;
    });
  }

  //tabBarView主控制
  Widget _tabBarViewSliver() {
    return StatefulBuilder(
      builder: (_, allListBuilderRebuild) {
        _allListBuilderRebuild = allListBuilderRebuild;
        if (_currentCenterTabBarType == CenterTabBarType.star) {
          return StarBuilder();
        } else if (_currentCenterTabBarType == CenterTabBarType.like) {
          return LikeBuilder();
        } else {
          return ReviewBuilder();
        }
      },
    );
  }
}

///
///
///
///
///
class ReviewBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReviewBuilder();
  }
}

class _ReviewBuilder extends State<ReviewBuilder> {
  ///必须默认为true
  bool _isMainEvent = true;

  @override
  Widget build(BuildContext context) {
    Color mainColor = Colors.white;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) {
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

                                      ///评论时间
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

                                ///评论的评论
                                Container(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.grey[100],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      shortReview(),
                                      shortReview(),
                                      allReview(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),

                          ///右
                          ///赞
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
            margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
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

  Widget allReview() {
    Color bc;
    return StatefulBuilder(
      builder: (_, rebuildIn) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                color: bc,
                child: Text(
                  "查看全部99+条评论",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
          onPanDown: (_) {
            bc = Colors.grey[300];
            _isMainEvent = false;
            rebuildIn(() {});
          },
          onPanCancel: () {
            bc = null;
            _isMainEvent = true;
            rebuildIn(() {});
          },
          onPanEnd: (_) {
            bc = null;
            _isMainEvent = true;
            rebuildIn(() {});
          },
          onTap: () {
            //TODO: 跳转到对方个人中心
          },
        );
      },
    );
  }
}

///
///
///
///
///
class StarBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StarBuilder();
  }
}

class _StarBuilder extends State<StarBuilder> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text("data"),
    );
  }
}

///
///
///
///
///
class LikeBuilder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LikeBuilder();
  }
}

class _LikeBuilder extends State<LikeBuilder> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text("data"),
    );
  }
}
