import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Pages/main_ui.dart';
import 'package:mp_karaoke_ui/Components/Pages/onboard_wizard/onboard.dart';
import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:mp_karaoke_ui/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();

  WakelockPlus.enable();
  await windowManager.ensureInitialized();

  await AppWrapper.onStart();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //
      theme: MyTheme().buildTheme(context),
      //
      home: AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  // final Widget child;
  const new({super.key});

  static Future<void> onStart() async {
    final prefs = AppConfig.instance.prefs;

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

    return;
  }

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WindowListener {
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
    final prefs = AppConfig.instance.prefs;

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

  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Navigator(
              key: _innerNavigatorKey,
              initialRoute: AppConfig.instance.prefs.getBool(AppConfig.spInitialized) == true ? 'mainUI' : 'onboard',
              onGenerateRoute: (settings) {
                WidgetBuilder builder;
                switch (settings.name) {
                  case 'mainUI':
                    builder = (BuildContext _) => const MainUIPage();
                    break;
                  case 'onboard':
                    builder = (BuildContext _) => const OnboardWizard();
                    break;
                  default:
                    throw Exception('Invalid route: ${settings.name}');
                }
                return MaterialPageRoute(builder: builder, settings: settings);
              },
            ),
          ),
          // Expanded(child: widget.child),
          StatusBarWidget(),
        ],
      ),
    );
  }
}
