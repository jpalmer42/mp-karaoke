import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Widgets/company_widget.dart';
import 'package:mp_karaoke_ui/Components/Widgets/help_widget.dart';
import 'package:mp_karaoke_ui/Components/Widgets/media_folders_widget.dart';
import 'package:mp_karaoke_ui/Components/Widgets/venues_widget.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:mp_karaoke_ui/constants.dart';

class OnboardWizard extends StatefulWidget {
  const new({super.key});

  @override
  State<OnboardWizard> createState() => _OnboardWizardState();
}

class _OnboardWizardState extends State<OnboardWizard> with Translate {
  int _index = 0;
  final List<Widget> _wigets = [];

  @override
  void initState() {
    _wigets.clear();
    super.initState();
  }

  bool _disabled = false;
  @override
  Widget build(BuildContext context) {
    if (_wigets.isEmpty) {
      _wigets.add(_wrapTitle(translate("Company Information"), child: CompanyWidgetEntry(), help: 'company'));
      _wigets.add(
        _wrapTitle(
          translate("Media Information"),
          child: MediaFoldersWidget(
            onScan: (bool isScanning) => setState(() {
              _disabled = isScanning;
            }),
          ),
          help: 'media',
        ),
      );
      _wigets.add(_wrapTitle(translate("Venues"), child: VenuesWidget()));
      _wigets.add(Text("Finish"));
    }

    // -----------------===============----------------=================
    return Constants.disableWidgetTree(
      _disabled,
      child: Scaffold(
        appBar: AppBar(
          title: Constants.appBarTitle(context, subTitle: translate("Onboarding Wizard")),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8),
          actions: [
            ElevatedButton.icon(
              onPressed: () {},
              label: Text(translate("Skip")),
              icon: Icon(Icons.cancel, color: Colors.red),
            ),
          ],
        ),
        body: Container(
          margin: Constants.doublePadding,
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).colorScheme.onPrimary)),
          child: Column(
            children: [
              Expanded(child: _wigets[_index]),
              _navigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigation() {
    return Container(
      width: double.infinity,
      padding: Constants.doublePadding,
      color: Theme.of(context).colorScheme.onPrimary,
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: [
          if (_index > 0)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _index--;
                });
              },
              label: Text(translate("Back")),
              icon: Icon(Icons.chevron_left, color: Colors.blue),
            ),
          const Spacer(),
          if (_index < _wigets.length - 2)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _index++;
                });
              },
              label: Text(translate("Next")),
              icon: Icon(Icons.chevron_right, color: Colors.green),
            ),
          if (_index == _wigets.length - 2)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  AppConfig.instance.prefs.setBool(AppConfig.spInitialized, true);
                  Navigator.of(context).pushNamedAndRemoveUntil('mainUI', (_) => false);
                });
              },
              label: Text(translate("Finish")),
              icon: Icon(Icons.flag, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _wrapTitle(String title, {required Widget child, String? help}) {
    return Container(
      width: double.infinity,
      padding: Constants.doublePadding,
      color: Theme.of(context).canvasColor,

      child: Card(
        child: Column(
          children: [
            Padding(
              padding: Constants.singlePadding,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const Divider(),
            Expanded(child: child),
            if (help != null) _showHelp(help),
          ],
        ),
      ),
    );
  }

  Widget _showHelp(String help) {
    return Container(
      width: double.infinity,
      padding: Constants.singlePadding,
      child: HelpWidget(helpFile: help),
    );
  }
}
