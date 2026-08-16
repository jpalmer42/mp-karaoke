import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/constants.dart';

class StatusBarWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<StatusBarWidget> createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> {
  final List<StatusInfo> status = [StatusInfo("My Status 1"), StatusInfo("My Status 2")];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blueGrey[900],
      child: Row(
        children: List.generate(
          status.length,
          (index) {
            return Container(
              margin: Constants.halfPadding,
              padding: .fromLTRB(10, 4, 10, 6),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Text(status[index].text),
            );
          },
        ),
      ),
    );
  }
}

class StatusInfo {
  String text;
  StatusInfo(this.text);
}
