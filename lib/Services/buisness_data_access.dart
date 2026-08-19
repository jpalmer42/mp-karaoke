import 'dart:io';

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
        "CREATE TABLE IF NOT EXISTS business (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, name TEXT, json TEXT)",
      ) //
      ..execute(
        "CREATE TABLE IF NOT EXISTS venues (id INTEGER NOT NULL PRIMARY KEY, last_updated TEXT, name TEXT, json TEXT)",
      ) //
      ;
  }
}
