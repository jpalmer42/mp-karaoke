import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';

class RosterListWidget extends StatefulWidget {
  const RosterListWidget({super.key});

  @override
  State<RosterListWidget> createState() => _RosterListWidgetState();
}

class _RosterListWidgetState extends State<RosterListWidget> {
  final List<RosterItem> _roster = [];
  int? selected;

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
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.primary,
          child: Text(
            'ROSTER',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 8,
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: _roster.length,
              onReorderItem: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final item = _roster.removeAt(oldIndex);
                _roster.insert(newIndex, item);

                if (selected == oldIndex) {
                  selected = newIndex;
                } else if (selected != null) {
                  if (oldIndex < selected! && newIndex >= selected!) {
                    selected = selected! - 1;
                  } else if (oldIndex > selected! && newIndex <= selected!) {
                    selected = selected! + 1;
                  }
                }

                setState(() {});
              },
              itemBuilder: (context, index) {
                final item = _roster[index];
                final isSelected = selected == index;

                return ReorderableDragStartListener(
                  key: ValueKey(item),
                  index: index,
                  child: ListTile(
                    tileColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : null,
                    title: Text(item.singerName),
                    onTap: () {
                      setState(() {
                        selected = index;
                      });
                    },
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
