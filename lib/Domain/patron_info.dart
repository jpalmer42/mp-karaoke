import 'package:mp_karaoke_ui/Domain/base.dart';

class PatronInfo extends BaseInfo {
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

  String get nameHomeVenue => '$name - $homeVenue';

  PatronInfo({required this.name, super.id, this.lastUpdated, this.homeVenue, this.json, List<PatronHistoryInfo>? history, this.dateAdded, this.dateLast}) {
    this.history = history ?? [];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PatronInfo && other.id == id || (other is PatronInfo && other.nameHomeVenue == nameHomeVenue);
  }
}

class PatronHistoryInfo extends BaseInfo {
  DateTime? lastUpdated;

  int idPatron;
  int idTrack;
  String fileName;
  String? json;
  int count = 0;

  PatronHistoryInfo({
    super.id,
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
