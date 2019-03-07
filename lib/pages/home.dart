import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../common/util.dart';
import '../events/index.dart';
import '../models/download.dart';
import './detail.dart';

class HomePage extends StatefulWidget {
  static const String Tag = 'home_page';

  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new TabController(vsync: this, length: 2);

    // 添加事件监听
    eventBus.listen<AddLinkEvent>((event) => _onAddUrlTask(event.url.trim()));

    eventBus.listen<DownloadBitTorrentEvent>((event) {
      print('add torrent:${event.id}');
    });
  }

  void _onAddUrlTask(String source) {
    var url = Util.normalizeURL(source);
    if (url == null) {
      Toast.show('未知协议\n  $source', context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      return;
    }

    setState(() {
      _tryAddTask(source, url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text("极速下载"),
      actions: <Widget>[
        IconButton(
          // icon: Icon(Icons.more_vert),
          icon: Icon(Icons.format_list_bulleted),
          onPressed: () => _showPopupMenus(),
        )
      ],
      bottom: TabBar(
        controller: _controller,
        tabs: <Widget>[
          Tab(
              child: Text(
            '下载中',
            style: TextStyle(fontSize: 14),
          )),
          Tab(
              child: Text(
            '已完成',
            style: TextStyle(fontSize: 14),
          ))
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return TabBarView(
      controller: _controller,
      children: <Widget>[
        _buildTaskListView(context, TaskManager.instance.processing),
        _buildTaskListView(context, TaskManager.instance.completed),
      ],
    );
  }

  Widget _buildTaskListView(BuildContext context, List<Task> tasks) {
//    print('build list view:${tasks.length}');
    if (tasks.length > 0) {
      return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
//            print('build:$index');
            return _buildCard(context, tasks[index]);
          });
    } else {
      return Center(child: Text('没有任务'));
    }
  }

  Widget _buildCard(BuildContext context, Task item) {
//    print('build card:${item.name}');
    final texts = Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.name,
              style: TextStyle(fontSize: 14),
              maxLines: 2,
            ),
            Text(
              item.sizeText,
              style: TextStyle(fontSize: 10),
              maxLines: 1,
            ),
          ],
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Text(item.stateText, style: TextStyle(fontSize: 12), maxLines: 1),
        )
      ],
    );

    var widgets = <Widget>[
      Image.asset('assets/images/task.jpeg', width: 100, height: 100, fit: BoxFit.fill),
    ];

    // TODO:add type icon
    if (!item.isCompleted) {
      IconData icon = item.isActive ? Icons.pause : Icons.file_download;
      var button = Material(
        type: MaterialType.circle,
        color: Colors.black26,
        child: InkWell(
          child: Container(
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1.0, color: Colors.white)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          onTap: () {
            setState(() {
              item.flipState();
            });
          },
        ),
      );

      widgets.add(button);
    }

    final imageButton = GestureDetector(
      child: Stack(alignment: AlignmentDirectional.center, children: widgets),
      // onLongPress: ()=>{},
      onTap: () => {},
    );

    final card = Card(
      child: Container(
        height: 100,
        padding: EdgeInsets.all(10),
        child: Row(children: [
          Expanded(child: texts),
          SizedBox(width: 10),
          imageButton,
        ]),
      ),
    );

    return InkWell(
      child: card,
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => DetailPage(item)));
        // Navigator.pushNamed(context, 'detail_page');
        // showDialog(context: context, builder: (context) => TorrentDialog());
      },
      onLongPress: () {
        showModalBottomSheet(context: context, builder: (_) => _buildBottomSheet(context, item));
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context, Task item) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
              title: Text(
                '分享',
                textAlign: TextAlign.center,
              ),
              onTap: () {
                print('share');
                Navigator.pop(context);
              }),
          Divider(height: 2),
          ListTile(
              title: Text(
                "复制链接",
                textAlign: TextAlign.center,
              ),
              onTap: () {
                print('copy link');
                Clipboard.setData(ClipboardData(text: item.name));
                Navigator.pop(context);
              }),
          Divider(height: 2),
          ListTile(
              title: Text("重命名", textAlign: TextAlign.center),
              onTap: () {
                print('rename');
                Navigator.pop(context);
              }),
          Divider(height: 2),
          ListTile(
              title: Text("删除", textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
              onTap: () {
                print('remove');
                Navigator.pop(context);
              }),
          Container(
            height: 5,
            color: Theme.of(context).dividerColor,
          ),
          ListTile(
              title: Text("取消", textAlign: TextAlign.center),
              onTap: () {
                Navigator.pop(context);
              }),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return SpeedDial(
      marginBottom: 50,
      marginRight: 20,
      overlayOpacity: 0,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 24.0),
      // onOpen: () => print('OPENING DIAL'),
      // onClose: () => print('DIAL CLOSED'),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          label: '搜索资源',
          child: Icon(Icons.search, size: 18, color: Colors.white),
          onTap: () => Navigator.pushNamed(context, 'search_page'),
        ),
        SpeedDialChild(
          label: '添加链接',
          child: Icon(Icons.link, size: 18, color: Colors.white),
          onTap: () => Navigator.pushNamed(context, "link_page"),
        ),
        SpeedDialChild(
          label: '打开文件',
          child: Icon(Icons.folder_open, size: 18, color: Colors.white),
          onTap: () => _openFileExplorer(),
        ),
      ],
    );
  }

  void _openFileExplorer() async {
    print('open document');
    try {
      var path = await FilePicker.getFilePath(type: FileType.ANY);
      print("open path:$path");
      if (path != '') {
        var uri = 'file://' + path;
        _tryAddTask(path, uri);
      }
    } on PlatformException catch (e) {
      print('error:${e.toString()}');
    }

    if (!mounted) return;
    // final path = await FlutterDocumentPicker.openDocument();
  }

  void _tryAddTask(String source, String url) {
    if (!TaskManager.instance.addTask(source, url)) {
      Toast.show('已经下载过', context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
    }
  }

  void _showPopupMenus() {
    print("more:show menus");
  }
}
