import '../common/util.dart';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

enum TaskState {
  Active,     // 下载中
  Paused,     // 暂停中
  Failure,    // 下载失败,发生错误
  Completed,  // 下载完成
}

// http,ftp单纯url即可
// magnet需要先下载torrent
// torrent是一个文件
class Task {
  TaskState state;
  Uri uri;
  String id;          // hashId
  String source;      // 原始链接地址
  String normalized;  // 解析后地址
  String output;      // 保存路径
  String name;
  int createAt;       // 创建时间
  int finishAt;       // 完成时间
  int size;           // 文件大小
  int speedUp;        // 上传速度
  int speedDown;      // 下载速度

  static String calcId(String uri) {
    var md5 = crypto.md5;
    var content = Utf8Encoder().convert(uri);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  Task(this.id, this.source, this.normalized) {
    this.state =TaskState.Active;
    this.uri =Uri.parse(this.normalized);
    this.createAt = DateTime.now().millisecondsSinceEpoch;
    this.finishAt = 0;
    this.size = -1;
    this.speedUp = -1;
    this.speedDown = -1;

    if(this.uri.pathSegments.isNotEmpty) {
      for(var i = uri.pathSegments.length - 1; i >= 0; i--) {
        if(uri.pathSegments[i].isNotEmpty) {
          this.name = uri.pathSegments[i];
          break;
        }
      }
    }

    if(this.name == null) {
      this.name = uri.host;
    }
  }

  String get sizeText {
    return this.size < 0 ? '未知大小' : Util.toByteCountText(this.size);
  }

  String get stateText {
    switch (this.state) {
      case TaskState.Active:
        return '下载中';
      case TaskState.Paused:
        return '已暂停';
      case TaskState.Completed:
        return '已完成';
      case TaskState.Failure:
        return '下载失败';
      default:
        return '未知错误';
    }
  }

  String get createAtText {
    return toTimeText(this.createAt);
  }

  String get finishAtText {
    return this.finishAt > 0 ? toTimeText(this.finishAt) : '--';
  }

  String toTimeText(int timestamp) {
    var t = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var dt = new DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
    var str = dt.toLocal().toString();
    return str.substring(0, str.length - 4);
  }

  bool get isCompleted {
    return this.state ==TaskState.Completed;
  }

  bool get isActive {
    return this.state ==TaskState.Active;
  }

  void flipState() {
    this.state =isActive ? TaskState.Paused :TaskState.Active;
  }
}

// 下载管理
class TaskManager {
  static TaskManager _inst =TaskManager();

  static TaskManager get instance {
    return _inst;
  }

  var tasks = <Task>[];

  // 未完成
  List<Task> get processing {
    return tasks.where((i)=>i.state != TaskState.Completed).toList();
  }
  // 已完成
  List<Task> get completed {
    return tasks.where((i)=>i.state == TaskState.Completed).toList();
  }

  bool addTask(String uri, String normalized) {
    var id = Task.calcId(normalized);
    if(this.hasTask(id)) {
      return false;
    }
    var task = new Task(id, uri, normalized);
    this.tasks.add(task);
    print('task count:${this.tasks.length}');
    return true;
  }

  bool hasTask(String id) {
    for(var task in this.tasks) {
      if(task.id == id) {
        return true;
      }
    }

    return false;
  }
}
