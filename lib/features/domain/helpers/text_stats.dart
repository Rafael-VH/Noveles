class TextStats {
  static int characters(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text.replaceAll(RegExp(r'([.,!?; ])'), '').length;
  }

  static int words(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  static int sentences(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text.split(RegExp(r'[.!?]')).length;
  }

  static int paragraphs(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text.split(RegExp(r'\n\s*\n')).length;
  }
}
