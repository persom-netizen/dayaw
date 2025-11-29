/// Font Preference Model
/// Defines font size levels and corresponding pixel sizes for different text types

/// Font size level (1-5)
/// Level 1: Smallest (for younger users)
/// Level 2: Small
/// Level 3: Medium (default)
/// Level 4: Large
/// Level 5: Extra Large (for elderly users)
enum FontSizeLevel {
  level1(1, 'Pinakamaliit'),
  level2(2, 'Maliit'),
  level3(3, 'Katamtaman'),
  level4(4, 'Malaki'),
  level5(5, 'Pinakamakaki');

  final int value;
  final String label;

  const FontSizeLevel(this.value, this.label);

  /// Get FontSizeLevel from int value
  static FontSizeLevel fromValue(int value) {
    return FontSizeLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => FontSizeLevel.level3,
    );
  }
}

/// Font size configuration for a specific level
class FontSizeConfig {
  final double titles;
  final double header1;
  final double description;
  final double header4;

  const FontSizeConfig({
    required this.titles,
    required this.header1,
    required this.description,
    required this.header4,
  });
}

/// Font preference data model
class FontPreference {
  final FontSizeLevel level;
  final FontSizeConfig config;

  const FontPreference({
    required this.level,
    required this.config,
  });

  /// Default font preference (Level 3 - Medium)
  factory FontPreference.defaultPreference() {
    return FontPreference(
      level: FontSizeLevel.level3,
      config: FontPreference.getConfigForLevel(FontSizeLevel.level3),
    );
  }

  /// Get font size configuration for a specific level
  /// Font Size Matrix:
  /// Level 1: Titles: 24px | Header1: 18px | Description: 14px | Header4: 10px
  /// Level 2: Titles: 28px | Header1: 20px | Description: 15px | Header4: 11px
  /// Level 3: Titles: 32px | Header1: 22px | Description: 16px | Header4: 12px
  /// Level 4: Titles: 36px | Header1: 24px | Description: 18px | Header4: 14px
  /// Level 5: Titles: 40px | Header1: 26px | Description: 20px | Header4: 16px
  static FontSizeConfig getConfigForLevel(FontSizeLevel level) {
    switch (level) {
      case FontSizeLevel.level1:
        return const FontSizeConfig(
          titles: 24,
          header1: 18,
          description: 14,
          header4: 10,
        );
      case FontSizeLevel.level2:
        return const FontSizeConfig(
          titles: 28,
          header1: 20,
          description: 15,
          header4: 11,
        );
      case FontSizeLevel.level3:
        return const FontSizeConfig(
          titles: 32,
          header1: 22,
          description: 16,
          header4: 12,
        );
      case FontSizeLevel.level4:
        return const FontSizeConfig(
          titles: 36,
          header1: 24,
          description: 18,
          header4: 14,
        );
      case FontSizeLevel.level5:
        return const FontSizeConfig(
          titles: 40,
          header1: 26,
          description: 20,
          header4: 16,
        );
    }
  }

  /// Create a new FontPreference with a different level
  FontPreference copyWith({FontSizeLevel? level}) {
    final newLevel = level ?? this.level;
    return FontPreference(
      level: newLevel,
      config: FontPreference.getConfigForLevel(newLevel),
    );
  }
}
