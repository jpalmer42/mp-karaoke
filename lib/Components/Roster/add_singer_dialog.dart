import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/patron_info.dart';
import 'package:mp_karaoke_ui/Formatters/title_case_formatter.dart';
import 'package:mp_karaoke_ui/Services/patron_data_access.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:mp_karaoke_ui/constants.dart';

class AddSingerDialog extends StatefulWidget {
  const new({super.key});

  static Future<PatronInfo?> showTheDialog(BuildContext context) async {
    return showDialog<PatronInfo?>(
      context: context,
      builder: (context) => AddSingerDialog(),
    );
  }

  @override
  State<AddSingerDialog> createState() => _AddSingerDialogState();
}

class _AddSingerDialogState extends State<AddSingerDialog> with Translate {
  late final TextEditingController _tecName;

  @override
  void initState() {
    _tecName = TextEditingController(text: "");

    _tecName.addListener(
      () {
        if (_tecName.text.length >= 3) {
          PatronDataAccess.instance.searchPatronsByName(_tecName.text).then(
            (value) {
              setState(() {
                _items = value;
              });
            },
          );
        } else if (_tecName.text.length < 3) {
          setState(() {
            _items.clear();
          });
        }
      },
    );

    _focusNode.addListener(() {
      print(_focusNode.hasFocus);
    });

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context).requestFocus(_focusNode));
  }

  @override
  void dispose() {
    _tecName.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<PatronInfo> _items = [];
  final FocusNode _focusNode = FocusNode();

  PatronInfo? _selectedPatron;

  @override
  Widget build(BuildContext context) {
    final double width = 300;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        contentPadding: Constants.doublePadding,
        // alignment: Alignment.center,
        title: Text(translate('Add Singer')),
        content: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: .min,
            children: [
              DropdownMenu<PatronInfo?>(
                controller: _tecName,
                focusNode: _focusNode,
                width: width,
                // decorationBuilder: (context, controller) {},
                enableSearch: true,
                label: Text(translate("Search for Singer")),
                textInputAction: .next,
                inputFormatters: [TitleCaseFormatter()],
                // showTrailingIcon: false,
                // selectedTrailingIcon: IconButton(
                //   onPressed: () {
                //     setState(() {
                //       _tecName.clear();
                //       _items.clear();
                //     });
                //   },
                //   icon: Icon(Icons.clear),
                // ),
                dropdownMenuEntries: _items
                    .map(
                      (item) => DropdownMenuEntry(
                        value: item,
                        label: item.name,
                        labelWidget: ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.homeVenue ?? ''),
                        ),
                      ),
                    )
                    .toList(),

                onSelected: (value) {
                  if (value == null) {
                    _selectedPatron = PatronInfo(name: _tecName.text, homeVenue: AppConfig.instance.currentVenue.nameCity);
                  } else {
                    _selectedPatron = value;
                  }
                },
              ),
              Constants.singleSpace,
              SwitchListTile(
                value: true,
                onChanged: (bool value) {},
                title: Text(translate("Randomize 10 Fav")),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
          ElevatedButton(onPressed: () => Navigator.pop(context, _selectedPatron), child: Text(translate('Okay'))),
        ],
      ),

      // SimpleDialog(
      //   shape: RoundedRectangleBorder(
      //     side: BorderSide(
      //       color: Theme.of(context).colorScheme.onPrimaryContainer,
      //     ),
      //     borderRadius: BorderRadius.circular(15.0),
      //   ),
      //   backgroundColor: Theme.of(context).colorScheme.onPrimary,
      //   contentPadding: Constants.doublePadding,
      //   alignment: Alignment.center,
      //   title: Text(translate('Add Singer')),
      //   children: [
      //     DropdownMenu<PatronInfo?>(
      //       inputFormatters: [TitleCaseFormatter()],
      //       // showTrailingIcon: false,
      //       selectedTrailingIcon: IconButton(
      //         onPressed: () {
      //           setState(() {
      //             _tecName.clear();
      //             _items.clear();
      //           });
      //         },
      //         icon: Icon(Icons.clear),
      //       ),
      //       // decorationBuilder: (context, controller) {},
      //       width: width,
      //       focusNode: _focusNode,
      //       controller: _tecName,
      //       dropdownMenuEntries: _items
      //           .map(
      //             (item) => DropdownMenuEntry(
      //               value: item,
      //               label: item.name,
      //             ),
      //           )
      //           .toList(),
      //       onSelected: (value) {
      //         if (value == null) {
      //           print(_tecName.text);
      //         } else {
      //           print(value.name);
      //         }
      //       },
      //     ),
      //     Constants.singleSpace,
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
      //       ],
      //     ),
      //   ],
      // ),
    );
  }
}
