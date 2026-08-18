import 'package:mp_karaoke_ui/Domain/base.dart';

class MediaFolderInfo extends BaseInfo {
  int? id;
  String path;
  bool monitor;
  DateTime? lastUpdated;
  int? count;
  String? json;

  MediaFolderInfo(this.path, {this.monitor = false, this.lastUpdated, this.count, this.id, this.json});

  @override
  String toString() {
    return '$id - $path';
  }
}
