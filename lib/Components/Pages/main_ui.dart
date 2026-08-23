import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Widgets/play_queue.dart';
import 'package:mp_karaoke_ui/Components/Roster/roster_list.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/business_info.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/config.dart';
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
    await MediaDataAccess.instance.refreshMonitored();

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

class AppDrawer extends StatefulWidget {
  const new({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with Translate {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ListTile(
            tileColor: Theme.of(context).colorScheme.onPrimary,
            title: Text(AppConfig.instance.currentBusiness.name),
            // dense: true,
          ),
          Constants.doubleSpace,
          DropdownMenu<VenueInfo>(
            selectOnly: true,
            label: Text(translate('Select Venue')),
            dropdownMenuEntries: AppConfig.instance.currentBusiness.venues!
                .map(
                  (venue) => DropdownMenuEntry(
                    value: venue,
                    label: '${venue.name} - ${venue.city}',
                  ),
                )
                .toList(),
            initialSelection: AppConfig.instance.currentVenue,
            onSelected: (venue) {
              setState(() {
                AppConfig.instance.currentVenue = venue!;
                // selectedVenue = venue;
              });
            },
            // width: double.infinity,
          ),
        ],
      ),
    );
  }
}
