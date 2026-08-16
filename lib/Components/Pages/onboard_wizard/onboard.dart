import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Widgets/company_widget.dart';
import 'package:mp_karaoke_ui/Components/Widgets/media_folders_widget.dart';
import 'package:mp_karaoke_ui/Components/ex_state.dart';
import 'package:mp_karaoke_ui/constants.dart';

class OnboardWizard extends StatefulWidget {
  const new({super.key});

  @override
  State<OnboardWizard> createState() => _OnboardWizardState();
}

class _OnboardWizardState extends ExState<OnboardWizard> {
  int _index = 0;
  final List<Widget> _wigets = [];

  @override
  void initState() {
    _wigets.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_wigets.isEmpty) {
      _wigets.add(_wrapTitle(translate("Company Information"), child: CompanyWidget()));
      _wigets.add(_wrapTitle(translate("Media Information"), child: MediaFoldersWidget()));
      _wigets.add(Text("Finish"));
    }
    return Scaffold(
      appBar: AppBar(
        title: Constants.appBarTitle(context, subTitle: translate("Onboarding Wizard")),
        actionsPadding: EdgeInsets.symmetric(horizontal: 8),
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            label: Text(translate("Skip")),
            icon: Icon(Icons.skip_next),
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
              icon: Icon(Icons.skip_previous),
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
              icon: Icon(Icons.skip_next),
            ),
          if (_index == _wigets.length - 2)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _index++;
                });
              },
              label: Text(translate("Finish")),
              icon: Icon(Icons.flag),
            ),
        ],
      ),
    );
  }

  Widget _wrapTitle(String title, {required Widget child}) {
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
          ],
        ),
      ),
    );
  }
}
