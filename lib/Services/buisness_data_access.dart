import 'dart:io';

import 'package:mp_karaoke_ui/Domain/business_info.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:sqlite3/sqlite3.dart';

class BusinessDataAccess {
  late final Database _db;

  static BusinessDataAccess? _instance;
  static BusinessDataAccess get instance => _instance ??= BusinessDataAccess._();

  BusinessDataAccess._() {
    String folder = '${AppConfig.instance.appSupportDir.path}${Platform.pathSeparator}mpk-business.db';
    _db = sqlite3.open(folder);
    _createTables();
  }

  void _createTables() {
    _db //
      ..execute(
        "CREATE TABLE IF NOT EXISTS businesses (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, name TEXT, json TEXT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS venues (id INTEGER NOT NULL PRIMARY KEY, business_id INTEGER NOT NULL, last_updated TEXT, name TEXT, json TEXT)",
      ) //
      ;
  }

  Future<BusinessInfo> fetchBusiness() async {
    BusinessInfo? response;

    final ResultSet results = _db.select(
      "SELECT id, last_updated, name, json FROM businesses",
    );
    if (results.isNotEmpty) {
      final result = results.first;

      String? dateStr = result.values[1] as String?;
      DateTime? date = (dateStr is String) ? DateTime.tryParse(dateStr) : null;

      response = BusinessInfo(
        id: result.values[0] as int,
        lastUpdated: date,
        name: result.values[2] as String,
        json: result.values[3] as String?,
      );

      response.venues = await fetchVenuesByBuisnessId(response.id!);
    }
    return response ?? BusinessInfo(name: '');
  }

  Future<List<VenueInfo>> fetchVenuesByBuisnessId(int id) async {
    List<VenueInfo> response = [];
    final results = _db.select("SELECT id, business_id, last_updated, name, json WHERE business_id=?", [id]);
    for (final result in results) {
      String? dateStr = result.values[2] as String?;
      DateTime? date = (dateStr is String) ? DateTime.tryParse(dateStr) : null;
      response.add(
        VenueInfo(
          id: result.values[0] as int,
          businessId: result.values[1] as int,
          lastUpdated: date,
          name: result.values[3] as String,
          json: result.values[4] as String?,
        ),
      );
    }
    return response;
  }

  Future<void> publishBusiness(List<BusinessInfo> payload) async {
    final deleteAll = _db.prepare(
      "DELETE FROM venues WHERE business_id=?",
    );
    final delete = _db.prepare(
      "DELETE FROM businesses WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO businesses (last_updated, name, json ) VALUES (?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE businesses set last_updated=?, name=?, json=? WHERE id=?",
    );

    for (final item in payload) {
      try {
        _db.execute('BEGIN TRANSACTION');

        if (item.status == .deleted) {
          if (item.id != null) {
            deleteAll.execute([item.id]);
            delete.execute([item.id]);
          }
        } else if (item.status == .updated) {
          if (item.id == null) {
            insert.execute([
              item.lastUpdated?.toIso8601String(),
              item.name,
              item.json,
            ]);
            item.id = _db.lastInsertRowId;
          } else {
            update.execute([
              item.lastUpdated?.toIso8601String(),
              item.name,
              item.json,
              item.id,
            ]);
          }
        }

        await publishVenues(item.id, item.venues, transactional: false);

        _db.execute('COMMIT');
      } catch (e) {
        _db.execute('ROLLBACK');
      } finally {
        deleteAll.close();
        delete.close();
        insert.close();
        update.close();
      }
    }

    return;
  }

  Future<void> publishVenues(int? id, List<VenueInfo>? payload, {bool transactional = true}) async {
    if (id == null || payload == null) return;

    final delete = _db.prepare(
      "DELETE FROM venues WHERE id=?",
    );
    final insert = _db.prepare(
      "INSERT INTO venues (last_updated, name, latitude, longitude, json ) VALUES (?,?,?)",
    );
    final update = _db.prepare(
      "UPDATE venues set last_updated=?, name=?, latitude=?, longitude=?, json=? WHERE id=?",
    );

    try {
      if (transactional) {
        _db.execute('BEGIN TRANSACTION');
      }
      for (final item in payload) {
        if (item.status == .deleted) {
          if (item.id != null) {
            delete.execute([item.id]);
          }
        } else if (item.status == .updated) {
          if (item.id == null) {
            insert.execute([
              item.lastUpdated?.toIso8601String(),
              item.name,
              item.latitude,
              item.longitude,
              item.json,
            ]);
          } else {
            update.execute([
              item.lastUpdated?.toIso8601String(),
              item.name,
              item.latitude,
              item.longitude,
              item.json,
              item.id,
            ]);
          }
        }
      }
      if (transactional) {
        _db.execute('COMMIT');
      }
    } catch (e) {
      if (transactional) {
        _db.execute('ROLLBACK');
      }
    } finally {
      delete.close();
      insert.close();
      update.close();
    }

    return;
  }
}
