import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Domain/play_queue_item.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';

class PlayQueueWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<PlayQueueWidget> createState() => _PlayQueueWidgetState();
}

class _PlayQueueWidgetState extends State<PlayQueueWidget> {
  final List<PlayQueueItem> _queue = [];

  @override
  void initState() {
    _queue.add(PlayQueueItem(RosterItem('jeff')));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      itemCount: _queue.length,

      onReorderItem: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final item = _queue.removeAt(oldIndex);
        _queue.insert(newIndex, item);
      },

      itemBuilder: (context, index) {
        final item = _queue[index];
        return ReorderableDragStartListener(
          key: ValueKey(item),
          index: index,
          child: ListTile(
            title: Text(item.rosterItem.singerName),
          ),
        );
      },
    );
  }
}
