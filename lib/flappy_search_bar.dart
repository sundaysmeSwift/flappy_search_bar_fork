library flappy_search_bar_fork;

import 'dart:async';

import 'package:async/async.dart';
import 'package:flappy_search_bar_fork/scaled_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'search_bar_style.dart';
import 'hot_history_style.dart';

import 'hovering_header_list.dart';
import 'index_bar.dart';

Size _getTextSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

typedef void CancelCallBack(String value);

enum SearchType { search, filter, lenovo, refresh }

mixin _ControllerListener<T, F> on State<SearchBar<T, F>> {
  //<T, F>
  void onListChanged(List<T> items, SearchType searchType) {} //<T>
  void onListLenovoChanged(List<F> items) {} //<F>
  void onLoading() {}

  void onClear() {}

  void onError(Error error) {}
}

class SearchBarController<T, F> {
  //<T, F>
  List<T> _list = []; //<T>
  List<T> _filteredList = []; //<T>
  List<T> _sortedList = []; //<T>
  List<F> _lenovoList = []; //<F>
  TextEditingController _searchQueryController;
  String _lastSearchedText;
  SearchType searchType;
  Future<List> Function(String text, SearchType)
      _lastSearchTFunction; //<List<T>>
  // Future<List<F>> Function(String text, SearchType) _lastSearchFFunction;
  _ControllerListener _controllerListener;
  int Function(T a, T b) _lastSorting; //T
  CancelableOperation _cancelableOperation;
  // CancelableOperation<T> _cancelableTOperation;
  // CancelableOperation<F> _cancelableFOperation;
  int minimumChars;

  void setTextController(
      TextEditingController _searchQueryController, minimunChars) {
    this._searchQueryController = _searchQueryController;
    this.minimumChars = minimunChars;
  }

  void setListener(_ControllerListener _controllerListener) {
    this._controllerListener = _controllerListener;
  }

  void clear() {
    _controllerListener?.onClear();
  }

  void _search(String text, SearchType searchType,
      Future Function(String text, SearchType) onSearch) async {
    //<List<T>>
    _controllerListener?.onLoading();
    // List<T> titems;
    // List<F> fitems;
    List items;
    try {
      if (_cancelableOperation != null &&
          (!_cancelableOperation.isCompleted ||
              !_cancelableOperation.isCanceled)) {
        _cancelableOperation.cancel();
      }
      //
      _cancelableOperation = CancelableOperation.fromFuture(
        onSearch(text, searchType),
        onCancel: () => {},
      );
      // final List<T> items = await _cancelableOperation.value;
      print('items b---');
      items = await _cancelableOperation.value;
      print('items a---');

      _lastSearchedText = text;
      _filteredList.clear();
      _sortedList.clear();
      _lastSorting = null;
      print('items center---');
      switch (searchType) {
        case SearchType.filter:
          {
            _lastSearchTFunction = onSearch;
            _filteredList.clear();
            _filteredList.addAll(List<T>.from(items));
            filterList((item) => false);
            _sortedList.clear();
            _controllerListener?.onListChanged(_filteredList, searchType);
          }
          break;
        case SearchType.lenovo:
          {
            _lenovoList.clear();
            _lenovoList.addAll(List<F>.from(items));
            _controllerListener?.onListChanged(_lenovoList, searchType);
          }
          break;
        default:
          {
            _lastSearchTFunction = onSearch;
            print('items  ss last-----');
            _list.clear();

            _list = items.cast<T>();

            _controllerListener?.onListChanged(_list, searchType);
          }
      }
    } catch (error) {
      _controllerListener?.onError(error);
    }
  }

