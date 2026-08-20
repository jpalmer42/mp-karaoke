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
  final ScrollController _scrollController = ScrollController();
  Key rolvKey = GlobalKey();

  @override
  void initState() {
    _queue.add(PlayQueueItem(RosterItem('jeff')));
    _queue.add(PlayQueueItem(RosterItem('bob')));
    _queue.add(PlayQueueItem(RosterItem('killer')));

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.onPrimary,
          child: Text(
            'Play Queue',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: 8,
            child: ReorderableListView.builder(
              scrollController: _scrollController,
              key: rolvKey,
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              itemCount: _queue.length,

              onReorderItem: (oldIndex, newIndex) {
                if (oldIndex < newIndex) newIndex++;
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
                    leading: Text('3:54'), //${item.rosterItem.tracks.first.length}
                    title: Text(item.rosterItem.singerName),
                    trailing: Text('count'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
