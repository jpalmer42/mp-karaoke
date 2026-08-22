import 'package:mp_karaoke_ui/Domain/base.dart';

class PatronInfo extends BaseInfo {
  int? id;
  DateTime? lastUpdated;
  String name;
  String? homeVenue;
  DateTime? dateAdded;
  DateTime? dateLast;
  String? json;

  List<PatronHistoryInfo> history = [];
  List<PatronHistoryInfo> get currentHistory {
    return [];
  }

  PatronInfo({required this.name, this.id, this.lastUpdated, this.homeVenue, this.json, List<PatronHistoryInfo>? history, this.dateAdded, this.dateLast}) {
    this.history = history ?? [];
  }
}

class PatronHistoryInfo extends BaseInfo {
  int? id;
  DateTime? lastUpdated;

  int idPatron;
  int idTrack;
  String fileName;
  String? json;
  int count = 0;

  PatronHistoryInfo({
    this.id,
    this.lastUpdated,

    required this.idPatron,
    required this.idTrack,
    required this.fileName,

    this.json,
    int? count,
  }) {
    this.count = count ?? 0;
  }
}
