import 'package:flutter/material.dart';
import '../models/download.dart';
import '../widgets/torrent_dialog.dart';

// 详细信息界面
class DetailPage extends StatefulWidget {
  static const String Tag = 'detail_page';
  final Task task;

  DetailPage(this.task);

  @override
  State<StatefulWidget> createState() {
    return _DetailPageState();
  }
}

class _DetailPageState extends State<DetailPage> {
  bool _collapsing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar();
  }

  Widget _buildBody(BuildContext context) {
    var widgets = <Widget>[
      _buildBrief(context),
      Divider(),
    ];

    if (!_collapsing) {
      widgets.add(_buildDetail(context));
      widgets.add(Divider());
    }

    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ListView(children: widgets),
    );
  }

  Widget _buildBrief(BuildContext context) {
    final task = this.widget.task;
    final text = Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SizedBox(
        height: 5,
      ),
      Text(task.name, maxLines: 2, style: TextStyle(fontSize: 16)),
      Text(task.sizeText, maxLines: 1, style: TextStyle(fontSize: 10)),
    ]);

    final info = Stack(children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: text),
          _buildButton(!_collapsing ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, () {
            setState(() {
              _collapsing = !_collapsing;
            });
          }),
        ],
      ),
      Positioned(left: 0, bottom: 0, child: Text(task.stateText, maxLines: 1, style: TextStyle(fontSize: 12))),
      Positioned(right: 0, bottom: 0, child: _buildRaisedButton(Text('打开', style: TextStyle(fontSize: 12)), () {
        showDialog(context: context, builder: (context) => TorrentDialog());
      })),
    ]);

    return Container(
        height: 100,
        child: Row(
          children: <Widget>[
            Image.asset('assets/images/task.jpeg', width: 100, height: 100, fit: BoxFit.fill),
            SizedBox(width: 10),
            Flexible(child: info),
          ],
        ));
  }

  Widget _buildButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      child: Container(
        width: 30,
        height: 30,
        child: Icon(icon),
      ),
      onTap: onPressed,
    );
  }

  Widget _buildRaisedButton(Widget child, VoidCallback onPressed) {
    return Material(
      type: MaterialType.button,
      color: Colors.blue,
      child: InkWell(
        child: Container(
          width: 40.0,
          height: 20.0,
          alignment: Alignment.center,
          child: child,
        ),
        onTap: onPressed,
      ),
    );
  }

  Widget _buildDetail(BuildContext context) {
    final task = this.widget.task;
    return Column(
      children: <Widget>[
        _buildTile('资源大小', task.size > 0 ? task.sizeText : '--'),
        _buildTile('资源数量', '--'),
        _buildTile('创建时间', task.createAtText),
        _buildTile('完成时间', task.finishAtText),
        _buildTile('资源链接', task.source),
      ],
    );
  }

  Widget _buildTile(String leading, String title) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      child: Row(children: <Widget>[
        Text(
          leading,
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(width: 10),
        Flexible(child: Text(title)),
//        Text(title),
      ]),
    );
  }
}
