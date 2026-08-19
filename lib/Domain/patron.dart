import 'package:mp_karaoke_ui/Domain/base.dart';

class Patron extends BaseInfo {
  int? id;
  DateTime? lastUpdated;
  String name;
  String? homeVenue;
  DateTime? dateAdded;
  DateTime? dateLast;
  String? json;

  List<PatronHistory>? history = [];

  Patron({required this.name, this.id, this.lastUpdated, this.homeVenue, this.json, this.history, this.dateAdded, this.dateLast});
}

class PatronHistory extends BaseInfo {
  int? id;
  DateTime? lastUpdated;
  int idPatron;
  String fileName;
  String? artist;
  String? title;
  String? json;
  int? count;

  PatronHistory({required this.idPatron, required this.fileName, this.id, this.lastUpdated, this.artist, this.title, this.json, this.count}) {
    count ??= 0;
  }
}
