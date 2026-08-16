import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Services/status_stream.dart';
import 'package:mp_karaoke_ui/constants.dart';

class StatusBarWidget extends StatelessWidget {
  const StatusBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: Constants.halfPadding,
      color: Theme.of(context).colorScheme.onTertiary,
      child: StreamBuilder(
        stream: StatusStream.instance.stream,
        builder: (context, state) {
          if (state.hasData) {
            final items = state.data!.values;
            return Row(
              children: items.map((item) {
                return Container(
                  margin: Constants.halfPadding,
                  padding: .fromLTRB(10, 4, 10, 6),
                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.tertiary)),
                  child: Text(item.text),
                );
              }).toList(),
            );
          } else {
            return Row();
          }
        },
      ),
    );
  }
}

class StatusInfo {
  String text;
  StatusInfo(this.text);
}
