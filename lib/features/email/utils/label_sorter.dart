class LabelSorter {
  static void sortLabels(List<String> labels) {
    labels.sort((a, b) {
      final isANumber = RegExp(r'^\d').hasMatch(a);
      final isBNumber = RegExp(r'^\d').hasMatch(b);

      if (isANumber && !isBNumber) return -1;
      if (!isANumber && isBNumber) return 1;
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
  }
}
