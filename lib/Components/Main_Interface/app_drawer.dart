import 'package:flutter/material.dart';
import 'package:mp_karaoke_ui/Components/translate_mixin.dart';
import 'package:mp_karaoke_ui/Domain/business_info.dart';
import 'package:mp_karaoke_ui/config.dart';
import 'package:mp_karaoke_ui/constants.dart';

class AppDrawer extends StatefulWidget {
  const new({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with Translate {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        // mainAxisAlignment: .spaceBetween,
        crossAxisAlignment: .center,
        children: [
          ListTile(
            tileColor: Theme.of(context).colorScheme.onPrimary,
            title: Text(AppConfig.instance.currentBusiness.name),
            // dense: true,
          ),
          Constants.doubleSpace,
          DropdownMenu<VenueInfo>(
            selectOnly: true,
            label: Text(translate('Select Venue')),
            dropdownMenuEntries: AppConfig.instance.currentBusiness.venues!
                .map(
                  (venue) => DropdownMenuEntry(
                    value: venue,
                    label: '${venue.name} - ${venue.city}',
                  ),
                )
                .toList(),
            initialSelection: AppConfig.instance.currentVenue,
            onSelected: (venue) {
              setState(() {
                AppConfig.instance.currentVenue = venue!;
                // selectedVenue = venue;
              });
            },
            // width: double.infinity,
          ),
          Spacer(),
          Container(
            padding: Constants.halfPadding,
            alignment: .centerEnd,
            child: Text('v${AppConfig.instance.packageInfo.version}'),
          ),
        ],
      ),
    );
  }
}
