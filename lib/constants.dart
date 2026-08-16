import 'package:flutter/material.dart';

class Constants {
  static const halfPadding = EdgeInsets.all(4);
  static const singlePadding = EdgeInsets.all(8);
  static const doublePadding = EdgeInsets.all(12);
  static const halfSpace = SizedBox(height: 4, width: 4);
  static const singleSpace = SizedBox(height: 8, width: 8);
  static const doubleSpace = SizedBox(height: 12, width: 12);

  static Widget pleaseWait({String message = "Please Wait...", Color? color}) {
    return Container(
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: Constants.doublePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              Constants.doubleSpace,
              RefreshProgressIndicator(color: color),
            ],
          ),
        ),
      ),
    );
  }

  static Widget unrecoverable({required String message, Color? color}) {
    return Container(
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: Constants.doublePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber,
                size: 48,
                color: Colors.red,
              ),
              Constants.doubleSpace,
              Text(message),
            ],
          ),
        ),
      ),
    );
  }

  static void message(BuildContext context, String message, {int timeout = 5}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: timeout),
      ),
    );
  }

  static Widget appBarTitle(BuildContext context, {String title = "MP-Karaoke", String? subTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        if (subTitle != null) Text(subTitle, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  static InputDecoration inputDecoration(
    String label, {
    Widget? prefix,
    Widget? suffix,
    bool? password,
    String? helper,
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: Constants.doublePadding,
      label: Text(label),
      prefixIcon: prefix,
      suffixIcon: suffix,
      counterText: '',
      counter: helper == null ? null : Text(helper, style: const TextStyle(fontSize: 10)),
    );
  }
}
