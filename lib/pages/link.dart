import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../events/index.dart';

// 添加链接页面
class LinkPage extends StatefulWidget {
  static const String Tag = 'link_page';

  @override
  State<StatefulWidget> createState() {
    return _LinkPageState();
  }
}

class _LinkPageState extends State<LinkPage> {
  TextEditingController _controller;
  bool _showClearButton;

  @override
  void initState() {
    super.initState();

    _showClearButton = false;

    _controller = new TextEditingController();
    _controller.addListener((){
      if(_showClearButton !=_controller.text.isNotEmpty) {
        setState(() {
          _showClearButton =_controller.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context));
  }

  Widget _buildAppBar() {
    return AppBar(title: Text("添加下载任务"),);
  }

  Widget _buildBody(BuildContext context) {
    var body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
      _buildClearableTextField(context),
      SizedBox(height: 10,),
      RaisedButton(
        child: Text("下载"), 
        color: Theme.of(context).accentColor,
        onPressed: (){
          Navigator.pop(context);
          if(_controller.text.isNotEmpty) {
            eventBus.fire(AddLinkEvent(_controller.text));
          }
        },)
    ]);

    return Padding(padding: EdgeInsets.all(10),child: body);
  }

  Widget _buildClearableTextField(BuildContext context) {
    var stack = Stack(children: <Widget>[
      TextField(
        controller: _controller,
        maxLines: 15,
        autofocus: true,
        decoration: InputDecoration(
          hintText: "支持链接:magnet,ed2k,thunder,ftp,http/https",
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.fromLTRB(4, 1, 20, 1)
        ),
      ),
    ],);

    if(_showClearButton) {
      stack.children.add(Positioned(
        top:0,
        right:0,
        child:Button(child: Icon(Icons.clear), onPressed: ()=>_controller.clear()),
      ));
    }

    return stack;
  }
}