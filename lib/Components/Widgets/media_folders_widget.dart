import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/media_folder.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/Services/folder_scan.dart';
import 'package:mp_karaoke_ui/constants.dart';

class MediaFoldersWidget extends StatefulWidget {
  final void Function(bool isScanning)? onScan;
  const new({
    super.key,
    this.onScan,
  });

  @override
  State<MediaFoldersWidget> createState() => _MediaFoldersWidgetState();
}

class _MediaFoldersWidgetState extends State<MediaFoldersWidget> with Translate {
  late final List<MediaFolderInfo> _items = [];

  @override
  void initState() {
    _getData();
    super.initState();
  }

  void _getData() {
    if (mounted) {
      MediaDataAccess.instance.fetchMediaFolders().then(
        (folders) => setState(() {
          _items.clear();
          _items.addAll(folders);
        }),
      );
    }
  }

  int selected = -1;
  bool isDisabled = false;
  @override
  Widget build(BuildContext context) {
    final visibleItems = _items.where((item) => item.status != .deleted).toList();

    return Constants.disableWidgetTree(
      isDisabled,
      showProgress: true,
      child: ListView(
        children: [
          ...List.generate(
            visibleItems.length,
            (index) {
              final item = visibleItems[index];

              return ListTile(
                selected: index == selected,
                selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                title: Text(item.path),
                titleTextStyle: Theme.of(context).textTheme.bodyLarge,
                subtitle: _subTitle(item),
                subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                leading: IconButton(
                  onPressed: () => _addEdit(index),
                  icon: Icon(Icons.edit, color: Colors.blue),
                ),
                trailing: Row(
                  mainAxisSize: .min,
                  children: [
                    if (item.monitor) Text(translate("Scan on Start")),
                    if (item.id != null)
                      IconButton(
                        tooltip: 'Scan Now!',
                        icon: const Icon(Icons.refresh, color: Colors.green),
                        onPressed: () {
                          _scanFolder(item);
                        },
                      ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        item.status = .deleted;
                        _save();
                      },
                    ),
                  ],
                ),
                onTap: () => setState(() => selected = index),
              );
            },
          ),
          ListTile(
            title: TextButton.icon(label: Text(translate("Add")), onPressed: () => _addEdit(-1), icon: Icon(Icons.add)),
          ),
        ],
      ),
    );
  }

  Text _subTitle(MediaFolderInfo info) {
    if (!Directory(info.path).existsSync()) {
      return Text(translate('Folder does not exist'), style: TextStyle(color: Colors.redAccent));
    }
    if (info.lastUpdated != null) {
      return Text("${info.lastUpdated!.toLocal()} (${info.count})");
    } else {
      return Text(translate("Not yet Indexed"), style: TextStyle(fontStyle: FontStyle.italic));
    }
  }

  void _addEdit(int index) {
    final MediaFolderInfo? item = index >= 0 ? _items[index] : null;
    showDialog<MediaFolderInfo?>(
      context: context,
      builder: (context) => AddMediaFolderDialog(mediaFolderInfo: item),
    ).then((MediaFolderInfo? response) {
      if (response != null) {
        response.status = .updated;
        setState(() {
          if (index >= 0) {
            _items[index] = response;
          } else {
            _items.add(response);
          }
        });
        _save();
      }
    });
  }

  void _scanFolder(MediaFolderInfo info) {
    setState(() => isDisabled = true);
    widget.onScan?.call(true);
    FolderScan.instance.process(info).then((_) {
      _getData();
      if (mounted) {
        setState(() => isDisabled = false);
        widget.onScan?.call(false);
      }
    });
  }

  void _save() {
    setState(() => isDisabled = true);
    widget.onScan?.call(true);
    MediaDataAccess.instance.publishMediaFolders(_items).then((_) {
      _getData();
      if (mounted) {
        setState(() => isDisabled = false);
        widget.onScan?.call(false);
      }
    });
  }
}

// =========================================================================================================
class AddMediaFolderDialog extends StatefulWidget {
  final MediaFolderInfo? mediaFolderInfo;
  const new({super.key, required this.mediaFolderInfo});

  @override
  State<AddMediaFolderDialog> createState() => _AddMediaFolderDialogState();
}

class _AddMediaFolderDialogState extends State<AddMediaFolderDialog> with Translate {
  late final TextEditingController _tecFolder;
  bool _monitored = false;
  late final MediaFolderInfo _response;

  @override
  void initState() {
    _response = widget.mediaFolderInfo ?? MediaFolderInfo("");

    _tecFolder = TextEditingController(text: widget.mediaFolderInfo?.path ?? '');
    _monitored = widget.mediaFolderInfo?.monitor ?? false;

    super.initState();
  }

  @override
  void dispose() {
    _tecFolder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: SimpleDialog(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        contentPadding: Constants.doublePadding,
        alignment: Alignment.center,
        title: Text(translate('Add Media Folder')),
        children: [
          TextField(
            autofocus: true,
            controller: _tecFolder,
            decoration: Constants.inputDecoration(
              translate("Media Folder"),
              suffix: IconButton(
                onPressed: () {
                  FilePicker.getDirectoryPath(
                    initialDirectory: _tecFolder.text.isNotEmpty
                        ? _tecFolder.text
                        : Platform.isWindows
                        ? r"C:\"
                        : "/",
                  ).then((value) => _tecFolder.text = value ?? _tecFolder.text);
                },
                icon: Icon(Icons.folder),
              ),
            ),
          ),
          SwitchListTile(title: Text(translate("Scan on Start")), value: _monitored, onChanged: (value) => setState(() => _monitored = value)),
          Constants.singleSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
              ElevatedButton(
                onPressed: () {
                  _response
                    ..lastUpdated = null
                    ..monitor = _monitored
                    ..path = _tecFolder.text;

                  Navigator.pop(context, _response);
                },
                child: Text(translate('Okay')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
