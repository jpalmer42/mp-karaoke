import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/business_info.dart';
import 'package:mp_karaoke_ui/Services/buisness_data_access.dart';
import 'package:mp_karaoke_ui/constants.dart';

class VenuesWidget extends StatefulWidget {
  const new({super.key});

  @override
  State<VenuesWidget> createState() => _VenuesWidgetState();
}

class _VenuesWidgetState extends State<VenuesWidget> with Translate {
  late final List<VenueInfo> _items = [];

  @override
  void initState() {
    _getData();
    super.initState();
  }

  void _getData() {
    if (mounted) {
      BusinessDataAccess.instance
          .fetchVenuesByBuisnessId(null)
          .then(
            (items) => setState(() {
              _items.clear();
              _items.addAll(items);
            }),
          );
    }
  }

  int selected = -1;
  bool isDisabled = false;
  @override
  Widget build(BuildContext context) {
    final visibleItems = _items.where((item) => item.status != .deleted).toList();

    return Constants.disableWidgetTree(
      isDisabled,
      showProgress: true,
      child: ListView(
        children: [
          ...List.generate(
            visibleItems.length,
            (index) {
              final item = visibleItems[index];

              return ListTile(
                selected: index == selected,
                selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                title: Text(item.name),
                titleTextStyle: Theme.of(context).textTheme.bodyLarge,
                // subtitle: _subTitle(item),
                subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                leading: IconButton(
                  onPressed: () => _addEdit(index),
                  icon: Icon(Icons.edit, color: Colors.blue),
                ),
                trailing: Row(
                  mainAxisSize: .min,
                  children: [
                    // if (item.monitor) Text(translate("Scan on Start")),
                    // if (item.id != null)
                    //   IconButton(
                    //     tooltip: 'Scan Now!',
                    //     icon: const Icon(Icons.refresh, color: Colors.green),
                    //     onPressed: () {
                    //       _scanFolder(item);
                    //     },
                    //   ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        item.status = .deleted;
                        _save();
                      },
                    ),
                  ],
                ),
                onTap: () => setState(() => selected = index),
              );
            },
          ),
          ListTile(
            title: TextButton.icon(label: Text(translate("Add")), onPressed: () => _addEdit(-1), icon: Icon(Icons.add)),
          ),
        ],
      ),
    );
  }

  void _addEdit(int index) {
    final VenueInfo? item = index >= 0 ? _items[index] : null;
    showDialog<VenueInfo?>(
      context: context,
      builder: (context) => AddVenueDialog(venueInfo: item),
    ).then((VenueInfo? response) {
      if (response != null) {
        response.status = .updated;
        setState(() {
          if (index >= 0) {
            _items[index] = response;
          } else {
            _items.add(response);
          }
        });
        _save();
      }
    });
  }

  void _save() {
    setState(() => isDisabled = true);
    BusinessDataAccess.instance.publishVenues(1, _items).then((_) {
      _getData();
      if (mounted) {
        setState(() => isDisabled = false);
      }
    });
  }
}

// =========================================================================================================
class AddVenueDialog extends StatefulWidget {
  final VenueInfo? venueInfo;
  const new({super.key, required this.venueInfo});

  @override
  State<AddVenueDialog> createState() => _AddVenueDialogState();
}

class _AddVenueDialogState extends State<AddVenueDialog> with Translate {
  late final TextEditingController _tecName;
  late final VenueInfo _response;

  @override
  void initState() {
    _response = widget.venueInfo ?? VenueInfo(businessId: 1, name: "");
    _tecName = TextEditingController(text: widget.venueInfo?.name ?? '');

    super.initState();
  }

  @override
  void dispose() {
    _tecName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
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
        title: Text(translate('Add Venue')),
        children: [
          TextField(
            autofocus: true,
            controller: _tecName,
            decoration: Constants.inputDecoration(
              translate("Venue Name"),
            ),
          ),
          Constants.singleSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(onPressed: () => Navigator.pop(context, null), child: Text(translate('Cancel'))),
              ElevatedButton(
                onPressed: () {
                  _response
                    ..lastUpdated = DateTime.now()
                    ..name = _tecName.text
                    ..status = .updated;

                  Navigator.pop(context, _response);
                },
                child: Text(translate('Okay')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
