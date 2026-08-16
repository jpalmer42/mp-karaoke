import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';

class RosterListWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<RosterListWidget> createState() => _RosterListWidgetState();
}

class _RosterListWidgetState extends State<RosterListWidget> {
  final List<RosterItem> _roster = [];

  @override
  void initState() {
    _roster.add(RosterItem('Jeff'));
    _roster.add(RosterItem('Rob'));
    _roster.add(RosterItem('Bob'));
    _roster.add(RosterItem('Tracy'));
    _roster.add(RosterItem('Shelly'));
    _roster.add(RosterItem('Brando'));
    _roster.add(RosterItem('StarrAnne'));
    _roster.add(RosterItem('Safire'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      itemCount: _roster.length,

      onReorderItem: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final item = _roster.removeAt(oldIndex);
        _roster.insert(newIndex, item);
      },

      itemBuilder: (context, index) {
        return ReorderableDragStartListener(
          key: ValueKey(_roster[index]),
          index: index,
          child: ListTile(
            title: Text(_roster[index].singerName),
          ),
        );
      },
    );
  }
}
