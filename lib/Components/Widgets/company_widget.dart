import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/ex_state.dart';
import 'package:mp_karaoke_ui/constants.dart';

class CompanyWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<CompanyWidget> createState() => _CompanyWidgetState();
}

class _CompanyWidgetState extends ExState<CompanyWidget> {
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
    return Container(
      padding: Constants.doublePadding,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: _tecCompanyName,
                  decoration: Constants.inputDecoration(translate("Company Name")),
                ),
              ),
              Constants.singleSpace,
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(translate("Link Online"), textAlign: .center),
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
                    translate("Company Imagry"),
                    suffix: IconButton(
                      onPressed: () {
                        FilePicker.getDirectoryPath().then((value) => _tecCarouselPath.text = value ?? _tecCarouselPath.text);
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

                  decoration: Constants.inputDecoration(translate("Duration")),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
