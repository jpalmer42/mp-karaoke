import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/patron_info.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';
import 'package:mp_karaoke_ui/Services/patron_data_access.dart';
import 'package:mp_karaoke_ui/Services/queue_stream.dart';
import 'package:mp_karaoke_ui/constants.dart';

class RosterListWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<RosterListWidget> createState() => _RosterListWidgetState();
}

class _RosterListWidgetState extends State<RosterListWidget> with Translate {
  final ScrollController _scrollController = ScrollController();
  Key rolvKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final List<RosterItem> _roster = [];
    return Column(
      children: [
        ListTile(
          tileColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(
            'Singers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              showDialog<PatronInfo?>(
                context: context,
                builder: (context) => AddPatronDialog(),
              ).then((patron) {
                if (patron != null) {
                  QueueStream.instance.addSinger(patron);
                }
              });
            },
            icon: Icon(Icons.add),
          ),
        ),
        StreamBuilder(
          stream: QueueStream.instance.rosterStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return _list(snapshot.data!);
            }
            return _list([]);
          },
        ),
      ],
    );
  }

  Widget _list(List<RosterItem> roster) {
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 8,
        child: ReorderableListView.builder(
          scrollController: _scrollController,
          key: rolvKey,
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          itemCount: roster.length,
          onReorderItem: (oldIndex, newIndex) => QueueStream.instance.onReorderItem(oldIndex, newIndex),
          itemBuilder: (context, index) {
            final item = roster[index];
            return ReorderableDragStartListener(
              key: ValueKey(item),
              index: index,
              child: ListTile(
                title: Text(item.patron.name),
                trailing: Row(
                  mainAxisSize: .min,
                  children: [
                    RawChip(label: Text('${item.patron.currentHistory.length} of ${item.tracks.length}'), tooltip: translate('Sung')),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AddPatronDialog extends StatefulWidget {
  const new({super.key});

  @override
  State<AddPatronDialog> createState() => _AddPatronDialogState();
}

class _AddPatronDialogState extends State<AddPatronDialog> with Translate {
  late final TextEditingController _tecName;

  @override
  void initState() {
    _tecName = TextEditingController(text: "");
    super.initState();
  }

  @override
  void dispose() {
    _tecName.dispose();
    super.dispose();
  }

  List<PatronInfo> _items = [];
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: SizedBox(
        width: 500,
        height: 500,
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
          title: Text(translate('Add Singer')),
          children: [
            TextField(
              autofocus: true,
              textCapitalization: .words,
              controller: _tecName,
              onChanged: (value) {
                PatronDataAccess.instance
                    .searchPatronsByName(value)
                    .then(
                      (result) => setState(() {
                        _items = result;
                      }),
                    );
              },
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.homeVenue ?? ''),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  );
                },
              ),
            ),

            Constants.singleSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
