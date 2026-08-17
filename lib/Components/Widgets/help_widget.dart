import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mp_karaoke_ui/constants.dart';

class HelpWidget extends StatelessWidget {
  final String helpFile;
  const new({super.key, required this.helpFile});

  @override
  Widget build(BuildContext context) {
    var futureString = getHtml(helpFile);
    return FutureBuilder<String>(
      future: futureString,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HtmlWidget(snapshot.data ?? '');
        }
        if (snapshot.hasError) {
          return Text(
            "Error Loading: $helpFile - ${snapshot.error}",
            textAlign: .center,
          );
        }
        return Constants.pleaseWait();
      },
    );
  }

  Future<String> getHtml(String htmlFile) async {
    return await rootBundle.loadString('assets/translations/${htmlFile}_en.html');
  }
}
