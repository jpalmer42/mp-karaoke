import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/Widgets/media_folders_widget.dart';
import 'package:mp_karaoke_ui/constants.dart';

class OnboardPage extends StatefulWidget {
  const new({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  late final TextEditingController _tecCompanyName;
  late final TextEditingController _tecCarouselPath;
  late final TextEditingController _tecCarouselDuration;
  @override
  void initState() {
    _tecCompanyName = TextEditingController(text: "");
    _tecCarouselPath = TextEditingController(text: "");
    _tecCarouselDuration = TextEditingController(text: "5");
    super.initState();
  }

  @override
  void dispose() {
    _tecCompanyName.dispose();
    _tecCarouselPath.dispose();
    _tecCarouselDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          actionsPadding: EdgeInsets.fromLTRB(0, 0, 8, 0),
          title: Constants.appBarTitle(context, subTitle: "Onboarding"),
          actions: [
            ElevatedButton.icon(icon: Icon(Icons.save), onPressed: () => _save(), label: Text('Save')),
          ],
        ),
        body: Container(
          padding: Constants.singlePadding,
          alignment: Alignment.center,
          child: SizedBox(
            width: 500,
            child: Card(
              child: Container(
                padding: Constants.doublePadding,
                child: Column(
                  crossAxisAlignment: .start,
                  // mainAxisSize: .min,
                  children: [
                    Constants.doubleSpace,
                    _onboardMessage(),
                    Constants.singleSpace,
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            textCapitalization: TextCapitalization.words,
                            controller: _tecCompanyName,
                            decoration: Constants.inputDecoration("Company Name"),
                          ),
                        ),
                        Constants.singleSpace,
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: Text("Link Online", textAlign: .center),
                          ),
                        ),
                      ],
                    ),
                    Constants.doubleSpace,
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _tecCarouselPath,
                            decoration: Constants.inputDecoration(
                              "Inter-song Imagry",
                              suffix: IconButton(
                                onPressed: () {
                                  FilePicker.getDirectoryPath().then((value) => _tecCarouselPath.text = value ?? '');
                                },
                                icon: Icon(Icons.folder),
                              ),
                            ),
                          ),
                        ),
                        Constants.singleSpace,
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _tecCarouselDuration,
                            keyboardType: TextInputType.number,
                            maxLength: 2,

                            decoration: Constants.inputDecoration(
                              "Duration",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Constants.singleSpace,
                    Divider(),
                    Expanded(
                      child: Container(
                        padding: Constants.singlePadding,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text("Media Locations", style: Theme.of(context).textTheme.titleMedium),
                            Expanded(child: MediaFoldersWidget()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    // TODO???
  }

  Widget _onboardMessage() {
    return Text("Info About Onboard");
  }
}
