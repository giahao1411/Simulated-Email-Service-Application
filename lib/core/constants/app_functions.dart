import 'package:flutter/foundation.dart';

class AppFunctions {
  static void debugPrint(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
