import 'dart:ui';

class ChildController {
  VoidCallback? _onTrigger;

  void register(VoidCallback callback) {
    _onTrigger = callback;
  }

  void callAction() {
    _onTrigger?.call();
  }
}
