import 'package:mp_karaoke_ui/Domain/base.dart';

class MediaFolderInfo extends BaseInfo {
  String path;
  bool monitor;
  DateTime? lastUpdated;
  int? count;
  String? json;

  MediaFolderInfo({required this.path, this.monitor = false, this.lastUpdated, this.count, super.id, this.json});

  @override
  String toString() {
    return '$id - $path';
  }
}
