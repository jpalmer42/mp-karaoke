import 'dart:async';

import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';

class StatusStream {
  StatusStream._();
  static StatusStream? _instance;
  static StatusStream get instance => _instance ??= StatusStream._();

  final _controller = StreamController<Map<String, StatusInfo>>();
  final Map<String, StatusInfo> _status = {};

  void setStatus(String key, StatusInfo? statusInfo) {
    if (statusInfo == null) {
      _status.remove(key);
    } else {
      _status[key] = statusInfo;
    }
    _controller.sink.add(_status);
  }

  Stream<Map<String, StatusInfo>> get stream => _controller.stream;
}
