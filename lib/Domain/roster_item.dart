import 'package:mp_karaoke_ui/Domain/base.dart';
import 'package:mp_karaoke_ui/Domain/track.dart';

class RosterItem extends BaseInfo {
  RosterItem(this.singerName);

  String singerName = "";
  List<Track> tracks = [];
}
