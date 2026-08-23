import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Roster/add_singer_dialog.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/roster_item.dart';
import 'package:mp_karaoke_ui/Services/queue_stream.dart';
import 'package:mp_karaoke_ui/config.dart';

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
          trailing: Row(
            mainAxisSize: .min,
            children: [
              IconButton.filledTonal(
                // color: Colors.yellow,
                onPressed: () {
                  AddSingerDialog.showTheDialog(context).then((patron) {
                    if (patron != null) {
                      QueueStream.instance.addSinger(patron);
                    }
                  });
                },
                icon: Icon(Icons.add),
              ),
            ],
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
          onReorderItem: //
          (oldIndex, newIndex) =>
              QueueStream.instance.onReorderItem(oldIndex, newIndex),
          itemBuilder: (context, index) {
            final item = roster[index];
            return ReorderableDragStartListener(
              key: ValueKey(item),
              index: index,
              child: ListTile(
                title: Badge(
                  label: Text('${item.patron.id}'),
                  child: Text(item.patron.name),
                ),
                subtitle: item.patron.homeVenue != AppConfig.instance.currentVenue.nameCity
                    ? Text(
                        item.patron.homeVenue ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
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

// class DialogDropdown extends StatefulWidget {
//   final Widget child;
//   final List<Widget> items;
//   final ValueChanged<int?>? onSelected;

//   const DialogDropdown({
//     super.key,
//     required this.child,
//     required this.items,
//     this.onSelected,
//   });

//   @override
//   State<DialogDropdown> createState() => _DialogDropdownState();
// }

// class _DialogDropdownState extends State<DialogDropdown> {
//   final LayerLink _layerLink = LayerLink();
//   bool _isOpen = false;
//   OverlayEntry? _overlayEntry;

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: GestureDetector(
//         onTap: _toggleDropdown,
//         child: widget.child,
//       ),
//     );
//   }

//   void _toggleDropdown() {
//     if (_isOpen) {
//       _closeDropdown();
//     } else {
//       _showDropdown();
//     }
//   }

//   void _showDropdown() {
//     final renderBox = context.findRenderObject() as RenderBox;
//     final size = renderBox.size;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: size.width,
//         child: CompositedTransformFollower(
//           link: _layerLink,
//           showWhenUnlinked: false,
//           offset: Offset(0, size.height),
//           child: Material(
//             elevation: 4,
//             child: ListView(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               children: widget.items
//                   .asMap()
//                   .entries
//                   .map(
//                     (entry) => ListTile(
//                       title: entry.value,
//                       onTap: () {
//                         widget.onSelected?.call(entry.key);
//                         _closeDropdown();
//                       },
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(_overlayEntry!);
//     setState(() => _isOpen = true);
//   }

//   void _closeDropdown() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     setState(() => _isOpen = false);
//   }

//   @override
//   void dispose() {
//     _closeDropdown();
//     super.dispose();
//   }
// }
