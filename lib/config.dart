import 'dart:io';

import 'package:mp_karaoke_ui/Domain/business_info.dart';
import 'package:mp_karaoke_ui/Services/buisness_data_access.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String spInitialized = 'Initialized';
  static const String spLanguage = 'language';
  static const String spBusinessId = 'businessId';
  static const String spVenueId = 'venueId';

  late final SharedPreferences _preferences;
  SharedPreferences get prefs => _preferences;

  late final Directory _appSupportDir;
  Directory get appSupportDir => _appSupportDir;

  AppConfig._();
  static AppConfig? _instance;

  static AppConfig get instance {
    assert(_instance != null, 'AppConfig must be initialized using AppConfig.init() before accessing instance.');
    return _instance!;
  }

  late BusinessInfo _currentBusiness;
  BusinessInfo get currentBusiness => _currentBusiness;
  set currentBusiness(BusinessInfo value) {
    _currentBusiness = value;
    _preferences.setInt(spBusinessId, value.id!);
  }

  late VenueInfo _currentVenue;
  VenueInfo get currentVenue => _currentVenue;
  set currentVenue(VenueInfo value) {
    _currentVenue = value;
    _preferences.setInt(spVenueId, value.id!);
  }

  static Future<void> init() async {
    if (_instance != null) return;

    final config = AppConfig._();
    config._preferences = await SharedPreferences.getInstance();
    config._appSupportDir = await getApplicationSupportDirectory();

    _instance = config;

    config._getCurrentBusiness(config);
  }

  // void _getCurrentVenue(AppConfig config) async {
  //   final int? venueId = config._preferences.getInt(spVenueId);
  //   if (venueId != null) {
  //     final venues = await BusinessDataAccess.instance.fetchVenuesById(id: venueId);

  //     config._currentVenue = venues.isNotEmpty ? venues.first : VenueInfo(name: "Not Found $venueId");
  //   } else {
  //     config._currentVenue = VenueInfo(name: "Not Set");
  //   }
  // }

  void _getCurrentBusiness(AppConfig config) async {
    final int? businessId = config._preferences.getInt(spBusinessId);
    if (businessId != null) {
      final businesses = await BusinessDataAccess.instance.fetchBusiness(id: businessId, fetchVenues: true);

      config._currentBusiness = businesses.isNotEmpty ? businesses.first : BusinessInfo(name: "Not Found $businessId");
    } else {
      config._currentBusiness = BusinessInfo(name: "Not Set");
    }

    final int? venueId = config._preferences.getInt(spVenueId) ?? 1;
    if (venueId != null) {
      config._currentVenue = config._currentBusiness.venues!.firstWhere((venue) => venueId == venue.id, orElse: () => VenueInfo(name: "Not Set"));
    }
  }
}
