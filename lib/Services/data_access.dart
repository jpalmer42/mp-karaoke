import 'package:mp_karaoke_ui/Domain/media_folder.dart';
import 'package:mp_karaoke_ui/Domain/track.dart';
import 'package:sqlite3/sqlite3.dart';

class DataAccess {
  late final Database _db;

  DataAccess._() {
    _db = sqlite3.open('mpKaraoke.db');
  }

  static DataAccess? _instance;
  static DataAccess get instance => _instance ??= DataAccess._();

  Future<bool> firstTime() {
    return Future<bool>.delayed(Duration(milliseconds: 200), () {
      try {
        ResultSet results = _db.select("SELECT * FROM config");
        return results.isNotEmpty;
      } catch (err) {
        _createTables();
        return true;
      }
    });
  }

  void _createTables() {
    _db
      ..execute(
        "CREATE TABLE IF NOT EXISTS key_bindings (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, function TEXT, option TEXT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS media_folders (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, path TEXT, monitor TEXT, count INT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS tracks (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, id_media_folder INTEGER NOT NULL, path_name TEXT, code TEXT, artist TEXT, title TEXT, length INT, genres TEXT)",
      ) //
      ;
  }

  Future<List<MediaFolderInfo>> fetchMediaFolders() {
    return Future<List<MediaFolderInfo>>(() {
      List<MediaFolderInfo> response = [];
      ResultSet results = _db.select("SELECT id, path, monitor, last_updated, count FROM media_folders");
      for (var result in results) {
        String? dateStr = result.values[3] as String?;
        DateTime? date = (dateStr is String) ? DateTime.tryParse(dateStr) : null;

        response.add(
          MediaFolderInfo(
            result.values[1] as String,
            monitor: (result.values[2] as String) == 'Y',
            lastUpdated: date,
            count: result.values[4] as int?,
            id: result.values[0] as int,
          ),
        );
      }
      return response;
    });
  }

  Future<void> publishMediaFolders(List<MediaFolderInfo> folderInfo) {
    final deleteAll = _db.prepare(
      "DELETE FROM tracks WHERE id_media_folder=?",
    );
    final delete = _db.prepare(
      "DELETE FROM media_folders WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO media_folders (path, monitor, last_updated, count ) VALUES (?,?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE media_folders set path=?, monitor=?, last_updated=?, count=? WHERE id=?",
    );

    return Future<void>(() {
      try {
        _db.execute('BEGIN TRANSACTION');
        for (var item in folderInfo) {
          if (item.status == .deleted) {
            if (item.id != null) {
              deleteAll.execute([item.id]);
              delete.execute([item.id]);
            }
          } else if (item.status == .updated) {
            if (item.id == null) {
              insert.execute([
                item.path,
                item.monitor ? 'Y' : 'N',
                item.lastUpdated?.toIso8601String(),
                item.count ?? 0,
              ]);
            } else {
              update.execute([
                item.path,
                item.monitor ? 'Y' : 'N',
                item.lastUpdated?.toIso8601String(),
                item.count ?? 0,
                item.id,
              ]);
            }
          }
        }
        _db.execute('COMMIT');
      } catch (e) {
        print(e);
        _db.execute('ROLLBACK');
      } finally {
        deleteAll.close();
        delete.close();
        insert.close();
        update.close();
      }

      return;
    });
  }

  Future<List<Track>> fetchTracksById(int? id) async {
    return Future<List<Track>>(
      () {
        List<Track> response = [];
        ResultSet results = _db.select(
          "SELECT id, last_updated, id_media_folder, path_name, code, artist, title, length, genres FROM tracks WHERE id_media_folder=?",
          [id],
        );
        for (var result in results) {
          String? dateStr = result.values[1] as String?;
          DateTime? date = (dateStr is String) ? DateTime.tryParse(dateStr) : null;

          response.add(
            Track(
              result.values[3] as String,
              id: result.values[0] as int,
              lastUpdated: date,
              mediaFolderId: result.values[2] as int,
              code: result.values[4] as String,
              artist: result.values[5] as String,
              title: result.values[6] as String,
              length: result.values[7] as int,
              genres: result.values[8] as String?,
            ),
          );
        }
        return response;
      },
    );
  }

  Future<void> publishTracks(int? id, List<Track> tracks) async {
    final delete = _db.prepare(
      "DELETE FROM tracks WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO tracks (last_updated, id_media_folder, path_name, code, artist, title, length, genres) VALUES (?,?,?,?,?,?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE tracks set last_updated=?, id_media_folder=?, path_name=?, code=?, artist=?, title=?, length=?, genres=? WHERE id=?",
    );

    return Future<void>(
      () {
        try {
          _db.execute('BEGIN TRANSACTION');
          for (var item in tracks) {
            if (item.status == .deleted) {
              if (item.id != null) {
                delete.execute([item.id]);
              }
            } else if (item.status == .updated) {
              if (item.id == null) {
                insert.execute([
                  item.lastUpdated?.toIso8601String(),
                  item.mediaFolderId,
                  item.pathName,
                  item.code,
                  item.artist,
                  item.title,
                  item.length,
                  item.genres,
                ]);
              } else {
                update.execute([
                  item.lastUpdated?.toIso8601String(),
                  item.mediaFolderId,
                  item.pathName,
                  item.code,
                  item.artist,
                  item.title,
                  item.length,
                  item.genres,
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
      },
    );
  }
}
