import 'package:mp_karaoke_ui/Domain/base.dart';

class MediaFolderInfo extends BaseInfo {
  int? id;
  String path;
  bool monitor;
  DateTime? lastUpdated;
  int? count;

  MediaFolderInfo(this.path, {this.monitor = false, this.lastUpdated, this.count, this.id});

  @override
  String toString() {
    return '$id - $path';
  }
}
