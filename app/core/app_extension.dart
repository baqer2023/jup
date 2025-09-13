extension StringExtension on String {
  bool get isNullOrEmpty => (this == null || this == '') ? true : false;

  bool get isNotNullOrEmpty => (this == null || this == '') ? false : true;
}
