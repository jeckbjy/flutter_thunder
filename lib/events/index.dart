import './event_bus.dart';

EventBus eventBus = new EventBus(sync: true);

// 添加新的下载连接事件
class AddLinkEvent {
  final String url;
  AddLinkEvent(this.url);
}

class AddTorrentFileEvent {
  final String file;
  AddTorrentFileEvent(this.file);
}

// 添加新的BT下载事件
class DownloadBitTorrentEvent {
  final String id;
  final List<String> files;
  DownloadBitTorrentEvent(this.id, this.files);
}
