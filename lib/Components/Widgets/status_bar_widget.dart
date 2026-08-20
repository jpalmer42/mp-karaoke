import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Services/status_stream.dart';
import 'package:mp_karaoke_ui/constants.dart';
import 'package:window_manager/window_manager.dart';

class StatusBarWidget extends StatefulWidget {
  const StatusBarWidget({super.key});

  @override
  State<StatusBarWidget> createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> with Translate {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      padding: Constants.halfPadding,
      color: Theme.of(context).colorScheme.onTertiary,
      child: StreamBuilder(
        stream: StatusStream.instance.stream,
        builder: (context, state) {
          final items = state.data ?? [];
          return Row(
            children: [
              ...List.generate(items.length, (index) {
                final item = items[index];
                return Container(
                  margin: .fromLTRB(0, 0, 4, 0),
                  padding: .fromLTRB(10, 4, 10, 6),
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
                  child: Text(item.text),
                );
              }),
              const Spacer(),
              TextButton(onPressed: _fullScreenToggle, child: Text(translate(_fullScreen ? "Windowed" : "Full Screen"))),
            ],
          );
        },
      ),
    );
  }

  bool _fullScreen = false;

  void _fullScreenToggle() {
    setState(() {
      _fullScreen = !_fullScreen;
      windowManager.setFullScreen(_fullScreen).then((_) {});
    });
  }
}

class StatusInfo {
  String text;
  Icon? icon;
  StatusInfo(this.text, {this.icon});

  @override
  String toString() {
    return text;
  }
}