  void _refreshData(
      bool isMore, Future<List<T>> Function(bool isMore) getFutureData) async {
    //<List<T>>
    _controllerListener?.onLoading();
    try {
      if (_cancelableOperation != null &&
          (!_cancelableOperation.isCompleted ||
              !_cancelableOperation.isCanceled)) {
        _cancelableOperation.cancel();
      }
      _cancelableOperation = CancelableOperation.fromFuture(
        getFutureData(isMore),
        onCancel: () => {},
      );
      //<T>
      final List items = await _cancelableOperation.value;

      if (isMore == true) {
        _list.addAll(items.cast<T>());
      } else {
        _list.clear();
        _list.addAll(items.cast<T>());
      }
      _filteredList.clear();
      _sortedList.clear();
      _lastSorting = null;

      _controllerListener?.onListChanged(_list, SearchType.refresh);
    } catch (error) {
      _controllerListener?.onError(error);
    }
  }

  void injectSearch(String searchText, SearchType searchType,
      Future<List> Function(String text, SearchType searchType) onChange) {
    //List<T>
    if (searchText != null && searchText.length >= minimumChars) {
      _searchQueryController.text = searchText;
      _search(searchText, searchType, onChange);
    }
  }

  void injectFreshData(
      bool isMore, Future<List<T>> Function(bool isMore) freshData) {
    //<List<T>>
    _refreshData(isMore, freshData);
  }

  void replayLastSearch() {
    if (_lastSearchTFunction != null && _lastSearchedText != null) {
      _search(_lastSearchedText, searchType, _lastSearchTFunction);
    }
  }

  void removeFilter() {
    _filteredList.clear();
    if (searchType != SearchType.lenovo) {
      if (_lastSorting == null) {
        _controllerListener?.onListChanged(_list, searchType);
      } else {
        _sortedList.clear();
        _sortedList.addAll(List.from(_list)); //<T>
        _sortedList.sort(_lastSorting);
        _controllerListener?.onListChanged(_sortedList, searchType);
      }
    }
  }

  void removeSort() {
    if (searchType != SearchType.lenovo) {
      _sortedList.clear();
      _lastSorting = null;
      _controllerListener?.onListChanged(
          _filteredList.isEmpty ? _list : _filteredList, searchType);
    }
  }

  void sortList(int Function(T a, T b) sorting) {
    //T
    _lastSorting = sorting;
    _sortedList.clear();
    //<T>
    _sortedList
        .addAll(List<T>.from(_filteredList.isEmpty ? _list : _filteredList));
    _sortedList.sort(sorting);
    _controllerListener?.onListChanged(_sortedList, searchType);
  }

  void filterList(bool Function(T item) filter) {
    //T
    _filteredList.clear();
    _filteredList.addAll(_sortedList.isEmpty
        ? _list.where(filter).toList()
        : _sortedList.where(filter).toList());
    _controllerListener?.onListChanged(_filteredList, searchType);
  }
}

/// Signature for a function that creates [ScaledTile] for a given index.
typedef ScaledTile IndexedScaledTileBuilder(int index);

class ScaledTitleProperty {
  /// Called to get the tile at the specified index for the
  /// [SliverGridStaggeredTileLayout].
  final IndexedScaledTileBuilder indexedScaledTileBuilder;

  /// Callback returning the widget corresponding to an item found
  /// //T
  final Widget Function(dynamic item, int index) onItemFound;
  const ScaledTitleProperty({this.indexedScaledTileBuilder, this.onItemFound});
}

class HoverListProperty {
  final List<int> itemCounts;
  final SectionHeaderBuilder sectionHeaderBuild;
  final HoverHeaderListItemBuilder itemBuilder;
  final HoverHeaderListSeparatorBuilder separatorBuilder;
  final ValueChanged onTopChanged;
  final ValueChanged onEndChanged;
  final SectionListOffsetChanged onOffsetChanged;
  final double initialScrollOffset;
  final ItemHeightForIndexPath itemHeightForIndexPath;
  final SeparatorHeightForIndexPath separatorHeightForIndexPath;
  final HeaderHeightForSection headerHeightForSection;

  final bool hover;
  final bool needSafeArea;
  final List<String> indexWordListOrBeforeList;
  final Function(String) indexBarCallBack;

