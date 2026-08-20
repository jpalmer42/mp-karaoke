import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Widgets/play_queue.dart';
import 'package:mp_karaoke_ui/Components/Widgets/roster_list.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';

class PreUI extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _preload(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainUIPage();
        }
        return Constants.pleaseWait();
      },
    );
  }

  Future<Object> _preload() async {
    // await MediaDataAccess.instance.refreshMonitored();

    // Load venue info
    // Load singers
    // Load playlist
    return '';
  }
}

class MainUIPage extends StatefulWidget with Translate {
  const new({super.key});

  @override
  State<MainUIPage> createState() => _MainUIPageState();
}

class _MainUIPageState extends State<MainUIPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MP-Karoake'),
        actions: [ElevatedButton(onPressed: () {}, child: Text('action'))],
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                child: Text('SongList'),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Text('A Drawer'),
    );
  }
}
