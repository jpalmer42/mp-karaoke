import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/track_info.dart';
import 'package:mp_karaoke_ui/Services/queue_stream.dart';

class PlayQueueWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<PlayQueueWidget> createState() => _PlayQueueWidgetState();
}

class _PlayQueueWidgetState extends State<PlayQueueWidget> with Translate {
  final ScrollController _scrollController = ScrollController();
  Key rolvKey = GlobalKey();

  @override
  void initState() {
    //todo: load playQueue Stream
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
        ListTile(
          tileColor: Theme.of(context).colorScheme.onPrimary,
          title: Text(
            translate('Play Queue'),
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
                onPressed: () {},
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
        StreamBuilder(
          stream: QueueStream.instance.playQueueStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return _list(snapshot.data!);
            }
            return _list([]);
          },
        ),
      ],
    );
  }

  Widget _list(List<PlayQueueInfo> items) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          return ListTile(
            title: Text(item.singer),
            subtitle: Text(item.track.artist!),
          );
        },
      ),
    );
  }
}