  HoverListProperty(
      {this.itemCounts,
      this.sectionHeaderBuild,
      this.itemBuilder,
      this.itemHeightForIndexPath,
      this.headerHeightForSection,
      this.separatorHeightForIndexPath,
      this.separatorBuilder,
      this.onTopChanged,
      this.onEndChanged,
      this.onOffsetChanged,
      this.initialScrollOffset = 0,
      this.hover = true,
      this.needSafeArea = false,
      this.indexWordListOrBeforeList,
      this.indexBarCallBack});
}

class SearchBar<T, F> extends StatefulWidget {
  //<T, F>
  /// Future returning searched items
  /// //
  final Future<List<T>> Function(bool isMore) getListData;

  final SearchType searchType;

//<List<T>>
  /// Future returning searched items
  final Future<List> Function(String text, SearchType searchType) onChange;
  // hot history
  final HotHistoryStyle hotHistoryStyle;

  /// List of items showed by default
  /// <T>
  final List<T> suggestions;

  /// Callback returning the widget corresponding to a Suggestion item
  /// //T
  final Widget Function(T item, int index) buildSuggestion;

  /// Minimum number of chars required for a search
  final int minimumChars;

  //T
  final Widget Function(dynamic item, int index) onItemLenovoFound;

  /// Callback returning the widget corresponding to an Error while searching
  final Widget Function(Error error) onError;

  /// Cooldown between each call to avoid too many
  final Duration debounceDuration;

  /// Widget to show when loading
  final Widget loader;

  /// Widget to show when no item were found
  final Widget emptyWidget;

  /// Widget to show by default
  final Widget placeHolder;

  /// Widget showed on left of the search bar
  final Widget icon;

  /// Widget placed between the search bar and the results
  final Widget header;

  /// Hint text of the search bar
  final String hintText;

  /// TextStyle of the hint text
  final TextStyle hintStyle;

  /// Color of the icon when search bar is active
  final Color iconActiveColor;

  /// Text style of the text in the search bar
  final TextStyle textStyle;

  /// Text Aligin
  final TextAlign textAligin;

  ///text left padding
  final double textPaddingLeft;

  /// Widget shown for cancellation
  final Widget cancellationWidget;

  /// Width of cancellationWidget;
  final double cancellationWidgetWidth;

  /// Callback when cancel button is triggered
  final CancelCallBack onCancelled;

  ///FocusNode or lose
  // FocusNode focusNode;

  ///FocusNode lose callBack
  final VoidCallback focusCall;

  /// Controller used to be able to sort, filter or replay the search
  final SearchBarController searchBarController;

  /// Enable to edit the style of the search bar
  final SearchBarStyle searchBarStyle;

  /// Number of items displayed on cross axis
  final int crossAxisCount;

  /// Weather the list should take the minimum place or not
  final bool shrinkWrap;

  ///
  final ScaledTitleProperty scaledTileProperty;

  ///
  final HoverListProperty hoverListProperty;

  /// Set the scrollDirection
  final Axis scrollDirection;

  /// Spacing between tiles on main axis
  final double mainAxisSpacing;

  /// Spacing between tiles on cross axis
  final double crossAxisSpacing;

  /// Set a padding on the search bar
  final EdgeInsetsGeometry searchBarPadding;

  /// Set a padding on the header
  final EdgeInsetsGeometry headerPadding;

  /// Set a padding on the list
  final EdgeInsetsGeometry listPadding;

