import 'dart:math';
import 'dart:ui';

import 'package:flappy_search_bar_fork/flappy_search_bar.dart';
import 'package:flappy_search_bar_fork/hot_history_style.dart';
import 'package:flappy_search_bar_fork/scaled_tile.dart';
import 'package:flappy_search_bar_fork/search_bar_style.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

// Size _getTextSize(String text, TextStyle style) {
//   final TextPainter textPainter = TextPainter(
//       text: TextSpan(text: text, style: style),
//       maxLines: 1,
//       textDirection: TextDirection.ltr)
//     ..layout(minWidth: 0, maxWidth: double.infinity);
//   return textPainter.size;
// }

class Post {
  final String title;
  final String body;

  Post(this.title, this.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SearchBarController<Post, String> _searchBarController =
      SearchBarController();
  bool isReplay = false;
  Random random = Random();
  double cancellationWidgetWidth = 0;
  TextAlign textAligin;
  // FocusNode focusNode;
  // //<List<Post>>
  // List<String>>
  Future<List> _getALlPosts(String text, SearchType searchType) async {
    await Future.delayed(Duration(seconds: text.length == 4 ? 10 : 1));

    // List posts = [];

    // var random = new Random();
    // for (int i = 0; i < 10; i++) {
    //   posts.add("${text} : ${random.nextInt(100)}");
    // }
    // return List.from(posts);
    //

    List<Post> posts = [];

    var random = new Random();
    for (int i = 0; i < 10; i++) {
      posts.add(Post(" $i", "body random number : ${random.nextInt(100)}"));
    }
    return posts;
  }

//<List<Post>>
  Future<List<Post>> _getData(bool isMore) async {
    var text = 'fresh fresh';
    await Future.delayed(Duration(seconds: text.length == 4 ? 10 : 1));
    if (isReplay) return [Post("Replaying !", "Replaying body")];
    if (text.length == 5) throw Error();
    if (text.length == 6) return [];
    List<Post> posts = [];

    var random = new Random();
    for (int i = 0; i < 10; i++) {
      posts
          .add(Post("$text $i", "body random number : ${random.nextInt(100)}"));
    }
    return posts;
  }

  @override
  void initState() {
    super.initState();
    // focusNode = FocusNode();
    textAligin = TextAlign.center;
    cancellationWidgetWidth = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // 触摸收起键盘
            FocusScope.of(context).requestFocus(FocusNode());
            setState(() {
              // focusNode = FocusNode();
            });
          },
          child: SearchBar<Post, String>(
            searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
            headerPadding: EdgeInsets.symmetric(horizontal: 10),
            listPadding: EdgeInsets.symmetric(horizontal: 10),
            getListData: _getData,
            searchType: SearchType.search,
            onChange: _getALlPosts,
            searchBarController: _searchBarController,
            textAligin: textAligin,
            textPaddingLeft: 30,
            // focusNode: focusNode,
            focusCall: () {
              setState(() {
                print('focuscall');
                textAligin = TextAlign.left;
                cancellationWidgetWidth = 120;
              });
            },
            hintText: '搜索',
            hintStyle: TextStyle(
              textBaseline: TextBaseline.alphabetic,
              fontSize: 16,
            ),
            placeHolder: Text("placeholder"),
            cancellationWidget: Text("Cancel"),
            cancellationWidgetWidth: cancellationWidgetWidth,
            emptyWidget: Text("empty"),
            hoverListProperty: HoverListProperty(itemCounts: [5]),
            // indexedScaledTileBuilder: (int index) =>
            //     // ScaledTile.count(1, 1), //index.isEven ? 2 : 1
            //     ScaledTile.extent(1, 60),
            header: Row(
              children: <Widget>[
                RaisedButton(
                  child: Text("Sort"),
                  onPressed: () {
                    _searchBarController.sortList((Post a, Post b) {
                      return a.body.compareTo(b.body);
                    });
                  },
                ),
                RaisedButton(
                  child: Text("Desort"),
                  onPressed: () {
                    _searchBarController.removeSort();
                  },
                ),
                RaisedButton(
                  child: Text("Replay"),
                  onPressed: () {
                    isReplay = !isReplay;
                    _searchBarController.replayLastSearch();
                  },
                ),
                RaisedButton(
                    child: Text("Random"),
                    onPressed: () {
                      // cancellationWidgetWidth = 0; //random.nextInt(250) + 50.0;
                      // textPaddingLeft = 250;
                      // focusNode = FocusNode();
                      setState(() {});
                    })
              ],
            ),
            onCancelled: (String value) {
              print("Cancelled triggered");

              setState(() {
                textAligin = TextAlign.center;
                cancellationWidgetWidth = 0; //random.nextInt(250) + 50.0;
              });
            },
            mainAxisSpacing: 0,
            crossAxisSpacing: 10,
            crossAxisCount: 1,
            onItemLenovoFound: (item, int index) {
              return Text('item ---- ${index}');
            }, //2,
            // onItemFound: (post, int index) {
            //   return Container(
            //     color: Colors.lightBlue,
            //     child: ListTile(
            //       title: Text((post.title)),
            //       // isThreeLine: true,
            //       subtitle: Text(post.body),
            //       onTap: () {
            //         Navigator.of(context).push(
            //             MaterialPageRoute(builder: (context) => Detail()));
            //       },
            //     ),
            //   );
            // },
          ),
        )),
      ),
    );
  }
}

class Detail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text("Detail"),
          ],
        ),
      ),
    );
  }
}
