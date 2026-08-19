import 'dart:io';

import 'package:mp_karaoke_ui/Domain/media_folder.dart';
import 'package:mp_karaoke_ui/Domain/track.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:sqlite3/sqlite3.dart';

class MediaDataAccess {
  late final Database _db;

  static MediaDataAccess? _instance;
  static MediaDataAccess get instance => _instance ??= MediaDataAccess._();

  MediaDataAccess._() {
    String folder = '${AppConfig.instance.appSupportDir.path}${Platform.pathSeparator}mpk-media.db';
    _db = sqlite3.open(folder);
    _createTables();
  }

  void _createTables() {
    _db
      // ..execute(
      //   "CREATE TABLE IF NOT EXISTS key_bindings (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, function TEXT, option TEXT)",
      // ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS media_folders (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, path TEXT, monitor TEXT, count INT, json TEXT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS tracks (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, id_media_folder INTEGER NOT NULL, path_name TEXT, file_name TEXT, code TEXT, artist TEXT, title TEXT, length INT, genres TEXT, rating INT, json TEXT)",
      ) //
      ;
  }

  Future<List<MediaFolderInfo>> fetchMediaFolders() async {
    List<MediaFolderInfo> response = [];
    ResultSet results = _db.select("SELECT id, path, monitor, last_updated, count, json FROM media_folders");
    for (var result in results) {
      String? dateStr = result.values[3] as String?;
      DateTime? date = (dateStr is String) ? DateTime.tryParse(dateStr) : null;

      response.add(
        MediaFolderInfo(
          result.values[1] as String,
          monitor: (result.values[2] as String) == 'Y',
          lastUpdated: date,
          count: result.values[4] as int?,
          json: result.values[5] as String?,
          id: result.values[0] as int,
        ),
      );
    }
    return response;
  }

  Future<void> publishMediaFolders(List<MediaFolderInfo> folderInfo) async {
    final deleteAll = _db.prepare(
      "DELETE FROM tracks WHERE id_media_folder=?",
    );
    final delete = _db.prepare(
      "DELETE FROM media_folders WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO media_folders (path, monitor, last_updated, count, json ) VALUES (?,?,?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE media_folders set path=?, monitor=?, last_updated=?, count=?, json=?  WHERE id=?",
    );

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
              item.json,
            ]);
          } else {
            update.execute([
              item.path,
              item.monitor ? 'Y' : 'N',
              item.lastUpdated?.toIso8601String(),
              item.count ?? 0,
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
      deleteAll.close();
      delete.close();
      insert.close();
      update.close();
    }

    return;
  }

  Future<List<Track>> fetchTracksById(int? id) async {
    String query = "SELECT id, last_updated, id_media_folder, path_name, code, artist, title, length, genres, json FROM tracks";
    if (id != null) query = "$query WHERE id_media_folder=?";

    List<Track> response = [];
    ResultSet results = _db.select(query, (id != null) ? [id] : []);
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
          json: result.values[9] as String?,
        ),
      );
    }
    return response;
  }

  Future<void> publishTracks(int? id, List<Track> tracks) async {
    final delete = _db.prepare(
      "DELETE FROM tracks WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO tracks (last_updated, id_media_folder, path_name, file_name, code, artist, title, length, genres, rating, json) VALUES (?,?,?,?,?,?,?,?,?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE tracks set last_updated=?, id_media_folder=?, path_name=?, file_name=?, code=?, artist=?, title=?, length=?, genres=?, rating=?, json=? WHERE id=?",
    );

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
              item.fileName,
              item.code,
              item.artist,
              item.title,
              item.length,
              item.genres,
              item.json,
              item.rating,
            ]);
          } else {
            update.execute([
              item.lastUpdated?.toIso8601String(),
              item.mediaFolderId,
              item.pathName,
              item.fileName,
              item.code,
              item.artist,
              item.title,
              item.length,
              item.genres,
              item.rating,
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
