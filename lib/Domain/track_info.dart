import 'dart:io';

import 'package:mp_karaoke_ui/Domain/base.dart';
import 'package:mp_karaoke_ui/constants.dart';

class TrackInfo extends BaseInfo {
  int? mediaFolderId;
  String pathName;
  late String fileName;
  String? code;
  String? artist;
  String? title;
  int length;
  DateTime? lastUpdated;
  String? genres;
  int? rating;
  String? searchable;
  String? json;

  TrackInfo(
    this.pathName, {
    super.id,
    this.mediaFolderId,
    this.code,
    this.artist,
    this.title,
    this.length = 0,
    this.lastUpdated,
    this.genres,
    this.rating,
    this.json,
  }) {
    fileName = pathName.substring(pathName.lastIndexOf(Platform.pathSeparator) + 1);
    final fName = fileName.substring(0, fileName.lastIndexOf('.'));
    final parts = fName.split(" - ");
    final len = parts.length;
    if (len == 2) {
      code ??= 'zzNoCode';
      artist ??= parts[0];
      title ??= parts[1];
    } else if (len == 3) {
      code ??= parts[0];
      artist ??= parts[1];
      title ??= parts[2];
    } else if (len > 3) {
      code ??= parts[0];
      artist ??= parts[1];
      title ??= parts.sublist(2).join(" - ");
    } else {
      code ??= 'zzNoCode';
      artist ??= 'zzFileFormat';
      title ??= fName;
    }
    lastUpdated ??= DateTime.now();
  }

  // void makeSearchable() {
  //   searchable = "|$_makeSearchable(artist)|$_makeSearchable(title)|$_makeSearchable(genres)|$_makeSearchable(code)";
  // }

  static final RegExp regExpKeepAlphaNumeric = RegExp(r'[^0-9a-z]');

  String get lengthStr {
    return Constants.formatDuration(length);
  }

  // String _makeSearchable(String? data) {
  //   return (data == null) ? '' : data.toLowerCase().replaceAll(regExpKeepAlphaNumeric, '');
  // }
}

class PlayQueueInfo extends BaseInfo {
  late String singer;
  TrackInfo track;

  PlayQueueInfo({String? singer, required this.track}) {
    this.singer = singer ?? 'None Assigned';
  }
}
