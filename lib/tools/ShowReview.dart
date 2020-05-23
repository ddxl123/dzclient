import 'dart:ui';

import 'package:flutter/material.dart';

showReview({
  @required BuildContext context,
  @required TextEditingController textEditingController,
  @required String speakToWho,
  @required Function onSend,
}) {
  double keyboardHeight;
  showModalBottomSheet(
    //isScrollControlled:true，可以让TextField行数最大化
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      print(["speakToWho:", speakToWho]);
      keyboardHeight = MediaQuery.of(_).viewInsets.bottom;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //下拉栏占位
          GestureDetector(
            child: Container(
              color: Colors.transparent,
              height: MediaQueryData.fromWindow(window).padding.top,
            ),
            onTap: () {
              Navigator.of(_).pop();
            },
          ),
          //顶栏
          Container(
            padding: EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text("我想对", style: TextStyle(fontSize: 16)),
                ButtonTheme.fromButtonThemeData(
                  data: ButtonThemeData(
                    padding: EdgeInsets.all(0),
                    minWidth: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: FlatButton(
                    onPressed: () {},
                    child: Text(
                      "@" + speakToWho,
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
                Text("说:", style: TextStyle(fontSize: 16)),
                Expanded(child: Container()),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                  child: ButtonTheme.fromButtonThemeData(
                    data: ButtonThemeData(
                      padding: EdgeInsets.fromLTRB(10, 1, 10, 1),
                      height: 0,
                      minWidth: 0,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: FlatButton(
                      child: Text("发送", style: TextStyle(fontSize: 16)),
                      onPressed: onSend,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //内容
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.grey[100],
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "想说点什么...",
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  ),
                  minLines: null,
                  maxLines: null,
                  autofocus: true,
                  onChanged: (value) {},
                ),
              ),
            ),
          ),
          //底栏
          Container(
            color: Colors.white,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.tag_faces),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.alternate_email),
                  onPressed: () {},
                ),
                Expanded(child: Container()),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                )
              ],
            ),
          ),
          //键盘占位
          Container(
            color: Colors.white,
            height: keyboardHeight,
          ),
        ],
      );
    },
  );
}
