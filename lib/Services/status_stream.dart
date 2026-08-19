import 'dart:async';

import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';

class StatusStream {
  StatusStream._();
  static StatusStream? _instance;
  static StatusStream get instance => _instance ??= StatusStream._();

  final _controller = StreamController<List<StatusInfo>>();
  final List<StatusInfo> _status = [];

  void setStatus(StatusInfo statusInfo, {Duration? duration}) {
    if (_status.contains(statusInfo)) {
      if (duration == null) {
        _status.remove(statusInfo);
      }
    } else {
      _status.add(statusInfo);
    }

    if (duration != null) {
      Future.delayed(duration, () {
        _status.remove(statusInfo);
        _controller.sink.add(_status);
      });
    }

    _controller.sink.add(_status);
  }

  Stream<List<StatusInfo>> get stream => _controller.stream;
}
