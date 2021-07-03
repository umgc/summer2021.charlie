///String extension
extension StringExtensions on String {
  ///isNotNullOrEmpty
  bool isNotNullOrEmpty() => !isNullOrEmpty();

  ///isNullOrEmpty
  bool isNullOrEmpty() => this == null || isEmpty;
}
