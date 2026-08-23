import 'package:mp_karaoke_ui/Domain/base.dart';

class BusinessInfo extends BaseInfo {
  DateTime? lastUpdated;
  String name;
  String? json;

  List<VenueInfo>? venues;
  BusinessInfo({super.id, this.lastUpdated, required this.name, this.json, this.venues});
}

class VenueInfo extends BaseInfo {
  int? businessId;
  DateTime? lastUpdated;
  String? name;
  String? city;
  String? json;

  VenueInfo({
    super.id,
    this.businessId,
    this.lastUpdated,
    this.name,
    this.city,
    this.json,
  });

  String? get nameCity => '$name - $city';
}
