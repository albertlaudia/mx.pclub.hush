import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

/// A Bible verse, or a non-scripture prompt.
class Prompt {
  final String id;
  final String ref; // e.g. "Psalm 46:10" or "prompt"
  final String text;
  final String translation; // "ESV", "NIV", etc., or "open" for non-scripture

  const Prompt({
    required this.id,
    required this.ref,
    required this.text,
    required this.translation,
  });

  /// A verse has a reference like "Book Chapter:Verse" (e.g. "Psalm 46:10")
  /// — i.e., it contains a space (book name) and a colon (chapter:verse).
  /// Non-verse prompts (future feature) would have a different format.
  ///
  /// The previous implementation checked `translation != 'open'`, but all
  /// verses in the curated pool use ESV/NIV/KJV, and the check was a
  /// tautology: every entry was always a "verse" because every entry had
  /// a translation. This check is more robust.
  bool get isVerse => ref.contains(':') && ref.contains(' ');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prompt &&
        other.id == id &&
        other.ref == ref &&
        other.text == text &&
        other.translation == translation;
  }

  @override
  int get hashCode => Object.hash(id, ref, text, translation);
}

/// Loads a curated pool of verses, then deterministically picks one
/// for today. The same calendar day always yields the same prompt, so
/// the user can return to a verse they remember.
///
/// Falls back to a hardcoded verse if the asset fails to load — the
/// user never sees a blank screen.
class PromptPicker {
  static const _versesPath = 'assets/verses/verses.json';

  /// Hardcoded fallback if the asset can't be loaded.
  static const _fallback = [
    Prompt(
      id: 'fallback-1',
      ref: 'Psalm 46:10',
      text: 'Be still, and know that I am God.',
      translation: 'ESV',
    ),
  ];

  static List<Prompt>? _cache;

  static Future<List<Prompt>> _all() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString(_versesPath);
      final data = json.decode(raw) as Map<String, dynamic>;
      final list = (data['verses'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((m) => Prompt(
                id: m['id'] as String,
                ref: m['ref'] as String,
                text: m['text'] as String,
                translation: m['translation'] as String,
              ))
          .toList();
      if (list.isEmpty) {
        _cache = List.of(_fallback);
      } else {
        _cache = list;
      }
      return _cache!;
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('PromptPicker: failed to load verses asset, using fallback. $e');
      }
      _cache = List.of(_fallback);
      return _cache!;
    }
  }

  /// The prompt for today, deterministically chosen from the day's date key.
  static Future<Prompt> today() async {
    final verses = await _all();
    final today = DateTime.now();
    // Day-of-year + year hash → index. Same day always yields same verse.
    final dayKey = today.year * 1000 + _dayOfYear(today);
    final idx = dayKey % verses.length;
    return verses[idx];
  }

  /// Test-only: clear the cache.
  @visibleForTesting
  static void resetCache() {
    _cache = null;
  }

  static int _dayOfYear(DateTime d) {
    final start = DateTime(d.year, 1, 1);
    return d.difference(start).inDays + 1;
  }
}
