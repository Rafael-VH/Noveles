class TextStats {
  static int characters(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text.replaceAll(RegExp(r'[.,!?; \n\r]'), '').length;
  }

  static int words(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  static int sentences(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .length;
  }

  static int paragraphs(String? text) {
    if (text == null || text.isEmpty) return 0;
    return text
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .length;
  }
}
