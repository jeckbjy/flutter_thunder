import 'package:flutter/material.dart';
import '../events/index.dart';
// 实现选文件对话框
class TorrentDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TorrentDialog();
  }
}

class _TorrentDialog extends State<TorrentDialog> {
  bool _selectAll = true;
  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      SizedBox(height: 3),
      Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Text("请选择下载文件",
              style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          Positioned(
            right: 0,
            child: MaterialButton(
              minWidth: 0,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _selectAll ? "全选" : '取消全选',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.end,
              ),
              onPressed: () {
                setState(() {
                  _selectAll = !_selectAll;
                });
              },
            ),
          )
        ],
      ),
      SizedBox(height: 1),
      Divider(),
      Flexible(
        child: ListView(
          children: <Widget>[],
        ),
      ),
      Divider(),
      Text(
        '占用0B,本机可用空间70GB',
        style: TextStyle(fontSize: 10),
        textAlign: TextAlign.center,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: RaisedButton(
            child: Text('下载'),
            color: ButtonTheme.of(context).colorScheme.primary,
            onPressed: () {
              print('download');
              Navigator.pop(context);
              eventBus.fire(DownloadBitTorrentEvent('aaa', []));
            }),
      ),
    ];

    var body = Container(
      height: 400,
      constraints: BoxConstraints(maxHeight: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      ),
    );

    return Dialog(child: body);
  }
}
