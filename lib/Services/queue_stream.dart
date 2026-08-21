import 'dart:async';

import 'package:mp_karaoke_ui/Domain/patron_info.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';

class QueueStream {
  QueueStream._();
  static QueueStream? _instance;
  static QueueStream get instance => _instance ??= QueueStream._();

  final _controllerRoster = StreamController<List<RosterItem>>();
  final _controllerQueue = StreamController<Object>();

  final List<RosterItem> _roster = [];

  void addSinger(PatronInfo patron) {
    _roster.add(RosterItem(patron));
    _controllerRoster.sink.add(_roster);
  }

  void onReorderItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex++;
    if (newIndex > oldIndex) newIndex--;
    final item = _roster.removeAt(oldIndex);
    _roster.insert(newIndex, item);
    //
    _controllerRoster.sink.add(_roster);
  }
}
