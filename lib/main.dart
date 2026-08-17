import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Pages/main_ui.dart';
import 'package:mp_karaoke_ui/Components/Pages/onboard_wizard/onboard.dart';
import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';
import 'package:mp_karaoke_ui/Services/data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';
import 'package:mp_karaoke_ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  await windowManager.ensureInitialized();

  await windowManagerStuff();

  runApp(const MainApp());
}

Future<void> windowManagerStuff() async {
  final prefs = await SharedPreferences.getInstance();

  double? x = prefs.getDouble('win_x');
  double? y = prefs.getDouble('win_y');
  double? width = prefs.getDouble('win_width');
  double? height = prefs.getDouble('win_height');
  bool isMaximized = prefs.getBool('win_maximized') ?? false;

  WindowOptions windowOptions = WindowOptions(
    size: Size(width ?? 1000, height ?? 700),
    center: (x == null || y == null), // Center if no saved position exists
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (x != null && y != null) {
      await windowManager.setPosition(Offset(x, y));
    }
    if (isMaximized) {
      await windowManager.maximize();
    }
    await windowManager.show();
    await windowManager.focus();
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: MyTheme().buildTheme(context),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: DataAccess.instance.firstTime(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return AppListener(child: snapshot.data == false ? MainUIPage() : OnboardWizard());
                  } else if (snapshot.hasError) {
                    return Constants.unrecoverable(message: snapshot.error.toString());
                  } else {
                    return Constants.pleaseWait();
                  }
                },
              ),
            ),
            StatusBarWidget(),
          ],
        ),
      ),
    );
  }
}

class AppListener extends StatefulWidget {
  final Widget child;
  const new({super.key, required this.child});

  @override
  State<AppListener> createState() => _AppListenerState();
}

class _AppListenerState extends State<AppListener> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final prefs = await SharedPreferences.getInstance();

    bool maximized = await windowManager.isMaximized();
    await prefs.setBool('win_maximized', maximized);

    if (!maximized) {
      Offset position = await windowManager.getPosition();
      Size size = await windowManager.getSize();

      await prefs.setDouble('win_x', position.dx);
      await prefs.setDouble('win_y', position.dy);
      await prefs.setDouble('win_width', size.width);
      await prefs.setDouble('win_height', size.height);
    }

    windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
