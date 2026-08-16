import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Pages/main_ui.dart';
import 'package:mp_karaoke_ui/Components/Pages/onboard_wizard/onboard.dart';
import 'package:mp_karaoke_ui/Components/Widgets/status_bar_widget.dart';
import 'package:mp_karaoke_ui/Services/data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';
import 'package:mp_karaoke_ui/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1024, 768),
    center: true,
    backgroundColor: Colors.transparent,
    // skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    List<Display> displays = await screenRetriever.getAllDisplays();

    if (displays.length > 1) {
      Display secondaryDisplay = displays[2];
      Offset topLeft = secondaryDisplay.visiblePosition!; // ?? secondaryDisplay.position;

      var scFactor = 1.25; //secondaryDisplay.scaleFactor!.toDouble();
      await windowManager.setPosition(topLeft.scale(scFactor, scFactor));
    }

    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MainApp());
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
                    return snapshot.data == false ? MainUIPage() : OnboardWizard();
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