  SearchBar({
    Key key,
    this.getListData,
    this.searchType = SearchType.search,
    this.onChange,
    this.hotHistoryStyle,
    this.scaledTileProperty,
    this.hoverListProperty,
    this.onItemLenovoFound,
    this.searchBarController,
    this.minimumChars = 1,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.loader = const Center(child: CircularProgressIndicator()),
    this.onError,
    this.emptyWidget = const SizedBox.shrink(),
    this.header,
    this.placeHolder,
    this.icon = const Icon(Icons.search),
    this.hintText = "",
    this.hintStyle = const TextStyle(color: Color.fromRGBO(142, 142, 147, 1)),
    this.iconActiveColor = Colors.grey,
    this.textStyle,
    this.textAligin = TextAlign.center,
    this.textPaddingLeft = 30,
    this.cancellationWidget = const Text("Cancel"),
    this.cancellationWidgetWidth,
    this.onCancelled,
    this.focusCall,
    this.suggestions = const [],
    this.buildSuggestion,
    this.searchBarStyle = const SearchBarStyle(),
    this.crossAxisCount = 1,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.listPadding = const EdgeInsets.all(0),
    this.searchBarPadding = const EdgeInsets.all(0),
    this.headerPadding = const EdgeInsets.all(0),
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState<T, F>(); //<T, F>
}

class _SearchBarState<T, F> extends State<SearchBar<T, F>> //
    with
        TickerProviderStateMixin,
        _ControllerListener {
  //<T, F>
  bool _loading = false;
  Widget _error;
  var _inputStr = '';
  final _searchQueryController = TextEditingController();
  Timer _debounce;
  bool _animate = false;
  List _list = []; //<T>
  List _filterList = [];
  HotHistoryStyle _hotHistoryStyle;
  List _historyListData = ['d'];
  List _hotListData = ['a'];
  SearchBarController searchBarController;
  FocusNode focusNode = FocusNode();
  var _index = 0;

  ScrollController _scrollController;
  final Map _groupOffsetMap = {
//    这里因为根据实际数据变化和固定全部字母前两个值都是一样的，所以没有做动态修改，如果不一样记得要修改
    // INDEX_WORDS[0]: 0.0,
    // INDEX_WORDS[1]: 0.0,
  };
  GlobalKey<HoveringHeaderListState> _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    searchBarController =
        widget.searchBarController ?? SearchBarController(); //<T, F>

    searchBarController.setListener(this);
    searchBarController.setTextController(
        _searchQueryController, widget.minimumChars);
    searchBarController.injectFreshData(false, widget.getListData);
    // setState(() {

    // });
    if (widget.hotHistoryStyle != null) {
      _hotHistoryStyle = widget.hotHistoryStyle;
    } else {
      _hotHistoryStyle = HotHistoryStyle();
    }

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        print('失去焦点');
        if (widget.onCancelled != null) {
          widget.onCancelled(_searchQueryController.text);
        }
        _animate = false;
        _index = 0;
      } else {
        print('得到焦点');

        _animate = true;
        widget.focusCall();
        if (_searchQueryController.text.length > 0) {
          _index = 0;
        } else {
          _hotHistoryStyle.showHotHistory ? _index = 1 : _index = 0;
        }
      }
    });
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    focusNode.dispose();
    super.dispose();
  }

  @override
  void onListChanged(List items, SearchType searchType) {
    //<T>
    setState(() {
      _loading = false;
      if (searchType == SearchType.refresh) {
        _list = items;
        _animate = false;
      } else {
        _filterList = items;
      }
    });
  }

  @override
  void onLoading() {
    setState(() {
      _loading = true;
      _error = null;
      _animate = true;
    });
  }

  @override
  void onClear() {
    _cancel();
  }

  @override
  void onError(Error error) {
    setState(() {
      _loading = false;
      _error = widget.onError != null ? widget.onError(error) : Text("error");
    });
  }

