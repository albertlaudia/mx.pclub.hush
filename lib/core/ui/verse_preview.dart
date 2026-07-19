/// Helpers for rendering a verse preview.
///
/// The brand says: home = preview, practice = moment. The home screen
/// shows the reference and a short preview (first 6 words). The
/// practice screen reveals the full verse. Same text, two intents.
String versePreviewText(String text, {int words = 6}) {
  final parts = text.split(' ');
  if (parts.length <= words) {
    return '"$text"';
  }
  return '"${parts.take(words).join(' ')}…"';
}
