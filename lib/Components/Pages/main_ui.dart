import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Widgets/play_queue.dart';
import 'package:mp_karaoke_ui/Components/Widgets/roster_list.dart';

class MainUIPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MP-Karoake'),
        actions: [ElevatedButton(onPressed: () {}, child: Text('action'))],
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: RosterListWidget(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: PlayQueueWidget(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                      child: Text('3'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 100,
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: Text('4'),
            ),
          ],
        ),
      ),
    );
  }
}
