import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/business_info.dart';
import 'package:mp_karaoke_ui/Services/buisness_data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';

class CompanyWidgetEntry extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BusinessDataAccess.instance.fetchBusiness(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CompanyWidget(businessInfo: snapshot.data);
        }
        return Constants.pleaseWait();
      },
    );
  }
}

class CompanyWidget extends StatefulWidget {
  final BusinessInfo? businessInfo;
  const new({super.key, required this.businessInfo});

  @override
  State<CompanyWidget> createState() => _CompanyWidgetState();
}

class _CompanyWidgetState extends State<CompanyWidget> with Translate {
  late final TextEditingController _tecCompanyName;

  late final TextEditingController _tecCarouselPath;
  late final TextEditingController _tecCarouselDuration;

  late final BusinessInfo _businessInfo;

  @override
  void initState() {
    _businessInfo = widget.businessInfo ?? BusinessInfo(name: "");

    _tecCompanyName = TextEditingController(text: _businessInfo.name);
    // convert the json string property to a json object
    final Map<String, dynamic> json = Map<String, dynamic>.from(
      jsonDecode(_businessInfo.json ?? '{}'),
    );

    _tecCarouselPath = TextEditingController(
      text: json['carouselImagePath'] as String? ?? '',
    );

    _tecCarouselDuration = TextEditingController(
      text: (json['carouselDuration'] as num?)?.toString() ?? '5',
    );
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
  void deactivate() async {
    await _save();
    super.deactivate();
  }

  Future<void> _save() async {
    _businessInfo.name = _tecCompanyName.text;
    var json = {
      "carouselImagePath": _tecCarouselPath.text,
      "carouselDuration": num.parse(_tecCarouselDuration.text),
    };
    _businessInfo.json = jsonEncode(json);
    _businessInfo.status = .updated;

    await BusinessDataAccess.instance.publishBusiness([_businessInfo]);
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
                  autofocus: true,
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
