import 'package:flutter/foundation.dart';
import 'package:email_application/features/email/controllers/label_controller.dart';

class LabelState {
  static final LabelState _instance = LabelState._internal();
  factory LabelState() => _instance;
  LabelState._internal();

  final ValueNotifier<List<String>> labelsNotifier =
      ValueNotifier<List<String>>([]);
  final LabelController _labelController = LabelController();

  Future<void> initialize() async {
    final labels = await _labelController.loadLabels();
    labelsNotifier.value = labels;
  }

  void updateLabels(List<String> newLabels) {
    labelsNotifier.value = [...newLabels];
  }

  Future<void> addLabel(String label) async {
    final success = await _labelController.saveLabel(label);
    if (success) {
      labelsNotifier.value = [...labelsNotifier.value, label];
    }
  }

  Future<void> editLabel(String oldLabel, String newLabel) async {
    final success = await _labelController.updateLabel(oldLabel, newLabel);
    if (success) {
      final updatedLabels =
          labelsNotifier.value
              .map((label) => label == oldLabel ? newLabel : label)
              .toList();
      labelsNotifier.value = updatedLabels;
    }
  }

  Future<void> removeLabel(String label) async {
    final success = await _labelController.deleteLabel(label);
    if (success) {
      labelsNotifier.value =
          labelsNotifier.value.where((l) => l != label).toList();
    }
  }

  void dispose() {
    labelsNotifier.dispose();
  }
}
