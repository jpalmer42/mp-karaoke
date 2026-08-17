import 'package:flutter/material.dart';

abstract class ExState<T extends StatefulWidget> extends State<T> {
  late Function(String value, {String? prefix, String? suffix}) translate;

  @override
  void initState() {
    try {
      translate = _translate;
    } catch (_) {}
    super.initState();
  }

  String _translate(String value, {String? prefix, String? suffix}) {
    return value;
  }
}

// ignore: must_be_immutable
abstract class ExStatelessWidget extends StatelessWidget {
  late Function(String value, {String? prefix, String? suffix}) translate;

  ExStatelessWidget({super.key}) {
    translate = _translate;
  }

  String _translate(String value, {String? prefix, String? suffix}) {
    return value;
  }
}