//上下拉刷新
  _refreshData(bool isMore) async {
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }

    _debounce = Timer(widget.debounceDuration, () async {
      if (widget.getListData != null) {
        searchBarController._refreshData(isMore, widget.getListData);
      } else {
        setState(() {
          if (isMore == false) {
            _list.clear();
          }
          _filterList.clear();
          _error = null;
          _loading = false;
          _animate = false;
        });
      }
    });
  }

  _onTextChanged(String newText) async {
    if (_hotHistoryStyle.showHotHistory == true) {
      newText.length > 0 ? _index = 0 : _index = 1;
      print('show object');
    } else {
      _index = 0;
      print('hidden object');
    }
    _inputStr = newText;
    if (_debounce?.isActive ?? false) {
      _debounce.cancel();
    }

    _debounce = Timer(widget.debounceDuration, () async {
      if (newText.length >= widget.minimumChars && widget.onChange != null) {
        if (widget.onChange != null) {
          searchBarController._search(
              newText, widget.searchType, widget.onChange);
        }
      } else {
        setState(() {
          _filterList.clear();
          _error = null;
          _loading = false;
          // _animate = false;
        });
      }
    });
  }

  void _cancel() {
    if (widget.onCancelled != null) {
      widget.onCancelled('');
    }
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _searchQueryController.clear();
      _inputStr = '';
      if (widget.getListData == null) {
        if (widget.onChange != null) {
          _filterList.clear();
        }
      }
      if (_index != 0) {
        _index = 0;
      }

      _error = null;
      _loading = false;
      _animate = false;
    });
  }

  //<T>
  Widget _buildListView(
      List items, Widget Function(dynamic item, int index) builder) {
    return Padding(
      padding: widget.listPadding,
      child: StaggeredGridView.countBuilder(
        crossAxisCount: widget.crossAxisCount,
        itemCount: items.length,
        shrinkWrap: widget.shrinkWrap,
        staggeredTileBuilder: widget.scaledTileProperty != null
            ? (widget.scaledTileProperty.indexedScaledTileBuilder ??
                (int index) => ScaledTile.fit(1))
            : (int index) => ScaledTile.fit(1),
        scrollDirection: widget.scrollDirection,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        addAutomaticKeepAlives: true,
        itemBuilder: (BuildContext context, int index) {
          return builder(items[index], index);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return _error;
    } else if (_loading) {
      return widget.loader;
    } else if (_searchQueryController.text.length < widget.minimumChars) {
      if (widget.placeHolder != null) return widget.placeHolder;
      return _buildListView(widget.suggestions,
          widget.buildSuggestion ?? widget.scaledTileProperty.onItemFound);
    } else if (_list.isNotEmpty) {
      return _buildListView(
          _list,
          widget.searchType == SearchType.lenovo
              ? widget.onItemLenovoFound
              : widget.scaledTileProperty.onItemFound);
    } else {
      return widget.emptyWidget;
    }
  }

  Widget searchWidget(BuildContext context, double widthMax) {
    print('----${_animate}');
    return Padding(
      padding: widget.searchBarPadding,
      child: Container(
        height: widget.searchBarStyle.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: _animate
                    ? widget.cancellationWidgetWidth != null
                        ? widthMax - widget.cancellationWidgetWidth
                        : widthMax * .85
                    : widthMax,
                decoration: BoxDecoration(
                    borderRadius: widget.searchBarStyle.borderRadius,
                    color: widget.searchBarStyle.backgroundColor,
                    border: widget.searchBarStyle.border),
                child: Padding(
                  padding: widget.searchBarStyle.padding,
                  child: Theme(
                    child: Stack(
                      children: [
                        Positioned(
                          top: 5,
                          left: _animate
                              ? widget.textPaddingLeft - 25
                              : widget.cancellationWidgetWidth != null
                                  ? (widthMax -
                                              widget.cancellationWidgetWidth -
                                              _getTextSize(
                                                      _searchQueryController
                                                              .text ??
                                                          widget.hintText,
                                                      ((_searchQueryController
                                                                  .text
                                                                  .isEmpty ||
                                                              _searchQueryController
                                                                      .text ==
                                                                  null)
                                                          ? widget.textStyle
                                                          : widget.hintStyle))
                                                  .width) /
                                          2 -
                                      widget.textPaddingLeft -
                                      ((_searchQueryController.text.isEmpty ||
                                              _searchQueryController.text ==
                                                  null)
                                          ? 15
                                          : 5)
                                  : (widthMax * .85 -
                                              _getTextSize(
                                                      _searchQueryController
                                                              .text ??
                                                          widget.hintText,
                                                      ((_searchQueryController
                                                                  .text
                                                                  .isEmpty ||
                                                              _searchQueryController
                                                                      .text ==
                                                                  null)
                                                          ? widget.hintStyle
                                                          : widget.textStyle))
                                                  .width) /
                                          2 -
                                      widget.textPaddingLeft -
                                      ((_searchQueryController.text.isEmpty ||
                                              _searchQueryController.text ==
                                                  null)
                                          ? 15
                                          : 5),
                          child: widget.icon ??
                              Container(
                                width: 0,
                                height: 0,
                              ),
                        ),
                        TextField(
                          controller: _searchQueryController,
                          focusNode: focusNode,
                          onChanged: _onTextChanged,
                          style: widget.textStyle,
                          textAlign: widget.textAligin,
                          textAlignVertical: TextAlignVertical.bottom,
                          decoration: InputDecoration(
                            // icon: widget.icon ?? null,
                            contentPadding: EdgeInsets.fromLTRB(
                                widget.textPaddingLeft, 7, 8, 7),
                            hintText: widget.hintText,
                            hintStyle: widget.hintStyle,
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                        )
                      ],
                    ),
                    data: Theme.of(context).copyWith(
                      primaryColor: widget.iconActiveColor,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: _cancel,
              child: AnimatedOpacity(
                opacity: _animate ? 1.0 : 0,
                curve: Curves.easeIn,
                duration: Duration(milliseconds: _animate ? 300 : 0),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: _animate
                      ? widget.cancellationWidgetWidth != null
                          ? widget.cancellationWidgetWidth
                          : widthMax * .15
                      : 0,
                  child: Container(
                    color: Colors.transparent,
                    child: Center(
                      child: widget.cancellationWidget,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _inputStr = widget.hintText ?? ' ';

    TextEditingController.fromValue(TextEditingValue(
        // 设置内容
        text: _inputStr,
        // 保持光标在最后
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream, offset: _inputStr.length))));

    // final widthMax = context.size.width;
    return Container(child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final widthMax = constraints.maxWidth;
      List<Widget> children = [];
      if (widget.hoverListProperty != null) {
        children.add(searchWidget(context, widthMax));
        children.add(Flexible(
            child: IndexedStack(
          index: _index,
          children: [
            Stack(
              children: [
                HoveringHeaderList(
                  key: _globalKey,

                  ///分组信息，每组有几个item
                  itemCounts: widget.hoverListProperty.itemCounts ?? [0, 0],

                  ///header builder
                  sectionHeaderBuild:
                      widget.hoverListProperty.sectionHeaderBuild ??
                          (ctx, section) {
                            return Text('header');
                          },

                  ///header高度
                  headerHeightForSection:
                      widget.hoverListProperty.headerHeightForSection ??
                          (section) {
                            return 40;
                          },

                  ///item builder
                  itemBuilder: widget.hoverListProperty.itemBuilder ??
                      (ctx, indexPath, height) {
                        return Text('indexpath item');
                      },

                  ///item高度
                  itemHeightForIndexPath:
                      widget.hoverListProperty.itemHeightForIndexPath ??
                          (indexPath) {
                            return 50;
                          },

                  ///分割线builder
                  separatorBuilder: widget.hoverListProperty.separatorBuilder ??
                      (ctx, indexPath, height, isLast) {
//        print("indexPath : $indexPath,$isLast");
                        return Divider();
                      },

                  ///分割线高度
                  separatorHeightForIndexPath:
                      widget.hoverListProperty.separatorHeightForIndexPath ??
                          (indexPath, isLast) {
                            return 1;
                          },

                  ///滚动到底部和离开底部的回调
                  onEndChanged: widget.hoverListProperty.onEndChanged ??
                      (end) {
//          print("end : $end");
                      },

                  ///offset改变回调
                  onOffsetChanged: widget.hoverListProperty.onOffsetChanged ??
                      (offset, maxOffset) {
//        print("111111:offset : $offset");
                      },

                  ///滚动到顶部和离开顶部的回调
                  onTopChanged: widget.hoverListProperty.onTopChanged ??
                      (top) {
//          print("top:$top");
                      },

                  ///是否需要悬停header
                  hover: widget.hoverListProperty.onTopChanged ?? true,
                ),
                widget.hoverListProperty.indexWordListOrBeforeList != null
                    ? IndexBar(
                        indexWordListOrBeforeList:
                            widget.hoverListProperty.indexWordListOrBeforeList,
                        indexBarCallBack: (str) {
                          if (widget.hoverListProperty.indexBarCallBack !=
                              null) {
                            widget.hoverListProperty.indexBarCallBack(str);
                          }
                          if (_groupOffsetMap[str] != null) {
                            // _scrollController.animateTo(_groupOffsetMap[str],
                            //     duration: Duration(milliseconds: 1),
                            //     curve: Curves.easeIn);
                          }
                        },
                      )
                    : Container()
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 10),
                  // 热搜
                  ...hotListWidget(),
                  //历史记录：
                  ...historyListWidget(),
                ],
              ),
            )
          ],
        )));
      } else {
        children.addAll([
          searchWidget(context, widthMax),
          Expanded(
              child: IndexedStack(
            index: _index,
            children: [
              Column(
                children: [
                  Padding(
                    padding: widget.headerPadding,
                    child: widget.header ?? Container(),
                  ),
                  _buildContent(context),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 10),
                    // 热搜
                    ...hotListWidget(),
                    //历史记录：
                    ...historyListWidget(),
                  ],
                ),
              )
            ],
          ))
        ]);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }));
  }

  List<Widget> hotListWidget() {
    List<Widget> childern = [];

    if (_hotListData.length > 0) {
      List<Widget> inChilds = _hotListData
          .map((e) => Container(
                padding: _hotHistoryStyle.padding,
                margin: _hotHistoryStyle.margin,
                decoration: BoxDecoration(
                    color: _hotHistoryStyle.bgColor,
                    borderRadius:
                        BorderRadius.circular(_hotHistoryStyle.borderRadius)),
                child: Text(e),
              ))
          .cast<Widget>()
          .toList();
      childern.addAll([
        Container(
          child: Text(_hotHistoryStyle.hotText,
              style: _hotHistoryStyle.hotTextStyle),
        ),
        Divider(),
        Wrap(
          children: inChilds,
          // Container(
          //   padding: EdgeInsets.all(10),
          //   margin: EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //       color: Color.fromRGBO(233, 233, 233, 0.9),
          //       borderRadius: BorderRadius.circular(10)),
          //   child: Text('女装'),
          // ),
        )
      ]);
    } else {
      childern.add(Text(''));
    }
    print('hisleng--- ${childern.length}');
    return childern;
  }

  List<Widget> historyListWidget() {
    List<Widget> childern = [];

    if (_historyListData.length > 0) {
      List<Widget> inChilds = _historyListData
          .map((e) => Container(
                padding: _hotHistoryStyle.padding,
                margin: _hotHistoryStyle.margin,
                decoration: BoxDecoration(
                    color: _hotHistoryStyle.bgColor,
                    borderRadius:
                        BorderRadius.circular(_hotHistoryStyle.borderRadius)),
                child: Text(e),
              ))
          .cast<Widget>()
          .toList();
      childern.addAll([
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_hotHistoryStyle.historyText,
                style: _hotHistoryStyle.historyTextStyle),
            InkWell(
              onTap: () {
                // SearchServices.removeHistoryList();
                // this._getHistoryData();
              },
              child: _hotHistoryStyle.clearBtn,
            )
          ],
        )),
        Divider(),
        Wrap(
          children: inChilds,
          // Container(
          //   padding: EdgeInsets.all(10),
          //   margin: EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //       color: Color.fromRGBO(233, 233, 233, 0.9),
          //       borderRadius: BorderRadius.circular(10)),
          //   child: Text('女装'),
          // ),
        )
      ]);
    } else {
      childern.add(Text(''));
    }
    print('hisleng--- ${childern.length}');
    return childern;
  }
}

// Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: <Widget>[
//     Padding(
//       padding: widget.searchBarPadding,
//       child: Container(
//         height: widget.searchBarStyle.height,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: <Widget>[
//             Flexible(
//               child: AnimatedContainer(
//                 duration: Duration(milliseconds: 200),
//                 width: _animate
//                     ? widget.cancellationWidgetWidth != null
//                         ? widthMax - widget.cancellationWidgetWidth
//                         : widthMax * .85
//                     : widthMax,
//                 decoration: BoxDecoration(
//                     borderRadius: widget.searchBarStyle.borderRadius,
//                     color: widget.searchBarStyle.backgroundColor,
//                     border: widget.searchBarStyle.border),
//                 child: Padding(
//                   padding: widget.searchBarStyle.padding,
//                   child: Theme(
//                     child: Stack(
//                       children: [
//                         Positioned(
//                           top: 5,
//                           left: _animate
//                               ? widget.cancellationWidgetWidth != null
//                                   ? (widthMax -
//                                           widget.cancellationWidgetWidth -
//                                           _getTextSize(
//                                                   _searchQueryController
//                                                           .text ??
//                                                       widget.hintText,
//                                                   ((_searchQueryController
//                                                               .text
//                                                               .isEmpty ||
//                                                           _searchQueryController
//                                                                   .text ==
//                                                               null)
//                                                       ? widget.textStyle
//                                                       : widget.hintStyle))
//                                               .width) /
//                                       2
//                                   : (widthMax * .85 -
//                                           widget.cancellationWidgetWidth -
//                                           _getTextSize(
//                                                   _searchQueryController
//                                                           .text ??
//                                                       widget.hintText,
//                                                   ((_searchQueryController
//                                                               .text
//                                                               .isEmpty ||
//                                                           _searchQueryController
//                                                                   .text ==
//                                                               null)
//                                                       ? widget.textStyle
//                                                       : widget.hintStyle))
//                                               .width) /
//                                       2
//                               : widget.textPaddingLeft - 20,
//                           child: widget.icon ??
//                               Container(
//                                 width: 0,
//                                 height: 0,
//                               ),
//                         ),
//                         TextField(
//                           controller: _searchQueryController,
//                           focusNode: focusNode,
//                           onChanged: _onTextChanged,
//                           style: widget.textStyle,
//                           textAlign: widget.textAligin,
//                           textAlignVertical: TextAlignVertical.bottom,
//                           decoration: InputDecoration(
//                             // icon: widget.icon ?? null,
//                             contentPadding: EdgeInsets.fromLTRB(
//                                 widget.textPaddingLeft, 7, 8, 7),
//                             hintText: widget.hintText,
//                             hintStyle: widget.hintStyle,
//                             border: OutlineInputBorder(
//                                 borderSide: BorderSide.none),
//                           ),
//                         )
//                       ],
//                     ),
//                     data: Theme.of(context).copyWith(
//                       primaryColor: widget.iconActiveColor,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: _cancel,
//               child: AnimatedOpacity(
//                 opacity: _animate ? 1.0 : 0,
//                 curve: Curves.easeIn,
//                 duration: Duration(milliseconds: _animate ? 300 : 0),
//                 child: AnimatedContainer(
//                   duration: Duration(milliseconds: 200),
//                   width: _animate
//                       ? widget.cancellationWidgetWidth != null
//                           ? widget.cancellationWidgetWidth
//                           : MediaQuery.of(context).size.width * .15
//                       : 0,
//                   child: Container(
//                     color: Colors.transparent,
//                     child: Center(
//                       child: widget.cancellationWidget,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//     Padding(
//       padding: widget.headerPadding,
//       child: widget.header ?? Container(),
//     ),
//     Expanded(
//       child: _buildContent(context),
//     ),
//   ],
// );
