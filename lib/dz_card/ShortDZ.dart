import 'package:dzclient/dz_card/DZPage.dart';
import 'package:dzclient/handles/UserIcons.dart';
import 'package:flutter/material.dart';

class ShortDZ extends StatelessWidget {
  ShortDZ({@required this.dataItem});
  //已经判断过dataItem为null的处理方式，所以这里一定不为null
  final Map dataItem;

  @override
  Widget build(BuildContext context) {
    initData();
    return ShortDZContent(dataItem: dataItem);
  }

  void initData() {
    dataItem["dz_id"] ??= "获取失败";
    dataItem["user_id"] ??= "获取失败";
    dataItem["title"] ??= "获取失败";
    dataItem["short_content"] ??= "获取失败";
    dataItem["update_time"] ??= 0;
    dataItem["username"] ??= "获取失败";
    dataItem["user_icon"] ??= 0;
    dataItem["review_count"] ??= 0;
    dataItem["review0"] == null || dataItem["review0"]["reviewer_user_id"] == null || dataItem["review0"]["content"] == null || dataItem["review0"]["reviewer_username"] == null
        ? dataItem["review0"] = null
        : () {}();
    dataItem["review1"] == null || dataItem["review1"]["reviewer_user_id"] == null || dataItem["review1"]["content"] == null || dataItem["review1"]["reviewer_username"] == null
        ? dataItem["review1"] = null
        : () {}();
    dataItem["star_count"] ??= 0;
    dataItem["like_count"] ??= 0;
  }
}

class ShortDZContent extends StatefulWidget {
  ShortDZContent({@required this.dataItem});
  final Map dataItem;

  @override
  State<StatefulWidget> createState() {
    return _ShortDZContent();
  }
}

class _ShortDZContent extends State<ShortDZContent> with AutomaticKeepAliveClientMixin {
  Color _bc1;
  Color _bc2;
  //防止同时触发父组件的onPanDown事件
  bool _isChildOnPanDown = false;
  Color _mainc = Colors.white;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      child: cardMain(),
      onPanDown: (_) {
        if (!_isChildOnPanDown) {
          _mainc = Colors.grey[300];
          setState(() {});
        }
      },
      onPanCancel: () {
        _mainc = Colors.white;
        setState(() {});
      },
      onPanEnd: (_) {
        _mainc = Colors.white;
        setState(() {});
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => DZPage(widget.dataItem["dz_id"])));
      },
    );
  }

  Widget cardMain() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: _mainc,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          up(),
          center(),
          bottom(),
          SizedBox(height: 10),
          reviews(),
        ],
      ),
    );
  }

  Widget up() {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(50),
            boxShadow: <BoxShadow>[BoxShadow(blurRadius: 2)],
          ),
          child: UserIcons.getUserIconWidget(widget.dataItem["user_icon"]),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                widget.dataItem["username"],
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 5),
            Container(
              child: Text(
                widget.dataItem["update_time"].toString(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
        Expanded(child: Container()),
        Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.orange,
            boxShadow: <BoxShadow>[BoxShadow(blurRadius: 0)],
          ),
          child: Text("水水水水"),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget center() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 14),
          Container(
            child: Text(
              widget.dataItem["title"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 14),
          Container(
            child: Text(
              widget.dataItem["short_content"],
              style: TextStyle(fontSize: 16.5, height: 1.8),
            ),
          ),
          SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget bottom() {
    return Row(
      children: <Widget>[
        Text(
          widget.dataItem["star_count"] > 99 ? "99+" : widget.dataItem["star_count"].toString() + " 收藏",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Expanded(child: Container()),
        GestureDetector(
          child: Text("谢谢谢谢", style: TextStyle(fontSize: 12, color: Colors.blue)),
          onTap: () {},
        ),
        Expanded(child: Container()),
        Text(
          widget.dataItem["like_count"] > 99 ? "99+" : widget.dataItem["like_count"].toString() + " 支持",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Container(width: 10),
        Text(
          widget.dataItem["review_count"] > 99 ? "99+" : widget.dataItem["review_count"].toString() + " 评论",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget reviews() {
    return Container(
      alignment: Alignment.centerLeft,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.dataItem["review0"] == null
              ? Container()
              : Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: StatefulBuilder(
                    builder: (_, rebuild) {
                      return RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: GestureDetector(
                                child: Text(
                                  widget.dataItem["review0"]["reviewer_username"],
                                  style: TextStyle(color: Colors.blue, backgroundColor: _bc1),
                                ),
                                onPanDown: (_) {
                                  _bc1 = Colors.grey[300];
                                  rebuild(() {});
                                  _isChildOnPanDown = true;
                                },
                                onPanCancel: () {
                                  _bc1 = null;
                                  rebuild(() {});
                                  _isChildOnPanDown = false;
                                },
                                onPanEnd: (_) {
                                  _bc1 = null;
                                  rebuild(() {});
                                  _isChildOnPanDown = false;
                                },
                                onTap: () {
                                  //TODO: 跳转到对方个人中心
                                },
                              ),
                            ),
                            TextSpan(
                              text: ": " + widget.dataItem["review0"]["content"],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          widget.dataItem["review1"] == null
              ? Container()
              : Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: StatefulBuilder(
                    builder: (_, rebuild) {
                      return RichText(
                        text: TextSpan(
                          children: <InlineSpan>[
                            WidgetSpan(
                              child: GestureDetector(
                                child: Text(
                                  widget.dataItem["review1"]["reviewer_username"],
                                  style: TextStyle(color: Colors.blue, backgroundColor: _bc2),
                                ),
                                onPanDown: (_) {
                                  _bc2 = Colors.grey[300];
                                  rebuild(() {});
                                  _isChildOnPanDown = true;
                                },
                                onPanCancel: () {
                                  _bc2 = null;
                                  rebuild(() {});
                                  _isChildOnPanDown = false;
                                },
                                onPanEnd: (_) {
                                  _bc2 = null;
                                  rebuild(() {});
                                  _isChildOnPanDown = false;
                                },
                                onTap: () {
                                  //TODO: 跳转到对方个人中心
                                },
                              ),
                            ),
                            TextSpan(
                              text: ": " + widget.dataItem["review1"]["content"],
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
    );
  }
}
