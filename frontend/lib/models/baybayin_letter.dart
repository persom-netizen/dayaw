/// Data model for Baybayin letters used in the flipcard system
class BaybayinLetter {
  /// The romanized representation of the letter (e.g., "A", "K")
  final String romanized;

  /// The Baybayin Unicode character representation
  final String baybayin;

  /// The type of letter: 'vowel' (patinig) or 'consonant' (katinig)
  final String type;

  /// Optional description or pronunciation guide
  final String? description;

  const BaybayinLetter({
    required this.romanized,
    required this.baybayin,
    required this.type,
    this.description,
  });
}

/// Collection of all Baybayin letters organized by type
class BaybayinLetterData {
  /// All vowels (Patinig) in Baybayin
  /// Note: E and I share the same Baybayin character (ᜁ)
  /// Note: O and U share the same Baybayin character (ᜂ)
  static const List<BaybayinLetter> vowels = [
    BaybayinLetter(
      romanized: 'A',
      baybayin: 'ᜀ', // U+1700 TAGALOG LETTER A
      type: 'vowel',
      description: 'Patinig A',
    ),
    BaybayinLetter(
      romanized: 'E',
      baybayin: 'ᜁ', // U+1701 TAGALOG LETTER I (also represents E)
      type: 'vowel',
      description: 'Patinig E (pareho ng I)',
    ),
    BaybayinLetter(
      romanized: 'I',
      baybayin: 'ᜁ', // U+1701 TAGALOG LETTER I
      type: 'vowel',
      description: 'Patinig I (pareho ng E)',
    ),
    BaybayinLetter(
      romanized: 'O',
      baybayin: 'ᜂ', // U+1702 TAGALOG LETTER U (also represents O)
      type: 'vowel',
      description: 'Patinig O (pareho ng U)',
    ),
    BaybayinLetter(
      romanized: 'U',
      baybayin: 'ᜂ', // U+1702 TAGALOG LETTER U
      type: 'vowel',
      description: 'Patinig U (pareho ng O)',
    ),
  ];

  /// All consonants (Katinig) in Baybayin
  /// Each consonant has an inherent "A" sound
  static const List<BaybayinLetter> consonants = [
    BaybayinLetter(
      romanized: 'K',
      baybayin: 'ᜃ', // U+1703 TAGALOG LETTER KA
      type: 'consonant',
      description: 'Katinig Ka',
    ),
    BaybayinLetter(
      romanized: 'G',
      baybayin: 'ᜄ', // U+1704 TAGALOG LETTER GA
      type: 'consonant',
      description: 'Katinig Ga',
    ),
    BaybayinLetter(
      romanized: 'H',
      baybayin: 'ᜑ', // U+1711 TAGALOG LETTER HA
      type: 'consonant',
      description: 'Katinig Ha',
    ),
    BaybayinLetter(
      romanized: 'L',
      baybayin: 'ᜎ', // U+170E TAGALOG LETTER LA
      type: 'consonant',
      description: 'Katinig La',
    ),
    BaybayinLetter(
      romanized: 'M',
      baybayin: 'ᜋ', // U+170B TAGALOG LETTER MA
      type: 'consonant',
      description: 'Katinig Ma',
    ),
    BaybayinLetter(
      romanized: 'N',
      baybayin: 'ᜈ', // U+1708 TAGALOG LETTER NA
      type: 'consonant',
      description: 'Katinig Na',
    ),
    BaybayinLetter(
      romanized: 'P',
      baybayin: 'ᜉ', // U+1709 TAGALOG LETTER PA
      type: 'consonant',
      description: 'Katinig Pa',
    ),
    BaybayinLetter(
      romanized: 'S',
      baybayin: 'ᜐ', // U+1710 TAGALOG LETTER SA
      type: 'consonant',
      description: 'Katinig Sa',
    ),
    BaybayinLetter(
      romanized: 'T',
      baybayin: 'ᜆ', // U+1706 TAGALOG LETTER TA
      type: 'consonant',
      description: 'Katinig Ta',
    ),
    BaybayinLetter(
      romanized: 'W',
      baybayin: 'ᜏ', // U+170F TAGALOG LETTER WA
      type: 'consonant',
      description: 'Katinig Wa',
    ),
    BaybayinLetter(
      romanized: 'Y',
      baybayin: 'ᜌ', // U+170C TAGALOG LETTER YA
      type: 'consonant',
      description: 'Katinig Ya',
    ),
  ];

  /// Get all Baybayin letters (vowels + consonants)
  static List<BaybayinLetter> getAllLetters() {
    return [...vowels, ...consonants];
  }

  /// Get total count of all letters
  static int get totalCount => vowels.length + consonants.length;
}
