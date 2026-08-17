import 'dart:io';

import 'package:mp_karaoke_ui/Domain/base.dart';

class Track extends BaseInfo {
  int? id;
  int? mediaFolderId;
  String pathName;
  String? fileName;
  String? code;
  String? artist;
  String? title;
  int length;
  DateTime? lastUpdated;
  String? genres;
  int? rating;
  String? searchable;

  Track(this.pathName, {this.id, this.mediaFolderId, this.code, this.artist, this.title, this.length = 0, this.lastUpdated, this.genres, this.rating}) {
    fileName = pathName.substring(pathName.lastIndexOf(Platform.pathSeparator) + 1);
    final parts = fileName!.split(" - ");
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
      title ??= fileName;
    }
    lastUpdated ??= DateTime.now();
  }

  void makeSearchable() {
    searchable = "|$_makeSearchable(artist)|$_makeSearchable(title)|$_makeSearchable(genres)|$_makeSearchable(code)";
  }

  static final RegExp regExpKeepAlphaNumeric = RegExp(r'[^0-9a-z]');
  String _makeSearchable(String? data) {
    return (data == null) ? '' : data.toLowerCase().replaceAll(regExpKeepAlphaNumeric, '');
  }
}
