import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp_karaoke_ui/Components/Main_Interface/app_drawer.dart';
import 'package:mp_karaoke_ui/Components/Roster/add_singer_dialog.dart';
import 'package:mp_karaoke_ui/Components/Widgets/play_queue.dart';
import 'package:mp_karaoke_ui/Components/Roster/roster_list.dart';
import 'package:mp_karaoke_ui/Components/Widgets/song_search_widget.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Services/media_data_access.dart';
import 'package:mp_karaoke_ui/Services/queue_stream.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:mp_karaoke_ui/constants.dart';
import 'package:resizable_splitter/resizable_splitter.dart';

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

class _MainUIPageState extends State<MainUIPage> with Translate {
  final _focusNode = FocusNode();
  final _searchFocusNode = FocusNode(); // This is passed to the SongSearchWidget

  late final SplitterController _scDynamicList;
  late final SplitterController _scRosterList;

  @override
  void initState() {
    _scDynamicList = SplitterController(initialPosition: SplitterPosition.fraction(.3));
    _scRosterList = SplitterController(initialPosition: SplitterPosition.fraction(.5));
    super.initState();
  }

  @override
  void dispose() {
    _scDynamicList.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      onKeyEvent: (KeyEvent value) {
        _processKeyEvent(value);
      },
      autofocus: true,
      focusNode: _focusNode,
      //
      child: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Constants.appBarTitle(context, title: translate('MP-Karaoke'), subTitle: AppConfig.instance.currentVenue.nameCity),
            actions: [ElevatedButton(onPressed: () {}, child: Text('action'))],
          ),
          drawer: AppDrawer(),
          onDrawerChanged: (isOpened) {
            if (!isOpened) {
              setState(() {});
            }
          },
          body: ResizableSplitter(
            controller: _scDynamicList,
            start: SongSearchWidget(searchFocusNode: _searchFocusNode),
            end: ResizableSplitter(
              controller: _scRosterList,
              start: RosterListWidget(),
              end: PlayQueueWidget(),
            ),
          ),
        ),
      ),
    );
  }

  void _processKeyEvent(KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.insert || (event.logicalKey == LogicalKeyboardKey.numpad0)) {
      AddSingerDialog.showTheDialog(context).then((patron) {
        if (patron != null) {
          QueueStream.instance.addSinger(patron);
        }
      });
    } else //
    if (event.logicalKey.keyId >= 48 && event.logicalKey.keyId <= 122) {
      _searchFocusNode.requestFocus();
    }
  }
}
