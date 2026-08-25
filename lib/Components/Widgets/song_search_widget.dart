import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/track_info.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';

class SongSearchWidget extends StatefulWidget {
  const new({super.key});

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

  @override
  Widget build(BuildContext context) {
    final trailingStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
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
          controller: _controller,
          decoration: Constants.inputDecoration(translate('Title/Artist/Code')),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return ListTile(
                // dense: true,
                title: Text(
                  '${item.artist} - ${item.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${item.length}', style: trailingStyle),
                trailing: Text(item.code ?? '', style: trailingStyle),
              );
            },
          ),
        ),
      ],
    );
  }
}
