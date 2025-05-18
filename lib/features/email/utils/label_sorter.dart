class LabelSorter {
  static void sortLabels(List<String> labels) {
    labels.sort((a, b) {
      bool isANumber = RegExp(r'^\d').hasMatch(a);
      bool isBNumber = RegExp(r'^\d').hasMatch(b);

      if (isANumber && !isBNumber) return -1;
      if (!isANumber && isBNumber) return 1; 
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
  }
}
