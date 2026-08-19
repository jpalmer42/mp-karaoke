import 'package:mp_karaoke_ui/Domain/base.dart';

class BusinessInfo extends BaseInfo {
  int? id;
  DateTime? lastUpdated;
  String name;
  String? json;

  List<VenueInfo>? venues;
  BusinessInfo({this.id, this.lastUpdated, required this.name, this.json, this.venues});
}

class VenueInfo extends BaseInfo {
  int? id;
  int businessId;
  DateTime? lastUpdated;
  String name;
  String? json;
  double? latitude;
  double? longitude;

  VenueInfo({this.id, required this.businessId, this.lastUpdated, required this.name, this.json, this.latitude, this.longitude});
}
