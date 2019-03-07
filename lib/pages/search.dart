import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  static const String Tag = 'search_page';

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchTextCtrl;

  @override
  void initState() {
    super.initState();

    _searchTextCtrl = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _searchTextCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          _buildHeadBar(context),
          // _buildSearchBar(context),
          // list
        ],
      ),
    );
  }

  Widget _buildHeadBar(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildFlatButton(
            44, Icon(Icons.arrow_back, size: 20), () => Navigator.pop(context)),
        Flexible(
          child: _buildSearchBar(context),
        ),
        _buildFlatButton(
            44,
            Text(
              '搜索',
              style: TextStyle(color: Colors.blue, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            () => _search()),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(40))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          width: 5,
        ),
        Icon(
          Icons.search,
          size: 20,
        ),
        Flexible(
          child: TextField(
            controller: _searchTextCtrl,
            autofocus: true,
            decoration: InputDecoration.collapsed(hintText: '请输入查询关键词'),
          ),
        ),
        _buildClearButton(context),
        SizedBox(width: 5),
      ]),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return Material(
      type: MaterialType.circle,
      color: Colors.grey,
      child: InkWell(
        child: Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1.0, color: Colors.white)),
          child: Icon(Icons.clear, color: Colors.white, size: 16),
        ),
        onTap: () {
          setState(() {
            _searchTextCtrl.clear();
          });
        },
      ),
    );
  }

  Widget _buildFlatButton(double width, Widget child, VoidCallback onPressed) {
    return InkWell(
      // child: SizedBox(width: width, height: 30, child: Center(child: child,),),
      child: Container(
          width: width, height: 30, child: child, alignment: Alignment.center),
      onTap: onPressed,
    );
  }

  void _search() {
    final text = _searchTextCtrl.text;
    if (text.isNotEmpty) {
      print('search:$text');
    }
  }
}
