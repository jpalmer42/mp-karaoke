import 'dart:async';
import 'dart:io';

import 'package:mp_karaoke_ui/Domain/patron_info.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';
import 'package:mp_karaoke_ui/Domain/track_info.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/Services/patron_data_access.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:sqlite3/sqlite3.dart';

class QueueStream {
  late final Database _db;

  QueueStream._() {
    String folder = '${AppConfig.instance.appSupportDir.path}${Platform.pathSeparator}mpk-roster.db';
    _db = sqlite3.open(folder);
    _createTables();
    _recover();
  }

  void _createTables() {
    _db
      ..execute(
        "CREATE TABLE IF NOT EXISTS roster (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, id_patron INTEGER NOT NULL, sort_order INT NOT NULL, json TEXT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS roster_tracks (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, id_patron INTEGER NOT NULL, id_track INTEGER NOT NULL, file_name TEXT NOT NULL, sort_order INT NOT NULL, json TEXT)",
      ) //
      ;
  }

  static QueueStream? _instance;
  static QueueStream get instance => _instance ??= QueueStream._();

  final _controllerRoster = StreamController<List<RosterItem>>();
  final _controllerQueue = StreamController<Object>();

  Stream<List<RosterItem>> get rosterStream => _controllerRoster.stream;
  Stream<Object> get songQueueStream => _controllerQueue.stream;

  final List<RosterItem> _roster = [];

  void addSinger(PatronInfo patron, {List<TrackInfo>? tracks}) async {
    if (patron.id == null) {
      await PatronDataAccess.instance.publishPatron([patron..status = .updated]);
    }
    _roster.add(RosterItem(patron: patron, tracks: tracks));
    _controllerRoster.sink.add(_roster);
    _backup();
  }

  void onReorderItem(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex++;
    if (newIndex > oldIndex) newIndex--;
    final item = _roster.removeAt(oldIndex);
    _roster.insert(newIndex, item);
    //
    _controllerRoster.sink.add(_roster);
    _backup();
  }

  void _recover() async {
    final ResultSet rsPatron = _db.select("SELECT id_patron, json FROM roster ORDER BY sort_order");
    _roster.clear();
    for (final rPatron in rsPatron) {
      final listPatron = await PatronDataAccess.instance.fetchPatronById(id: rPatron.values[0] as int);
      if (listPatron.isNotEmpty) {
        final patron = listPatron.first;
        final ResultSet rsTracks = _db.select("SELECT id_track, file_name, json FROM roster_tracks WHERE id_patron=? ORDER BY sort_order", [patron.id]);
        final List<TrackInfo> tracks = [];
        for (final rTrack in rsTracks) {
          final listTracks = await MediaDataAccess.instance.fetchTracksById(rTrack.values[0] as int);
          if (listTracks.isNotEmpty) {
            tracks.add(listTracks.first);
          }
        }
        _roster.add(RosterItem(patron: patron, tracks: tracks));
      }
    }
    //
  }

  Future<void> _backup() async {
    //
  }
}
