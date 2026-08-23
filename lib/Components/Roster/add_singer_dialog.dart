import 'dart:ui';

import 'package:flutter/material.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    _tecName.dispose();
    super.dispose();
  }

  List<PatronInfo> _items = [];
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: SizedBox(
        width: 500,
        height: 500,
        child: SimpleDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          contentPadding: Constants.doublePadding,
          alignment: Alignment.center,
          title: Text(translate('Add Singer')),
          children: [
            TextField(
              inputFormatters: [TitleCaseFormatter()],
              autofocus: true,
              textCapitalization: .words,
              keyboardType: .name,
              onEditingComplete: () {
                final name = _tecName.text.trim();
                if (name.length < 3) return;

                PatronInfo? response = PatronInfo(name: name, homeVenue: AppConfig.instance.currentVenue.nameCity);
                Navigator.pop(context, response);

                // final nameLower = name.toLowerCase();
                // // Search results for same name
                // final matches = _items.where((item) {
                //   return item.name.toLowerCase().contains(nameLower);
                // });

                // if (matches.length == 1) {
                //   response = matches.first;
                // } else if (matches.length > 1) {
                //   final list = matches.toList();
                //   list.insert(0, PatronInfo(name: name, homeVenue: AppConfig.instance.currentVenue.nameCity));
                //   PatronConflict.showTheDialog(context, list).then((value) {
                //     if (context.mounted) {
                //       Navigator.pop(context, value);
                //     }
                //   });
                // } else {
                //   Navigator.pop(context, response);
                // }
              },
              controller: _tecName,
              onChanged: (value) {
                if (value.trim().length >= 3) {
                  PatronDataAccess.instance.searchPatronsByName(value).then((result) => setState(() => _items = result));
                } else {
                  setState(() {
                    _items.clear();
                  });
                }
              },
              decoration: Constants.inputDecoration(
                "Name",
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _items.clear();
                      _tecName.clear();
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              ),
            ),
            SizedBox(
              height: 300,
              width: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text(item.homeVenue ?? ''),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  );
                },
              ),
            ),

            Constants.singleSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class PatronConflict extends StatefulWidget {
//   final List<PatronInfo> patrons;
//   const new({super.key, required this.patrons});

//   static Future<PatronInfo?> showTheDialog(BuildContext context, List<PatronInfo> patrons) async {
//     return showDialog<PatronInfo?>(
//       context: context,
//       builder: (context) => PatronConflict(patrons: patrons),
//     );
//   }

//   @override
//   State<PatronConflict> createState() => _PatronConflictState();
// }

// class _PatronConflictState extends State<PatronConflict> with Translate {
//   @override
//   Widget build(BuildContext context) {
//     return BackdropFilter(
//       filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
//       child: SizedBox(
//         width: 500,
//         height: 500,
//         child: SimpleDialog(
//           shape: RoundedRectangleBorder(
//             side: BorderSide(
//               color: Theme.of(context).colorScheme.onPrimaryContainer,
//             ),
//             borderRadius: BorderRadius.circular(15.0),
//           ),
//           backgroundColor: Theme.of(context).colorScheme.onPrimary,
//           contentPadding: Constants.doublePadding,
//           alignment: Alignment.center,
//           title: Text(translate('Conflict')),
//           children: [
//             ...List.generate(
//               widget.patrons.length,
//               (index) {
//                 final item = widget.patrons[index];
//                 return ListTile(
//                   title: Text(item.name),
//                   subtitle: Text(item.homeVenue ?? ''),
//                   onTap: () {
//                     Navigator.pop(context, item);
//                   },
//                 ) //
//                 ;
//               },
//             ),
//             Constants.singleSpace,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
