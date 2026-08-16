import 'dart:io';
import 'dart:isolate';

import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';
import 'package:mp_karaoke_ui/Domain/media_folder.dart';
import 'package:mp_karaoke_ui/Domain/track.dart';
import 'package:mp_karaoke_ui/Services/data_access.dart';
import 'package:mp_karaoke_ui/Services/status_stream.dart';

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
      StatusStream.instance.setStatus('folderSync', StatusInfo('Starting Folder Sync'));
      _stack.add(info);
      final List<Track>? response = await Isolate.run<List<Track>?>(() => _isoFunc(info));
      if (response != null) {
        await DataAccess.instance.publishTracks(info.id, response);

        info.status = .updated;
        info.count = response.length;
        info.lastUpdated = DateTime.now();
        await DataAccess.instance.publishMediaFolders([info]);
        StatusStream.instance.setStatus('folderSync', StatusInfo('Finished Folder Sync'));
        Future.delayed(Duration(seconds: 5), () => StatusStream.instance.setStatus('folderSync', null));
        return true;
      }
    } finally {
      _stack.remove(info);
    }

    return false;
  }

  static final RegExp typePattern = RegExp(r'(\.CDG|\.ZIP)$', caseSensitive: false);

  Future<List<Track>?> _isoFunc(MediaFolderInfo info) async {
    final Directory dir = Directory(info.path);
    if (!dir.existsSync()) return null;

    List<Track> tracks = await DataAccess.instance.fetchTracksById(info.id);
    tracks.forEach((item) => item.status = .deleted);
    final Map<String, Track> mapTrack = {for (var track in tracks) track.pathName: track};

    dir.listSync(recursive: true).forEach((entry) {
      if (entry is File) {
        if (typePattern.hasMatch(entry.path)) {
          final track = mapTrack[entry.path];
          if (track != null) {
            track.status = .unchanged;
          } else {
            tracks.add(
              Track(entry.path)
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
