import 'package:flutter/material.dart';

class TwoStepManage with ChangeNotifier {
  bool _isTwoStepEnabled = false;

  bool get isTwoStepEnabled => _isTwoStepEnabled;

  void setTwoStepEnabled(bool value) {
    _isTwoStepEnabled = value;
    notifyListeners();
  }

  void toggleTwoStep(bool value) {
    _isTwoStepEnabled = value;
    notifyListeners();
  }
}
