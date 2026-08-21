import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';

class RosterListWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<RosterListWidget> createState() => _RosterListWidgetState();
}

class _RosterListWidgetState extends State<RosterListWidget> {
  final List<RosterItem> _roster = [];
  final ScrollController _scrollController = ScrollController();
  Key rolvKey = GlobalKey();

  @override
  void initState() {
    //todo: load Roster stream
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
            'Singers',
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
              itemCount: _roster.length,

              onReorderItem: (oldIndex, newIndex) {
                if (oldIndex < newIndex) newIndex++;
                if (newIndex > oldIndex) newIndex--;
                final item = _roster.removeAt(oldIndex);
                _roster.insert(newIndex, item);
              },

              itemBuilder: (context, index) {
                final item = _roster[index];
                return ReorderableDragStartListener(
                  key: ValueKey(item),
                  index: index,
                  child: ListTile(
                    title: Text(item.patron.name),
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
