import 'package:bot_toast/bot_toast.dart';
import 'package:dzclient/bi/ResponseCodeHandle.dart';
import 'package:dzclient/bi/RouteName.dart';
import 'package:dzclient/bi/SendRequest.dart';
import 'package:dzclient/dz_card/ShortDZ.dart';
import 'package:dzclient/home/HomePageProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BuildDZ extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BuildDZContent();
  }
}

class BuildDZContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BuildDZContent();
  }
}

class _BuildDZContent extends State<BuildDZContent> {
  RefreshController _refreshController = RefreshController(initialRefresh: true);
  List<Map<dynamic, dynamic>> _data = new List();
  Map<dynamic, dynamic> _reData = {};
  HomePageProvider _homePageProvider;

  @override
  void initState() {
    super.initState();

    //只引用值
    _homePageProvider = Provider.of<HomePageProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    _reData.clear();
    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: true,
      header: WaterDropHeader(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        controller: _homePageProvider.scrollController,
        itemCount: _data.length,
        itemBuilder: (_, index) {
          return itemBuilder(index);
        },
      ),
      onRefresh: () async {
        await pullGetDZRequest(isMore: false);
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await pullGetDZRequest(isMore: true);
        _refreshController.loadComplete();
      },
    );
  }

  Widget itemBuilder(int index) {
    if (_data[index] == null) {
      return Container();
    }

    //每次在builder之前，都要检测一下是否有重复
    if (_reData[_data[index]["dz_id"]] == null) {
      _reData[_data[index]["dz_id"]] = true;
      return Column(
        children: <Widget>[
          //已经判断过_data[index]为null的处理方式，所以这里一定不为null
          ShortDZ(dataItem: _data[index]),
          Divider(height: 0, thickness: 5, color: Colors.grey[100]),
        ],
      );
    } else {
      return Container();
    }
  }

  Future pullGetDZRequest({@required bool isMore}) async {
    await SendRequest.request(
      context: context,
      method: "GET",
      route: RouteName.noIdRoutes.homePage.getDz,
      query: {
        "sort_method": Provider.of<HomePageProvider>(context, listen: false).sortMethod,
        "any": (() {
          if (!isMore) {
            return null;
          }
          if (_data.length == 0) {
            return null;
          }
          var sm = Provider.of<HomePageProvider>(context, listen: false).sortMethod;
          if (sm == "随机") {
            return null;
          } else if (sm == "最新") {
            if (_data[_data.length - 1]["update_time"] == null) {
              return null;
            } else {
              return _data[_data.length - 1]["update_time"];
            }
          }
        })(),
      },
      toCodeHandles: (code, response) {
        return [
          codeHandles(code, ["5001", "5003", "5005"], () {
            BotToast.showNotification(title: (_) => Text("获取数据失败$code"));
          }),
          codeHandles(code, ["5002"], () {
            if (response.data["data"] == null) {
              BotToast.showNotification(title: (_) => Text("获取数据失败"));
              return;
            }
            if (isMore) {
              _data.addAll((response.data["data"] as List<dynamic>).cast());
            } else {
              _data.clear();
              _data.addAll((response.data["data"] as List<dynamic>).cast());
            }
            setState(() {});
          }),
        ];
      },
      toOtherCodeHandles: () {},
      bindLine: "1",
      isLoading: false,
    );
  }
}
