import 'package:flutter/material.dart';

class HotHistoryStyle {
  final bool showHotHistory;
  final String hotText;
  final TextStyle hotTextStyle;
  // final Function clearHistoryFunc;
  final String historyText;
  final TextStyle historyTextStyle;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color bgColor;
  final double borderRadius;
  final Widget clearBtn;
  // Widget clearBtn = Container(
  //   // width: 100,
  //   // height: 25,
  //   decoration:
  //       BoxDecoration(border: Border.all(color: Colors.black54, width: 1)),
  //   child: Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[Icon(Icons.delete), Text('清空历史记录')],
  //   ),
  // );
  HotHistoryStyle(
      {this.showHotHistory = true,
      this.hotText = '热搜',
      this.hotTextStyle =
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      // this.clearHistoryFunc,
      this.historyText = '搜索',
      this.historyTextStyle =
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      this.padding = const EdgeInsets.all(10),
      this.margin = const EdgeInsets.all(10),
      this.bgColor = const Color.fromRGBO(233, 233, 233, 0.9),
      this.borderRadius = 10,
      this.clearBtn = const Icon(Icons.delete)});
}
