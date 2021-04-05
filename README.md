此案例参考flappy_search_bar_fork 和 FultterIntroduction 控件改写而成   （显示联系人列表样式尚未完成）部分尚未改写完毕，更新中

flappy_search_bar_fork
==============================
This is fork of flappy_search_bar
----------------------------------------
A SearchBar widget handling most of search cases.

## Usage

To use this plugin, add flappy_search_bar as a dependency in your pubspec.yaml file.

### Example

```
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
            改写后到属性 (hoverListProperty,scaledTileProperty只选其一)
            hoverListProperty: HoverListProperty(itemCounts: [5],xx,xx,),
            
            scaledTileProperty: ScaledTitleProperty(
              indexedScaledTileBuilder: (int index) => ScaledTile.extent(1, 60),
              onItemFound: (post, int index) {
                return Container(
                  color: Colors.lightBlue,
                  child: ListTile(
                    title: Text((post.title)),
                    // isThreeLine: true,
                    subtitle: Text(post.body),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Detail()));
                    },
                  ),
                );
              },
            ),
            //这两个属性属性被改写到一个属性里边
            // indexedScaledTileBuilder: (int index) =>ScaledTile.extent(1, 60),
            //indexedScaledTileBuilder: (int index) => ScaledTile.count(1, index.isEven ? 2 : 1),
            
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
            
          ),
      ),
    );
  }
```

### Try it

A sample app is available to let you try all the features ! :)

### Warning

If you want to use a SearchBarController in order to do some sorts or filters, PLEASE put your instance of SearchBarController in a StateFullWidget.

If not, it will not work properly.

If you don't use an instance of SearchBarController, you can keep everything in a StateLessWidget !

### Parameters

| Name  | Type | Usage | Required | Default Value |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| onSearch   | Future<List<T>> Function(String text) | Callback giving you the text to look for and asking for a Future  | yes  | - |
| onItemFound| Widget Function(T item, int index) | Callback letting you build the widget corresponding to each item| yes| - |
| suggestions  |  List<T> | Potential fist list of suggestions (when no request have been made)  | no| [] |
| searchBarController  |  SearchBarController | Enable you to sort and filter your list  | no | default controller |
| searchBarStyle  |  SearchBarStyle | Syle to customize SearchBar  | no | default values on bottom tab |
| buildSuggestions| Widget Function(T item, int index) | Callback called to let you build Suggestion item (if not provided, the suggestion will have the same layout as the basic item)  | no| null|
| minimumChars  |  int | Minimum number of chars to start querying  | no| 3 |
| onError  |  Function(Error error) | Callback called when an error occur runnning Future | no| null |
| debounceDuration  | Duration | Debounce's duration | no| Duration(milliseconds: 500) |
| loader  | Widget | Widget that appears when Future is running | no| CircularProgressIndicator() |
| emptyWidget  | Widget | Widget that appears when Future is returning an empty list | no| SizedBox.shrink() |
| icon  | Widget | Widget that appears on left of the SearchBar | no| Icon(Icons.search) |
| hintText  | String | Hint Text | no| "" |
| hintStyle  | TextStyle | Hint Text style| no| TextStyle(color: Color.fromRGBO(142, 142, 147, 1)) |
| iconActiveColor  | Color | Color of icon when active | no| Colors.black |
| textStyle  | TextStyle | TextStyle of searched text | no| TextStyle(color: Colors.black) |
| cancellationWidget  | Widget | Widget shown on right of the SearchBar | no| Text("Cancel") |
| onCancelled  | VoidCallback | Callback triggered on cancellation's button click | no| null |
| crossAxisCount  | int | Number of tiles on cross axis (Grid) | no| 2 |
| shrinkWrap  | bool | Wether list should be shrinked or not (take minimum space) | no| true |
| scrollDirection  | Axis | Set the scroll direction | no| Axis.vertical |
| mainAxisSpacing  | int | Set the spacing between each tiles on main axis | no| 10 |
| crossAxisSpacing  | int | Set the spacing between each tiles on cross axis | no| 10 |
| indexedScaledTileBuilder  | IndexedScaledTileBuilder | Builder letting you decide how much space each tile should take | no| (int index) => ScaledTile.count(1, index.isEven ? 2 : 1) |  
| searchBarPadding  | EdgeInsetsGeometry | Set a padding on the search bar | no| EdgeInsets.symmetric(horizontal: 10) |
| headerPadding  | EdgeInsetsGeometry | Set a padding on the header | no| EdgeInsets.symmetric(horizontal: 10) |
| listPadding  | EdgeInsetsGeometry | Set a padding on the list | no| EdgeInsets.symmetric(horizontal: 10) |
  
### SearchBar default SearchBarStyle

| Name  | Type | default Value |
| ------------- | ------------- | ------------- |
| backgroundColor  | Color  | Color.fromRGBO(142, 142, 147, .15)  |
| padding  | EdgeInsetsGeometry  | EdgeInsets.all(5.0)  |
| borderRadius  | BorderRadius  | BorderRadius.all(Radius.circular(5.0))})  |



