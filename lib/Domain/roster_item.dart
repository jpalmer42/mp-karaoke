import 'package:mp_karaoke_ui/Domain/base.dart';
import 'package:mp_karaoke_ui/Domain/patron_info.dart';
import 'package:mp_karaoke_ui/Domain/track_info.dart';

class RosterItem extends BaseInfo {
  PatronInfo patron;
  List<TrackInfo> tracks = [];

  RosterItem(this.patron);
}
