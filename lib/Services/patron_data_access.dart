import 'dart:io';

import 'package:mp_karaoke_ui/Domain/patron_info.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:sqlite3/sqlite3.dart';

class PatronDataAccess {
  late final Database _db;

  static PatronDataAccess? _instance;
  static PatronDataAccess get instance => _instance ??= PatronDataAccess._();

  PatronDataAccess._() {
    String folder = '${AppConfig.instance.appSupportDir.path}${Platform.pathSeparator}mpk-patron.db';
    _db = sqlite3.open(folder);
    _createTables();
  }

  void _createTables() {
    _db //
      ..execute(
        "CREATE TABLE IF NOT EXISTS patron (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, name TEXT, alias TEXT, home_venue TEXT, date_added TEXT, date_last TEXT, json TEXT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS patron_history (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, id_patron INTEGER NOT NULL, fileName TEXT, artist TEXT, title TEXT, count INTEGER, json TEXT)",
      ) //
      ;
  }

  Future<List<PatronInfo>> searchPatronsByName(String criteria) async {
    List<PatronInfo> response = [];

    final ResultSet results = _db.select("SELECT id, name, home_venue FROM patron WHERE name like ? COLLATE NOCASE or alias like ? COLLATE NOCASE", [
      ['%$criteria%', '%$criteria%'],
    ]);
    for (final item in results) {
      response.add(
        PatronInfo(
          id: item.values[0] as int,
          name: item.values[1] as String,
          homeVenue: item.values[2] as String?,
        ),
      );
    }
    return response;
  }

  Future<PatronInfo?> fetchPatronById({int? id}) async {
    PatronInfo? response;
    var query = "id, last_updated, name, home_venue, date_added, date_last, json FROM patron";
    if (id != null) {
      query = '$query WHERE id=?';
    }

    final ResultSet results = _db.select(
      query,
      id == null ? [] : [id],
    );

    if (results.isNotEmpty) {
      final item = results.first;
      final dateUpdatedStr = item.values[1];
      DateTime? dateUpdated = (dateUpdatedStr is String) ? DateTime.tryParse(dateUpdatedStr) : null;

      final dateAddedStr = item.values[4];
      DateTime? dateAdded = (dateAddedStr is String) ? DateTime.tryParse(dateAddedStr) : null;

      final dateLastStr = item.values[5];
      DateTime? dateLast = (dateLastStr is String) ? DateTime.tryParse(dateLastStr) : null;

      response = PatronInfo(
        id: item.values[0] as int,
        lastUpdated: dateUpdated,
        name: item.values[1] as String,
        homeVenue: item.values[2] as String,
        dateAdded: dateAdded,
        dateLast: dateLast,
        json: item.values[6] as String,
      );

      List<PatronHistoryInfo> history = [];
      final ResultSet historyResults = _db.select(
        "SELECT id, last_updated, id_patron, fileName, artist, title, count, json FROM patron_history WHERE id_patron=?",
        [id],
      );
      for (final item in historyResults) {
        final dateStr = item.values[1];
        DateTime? date = (dateStr is String) ? DateTime.tryParse(dateStr) : null;
        history.add(
          PatronHistoryInfo(
            id: item.values[0] as int,
            lastUpdated: date,
            idPatron: item.values[2] as int,
            fileName: item.values[3] as String,
            artist: item.values[4] as String?,
            title: item.values[5] as String?,
            count: item.values[6] as int,
            json: item.values[7] as String?,
          ),
        );
      }
    }

    return response;
  }

  Future<void> publishPatron(List<PatronInfo> payload) async {
    final delete = _db.prepare(
      "DELETE FROM patron_history WHERE id_patron=?;DELETE FROM patron WHERE id=?",
    );
    final deleteAllHist = _db.prepare(
      "DELETE FROM patron_history WHERE id_patron=?",
    );
    final insert = _db.prepare(
      "INSERT INTO patron (last_updated, name, home_venue, date_added, date_last, json) VALUES (?,?,?,?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE patron set last_updated=?, name=?, home_venue=?, date_added=?, date_last=?, json=? FROM patron WHERE id=?",
    );

    for (final item in payload) {
      try {
        _db.execute('BEGIN TRANSACTION');

        if (item.status == .deleted) {
          if (item.id != null) {
            deleteAllHist.execute([item.id]);
            delete.execute([item.id]);
            item.history = [];
          }
        } else if (item.status == .updated) {
          item.lastUpdated = DateTime.now();
          if (item.id == null) {
            insert.execute([
              item.lastUpdated?.toIso8601String(),
              item.name,
              item.homeVenue,
              item.dateAdded?.toIso8601String(),
              item.dateLast?.toIso8601String(),
              item.json,
            ]);
            item.id = _db.lastInsertRowId;
          } else {
            update.execute([
              item.lastUpdated?.toIso8601String(),
              item.name,
              item.homeVenue,
              item.dateAdded?.toIso8601String(),
              item.dateLast?.toIso8601String(),
              item.json,
              item.id,
            ]);
          }
        }

        await publishPatronHistory(item.id, item.history, transactional: false);

        _db.execute('COMMIT');
      } catch (e) {
        _db.execute('ROLLBACK');
      } finally {
        deleteAllHist.close();
        delete.close();
        insert.close();
        update.close();
      }
    }
    return;
  }

  Future<void> publishPatronHistory(int? id, List<PatronHistoryInfo>? history, {bool transactional = true}) async {
    if (id == null || history == null) return;

    final delete = _db.prepare(
      "DELETE FROM patron_history WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO patron_history (last_updated, id_patron, fileName, artist, title, count, json) VALUES (?,?,?,?,?,?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE patron_history set last_updated=?, id_patron=?, fileName=?, artist=?, title=?, count=?, json=? WHERE id=?",
    );

    try {
      _db.execute('BEGIN TRANSACTION');
      for (final item in history) {
        item.idPatron = id;

        if (item.status == .deleted) {
          if (item.id != null) {
            delete.execute([item.id]);
          }
        } else if (item.status == .updated) {
          item.lastUpdated = DateTime.now();
          if (item.id == null) {
            insert.execute([
              item.lastUpdated?.toIso8601String(),
              item.idPatron,
              item.fileName,
              item.artist,
              item.title,
              item.count,
              item.json,
            ]);
          } else {
            update.execute([
              item.lastUpdated?.toIso8601String(),
              item.idPatron,
              item.fileName,
              item.artist,
              item.title,
              item.count,
              item.json,
              item.id,
            ]);
          }
        }
      }

      _db.execute('COMMIT');
    } catch (e) {
      _db.execute('ROLLBACK');
    } finally {
      delete.close();
      insert.close();
      update.close();
    }
    return;
  }
}
