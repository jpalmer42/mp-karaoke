import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';
import 'package:mp_karaoke_ui/Domain/media_folder_info.dart';
import 'package:mp_karaoke_ui/Domain/track_info.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/Services/status_stream.dart';
import 'package:mp_karaoke_ui/config.dart';

class FolderScan {
  FolderScan._();
  static FolderScan? _instance;
  static FolderScan get instance => _instance ??= FolderScan._();

  final List<MediaFolderInfo> _stack = [];

  Future<bool> process(MediaFolderInfo info) async {
    if (_stack.any((item) => item.id == info.id)) {
      return false;
    }

    try {
      StatusInfo status = StatusInfo('Starting Folder Sync');
      StatusStream.instance.setStatus(status);

      _stack.add(info);
      final RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
      final List<TrackInfo>? response = await Isolate.run<List<TrackInfo>?>(() => _isoFunc(info, rootIsolateToken));
      if (response != null) {
        await MediaDataAccess.instance.publishTracks(info.id, response);

        info.status = .updated;
        info.count = response.length;
        info.lastUpdated = DateTime.now();
        await MediaDataAccess.instance.publishMediaFolders([info]);
        StatusStream.instance.setStatus(status..text = 'Folder Sync Finshed', duration: Duration(seconds: 3));
        return true;
      }
    } finally {
      _stack.remove(info);
    }

    return false;
  }

  static final RegExp typePattern = RegExp(r'(\.CDG|\.ZIP)$', caseSensitive: false);

  Future<List<TrackInfo>?> _isoFunc(MediaFolderInfo info, RootIsolateToken rootIsolateToken) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final Directory dir = Directory(info.path);
    if (!dir.existsSync()) return null;

    await AppConfig.init(); // New Spawned Thread!

    List<TrackInfo> tracks = await MediaDataAccess.instance.fetchTracksById(info.id);
    tracks.forEach((item) => item.status = .deleted);
    final Map<String, TrackInfo> mapTrack = {for (var track in tracks) track.pathName: track};

    dir.listSync(recursive: true).forEach((entry) {
      if (entry is File) {
        if (typePattern.hasMatch(entry.path)) {
          final track = mapTrack[entry.path];
          if (track != null) {
            track.status = .unchanged;
          } else {
            tracks.add(
              TrackInfo(entry.path)
                ..status = .updated
                ..mediaFolderId = info.id,
            );
          }
        }
      }
    });

    return tracks;
  }
}
