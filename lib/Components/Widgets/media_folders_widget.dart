import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Architecture/child_controller.dart';
import 'package:mp_karaoke_ui/Components/ex_state.dart';
import 'package:mp_karaoke_ui/Domain/media_folder.dart';
import 'package:mp_karaoke_ui/Services/data_access.dart';
import 'package:mp_karaoke_ui/Services/folder_scan.dart';
import 'package:mp_karaoke_ui/constants.dart';

class MediaFoldersWidget extends StatefulWidget {
  final ChildController controller;
  const new({super.key, required this.controller});

  @override
  State<MediaFoldersWidget> createState() => _MediaFoldersWidgetState();
}

class _MediaFoldersWidgetState extends ExState<MediaFoldersWidget> {
  late final List<MediaFolderInfo> _items = [];

  @override
  void initState() {
    widget.controller.register(save);

    _getData();
    super.initState();
  }

  void _getData() {
    DataAccess.instance.fetchMediaFolders().then(
      (folders) => setState(() {
        _items.clear();
        _items.addAll(folders);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // _items.sort((a, b) => (a.id ?? 0).compareTo((b.id ?? 999)));

    final visibleItems = _items.where((item) => item.status != .deleted).toList();

    return ListView(
      children: [
        ...List.generate(
          visibleItems.length,
          (index) {
            final item = visibleItems[index];

            return ListTile(
              title: Text(item.path),
              titleTextStyle: Theme.of(context).textTheme.bodyLarge,
              subtitle: _subTitle(item),
              subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
              trailing: Row(
                mainAxisSize: .min,
                children: [
                  if (item.monitor) Text(translate("Scan on Start")),
                  if (item.id != null)
                    IconButton(
                      tooltip: 'Scan Now!',
                      icon: const Icon(Icons.refresh, color: Colors.green),
                      onPressed: () {
                        FolderScan.instance.process(item).then((_) => _getData());
                      },
                    ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => item.status = .deleted),
                  ),
                ],
              ),
              onTap: () => _edit(index),
            );
          },
        ),
        ListTile(
          title: TextButton.icon(label: Text(translate("Add")), onPressed: () => _edit(-1), icon: Icon(Icons.add)),
        ),
      ],
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

  void _edit(int index) {
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
      }
    });
  }

  void save() {
    DataAccess.instance.publishMediaFolders(_items).then((_) => _getData());
  }
}

// ==============================
class AddMediaFolderDialog extends StatefulWidget {
  final MediaFolderInfo? mediaFolderInfo;
  const new({super.key, required this.mediaFolderInfo});

  @override
  State<AddMediaFolderDialog> createState() => _AddMediaFolderDialogState();
}

class _AddMediaFolderDialogState extends ExState<AddMediaFolderDialog> {
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
