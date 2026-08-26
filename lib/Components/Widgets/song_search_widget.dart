import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/track_info.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';

class SongSearchWidget extends StatefulWidget {
  final FocusNode searchFocusNode;
  const new({super.key, required this.searchFocusNode});

  @override
  State<SongSearchWidget> createState() => _SongSearchWidgetState();
}

class _SongSearchWidgetState extends State<SongSearchWidget> with Translate {
  final List<TrackInfo> _items = [];
  late final ScrollController _scrollController;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    _scrollController = ScrollController();
    _controller.addListener(_onTextChanged);
    super.initState();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(300.milliseconds, () {
      final value = _controller.text.trim();
      if (value.length >= 3) {
        MediaDataAccess.instance.searchTracks(value).then((results) {
          setState(() {
            _items.clear();
            _items.addAll(results);
          });
        });
      } else {
        setState(() {
          _items.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel(); // Prevent callbacks after widget disposal
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _clearContent() {
    setState(() {
      _controller.clear();
      _items.clear();
      _selected = -1;
    });
  }

  int _selected = -1;
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final trailingStyle = Theme.of(context).textTheme.bodySmall;
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.escape:
              _clearContent();
              break;
            case LogicalKeyboardKey.arrowUp:
              setState(() {
                _selected = _selected > 1 ? _selected-- : 0;
              });
              break;
            case LogicalKeyboardKey.arrowDown:
              setState(() {
                final len = _items.length - 1;
                _selected = _selected < len ? _selected++ : len;
              });
              break;
            // default:
            // return KeyEventResult.ignored;
          }
        }
        // return KeyEventResult.handled;
      },

      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.onPrimary,
            child: Text(
              'Search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextField(
            focusNode: widget.searchFocusNode,
            controller: _controller,
            decoration: Constants.inputDecoration(
              translate('Title/Artist/Code'),
              suffix: Badge(
                alignment: .center,
                label: Text('${_items.length}'),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Draggable(
                  data: item,

                  feedback: Material(
                    elevation: 4.0,
                    child: SizedBox(
                      width: 300,
                      child: ListTile(
                        title: Text(item.title ?? ''),
                      ),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selected = index;
                      });
                    },
                    selected: index == _selected,
                    selectedTileColor: Theme.of(context).colorScheme.onSecondary,
                    // dense: true,
                    title: Text(
                      item.artist ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .end,
                      children: [
                        Text(item.code ?? '', style: trailingStyle),
                        Text(item.lengthStr, style: trailingStyle),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
