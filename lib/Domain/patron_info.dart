import 'package:mp_karaoke_ui/Domain/base.dart';

class PatronInfo extends BaseInfo {
  int? id;
  DateTime? lastUpdated;
  String name;
  String? homeVenue;
  DateTime? dateAdded;
  DateTime? dateLast;
  String? json;

  List<PatronHistoryInfo>? history = [];

  PatronInfo({required this.name, this.id, this.lastUpdated, this.homeVenue, this.json, this.history, this.dateAdded, this.dateLast});
}

class PatronHistoryInfo extends BaseInfo {
  int? id;
  DateTime? lastUpdated;
  int idPatron;
  String fileName;
  String? artist;
  String? title;
  String? json;
  int? count;

  PatronHistoryInfo({required this.idPatron, required this.fileName, this.id, this.lastUpdated, this.artist, this.title, this.json, this.count}) {
    count ??= 0;
  }
}
