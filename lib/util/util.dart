extension StringExtensions on String {
  bool isNotNullOrEmpty() => !isNullOrEmpty();

  bool isNullOrEmpty() => this == null || isEmpty;
}
