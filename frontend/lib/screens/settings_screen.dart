import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../models/font_preference.dart';

/// Settings Page
/// Displays user settings and app preferences
class SettingsScreen extends StatefulWidget {
  final String username;

  const SettingsScreen({super.key, required this.username});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  late AnimationController _animationController;
  
  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lumabas'),
        content: const Text('Sigurado ka bang gusto mong lumabas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lumabas'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeConfirmation(
    FontProvider fontProvider,
    FontSizeLevel newLevel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Baguhin ang Laki ng Font'),
        content: const Text(
          'Sigurado ka bang nais mong palitan ang laki ng font mo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hindi'),
          ),
          ElevatedButton(
            onPressed: () {
              fontProvider.setFontLevel(newLevel);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Laki ng font ay nagbago sa buong sistema'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow,
              foregroundColor: textColor,
            ),
            child: const Text('Oo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Consumer<FontProvider>(
        builder: (context, fontProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, -20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryYellow,
                      boxShadow: [
                        BoxShadow(
                          color: primaryYellow.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Setting',
                          style: TextStyle(
                            fontSize: fontProvider.titleSize,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mga Kagustuhan',
                          style: TextStyle(
                            fontSize: fontProvider.descriptionSize,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  delay: 100,
                  child: _buildSectionHeader('Username', fontProvider),
                ),
                _buildAnimatedSection(
                  delay: 150,
                  child: _buildSettingsTile(
                    icon: Icons.person_outline,
                    title: 'Username',
                    subtitle: widget.username,
                    fontProvider: fontProvider,
                  ),
                ),
                const Divider(),
                _buildAnimatedSection(
                  delay: 200,
                  child: _buildSectionHeader('Mga Nais', fontProvider),
                ),
                _buildAnimatedSection(
                  delay: 250,
                  child: _buildFontSizePreference(fontProvider),
                ),
                const Divider(),
                _buildAnimatedSection(
                  delay: 300,
                  child: _buildSectionHeader('Mga Kagustuhan', fontProvider),
                ),
                _buildAnimatedSection(
                  delay: 350,
                  child: SwitchListTile(
                    secondary: Icon(
                      Icons.notifications_outlined,
                      color: primaryYellow,
                    ),
                    title: Text(
                      'Mga Notification',
                      style: TextStyle(
                        fontSize: fontProvider.descriptionSize,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      'Tumanggap ng mga abiso',
                      style: TextStyle(
                        fontSize: fontProvider.header4Size,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    value: _notificationsEnabled,
                    activeColor: primaryYellow,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),
                ),
                _buildAnimatedSection(
                  delay: 400,
                  child: SwitchListTile(
                    secondary: Icon(
                      Icons.dark_mode_outlined,
                      color: primaryYellow,
                    ),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: fontProvider.descriptionSize,
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      'Gamitin ang madilim na tema',
                      style: TextStyle(
                        fontSize: fontProvider.header4Size,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    value: _darkModeEnabled,
                    activeColor: primaryYellow,
                    onChanged: (value) {
                      setState(() => _darkModeEnabled = value);
                    },
                  ),
                ),
                const Divider(),
                _buildAnimatedSection(
                  delay: 450,
                  child: _buildSectionHeader('Tungkol sa App', fontProvider),
                ),
                _buildAnimatedSection(
                  delay: 500,
                  child: _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                    fontProvider: fontProvider,
                  ),
                ),
                _buildAnimatedSection(
                  delay: 550,
                  child: _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Mga Tuntunin ng Serbisyo',
                    fontProvider: fontProvider,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mga Tuntunin ng Serbisyo - Coming Soon'),
                        ),
                      );
                    },
                  ),
                ),
                _buildAnimatedSection(
                  delay: 600,
                  child: _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Patakaran sa Privacy',
                    fontProvider: fontProvider,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Patakaran sa Privacy - Coming Soon'),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                _buildAnimatedSection(
                  delay: 650,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: Text(
                          'Lumabas',
                          style: TextStyle(
                            fontSize: fontProvider.descriptionSize,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  Widget _buildSectionHeader(String title, FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontProvider.header4Size,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    required FontProvider fontProvider,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryYellow),
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontProvider.descriptionSize,
          color: textColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: fontProvider.header4Size,
                color: textColor.withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: onTap != null ? Icon(Icons.chevron_right, color: textColor) : null,
      onTap: onTap,
    );
  }

  Widget _buildFontSizePreference(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.text_fields, color: primaryYellow),
            title: Text(
              'Laki ng Titik',
              style: TextStyle(
                fontSize: fontProvider.descriptionSize,
                color: textColor,
              ),
            ),
            subtitle: Text(
              'Ayusin ang laki ng mga titik para sa mas madaling pagbasa',
              style: TextStyle(
                fontSize: fontProvider.header4Size,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _FontSizeSlider(
            fontProvider: fontProvider,
            onFontSizeChanged: _showFontSizeConfirmation,
          ),
          const SizedBox(height: 16),
          _FontSizePreview(fontProvider: fontProvider),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final FontProvider fontProvider;
  final Function(FontProvider, FontSizeLevel) onFontSizeChanged;

  const _FontSizeSlider({
    required this.fontProvider,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: FontSizeLevel.values.map((level) {
              final isSelected = fontProvider.level == level;
              return GestureDetector(
                onTap: () {
                  onFontSizeChanged(fontProvider, level);
                },
                child: Column(
                  children: [
                    Text(
                      '${level.value}',
                      style: TextStyle(
                        fontSize: isSelected ? 16 : 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? const Color(0xFFFFDF00) : const Color(0xFF554141).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLevelIcon(level),
                      style: TextStyle(fontSize: isSelected ? 20 : 16),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFFDF00),
              inactiveTrackColor: const Color(0xFF554141).withValues(alpha: 0.2),
              thumbColor: const Color(0xFFFFDF00),
              overlayColor: const Color(0xFFFFDF00).withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: fontProvider.level.value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) {
                final newLevel = FontSizeLevel.values[value.round() - 1];
                onFontSizeChanged(fontProvider, newLevel);
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDF00),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fontProvider.level.label,
              style: TextStyle(
                fontSize: fontProvider.header4Size,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF554141),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelIcon(FontSizeLevel level) {
    switch (level) {
      case FontSizeLevel.level1:
        return 'ᴬ';
      case FontSizeLevel.level2:
        return 'A';
      case FontSizeLevel.level3:
        return 'A';
      case FontSizeLevel.level4:
        return 'A';
      case FontSizeLevel.level5:
        return '𝐀';
    }
  }
}

class _FontSizePreview extends StatelessWidget {
  final FontProvider fontProvider;

  const _FontSizePreview({required this.fontProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Preview ng Laki ng Titik',
                style: TextStyle(
                  fontSize: fontProvider.header4Size,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildPreviewRow(
            label: 'Pamagat',
            sampleText: 'Maligayang Pagdating sa Dayaw',
            fontSize: fontProvider.titleSize,
            fontWeight: FontWeight.bold,
            fontProvider: fontProvider,
          ),
          const SizedBox(height: 12),
          _buildPreviewRow(
            label: 'Header',
            sampleText: 'Matuto ng Baybayin',
            fontSize: fontProvider.header1Size,
            fontWeight: FontWeight.bold,
            fontProvider: fontProvider,
          ),
          const SizedBox(height: 12),
          _buildPreviewRow(
            label: 'Nilalaman',
            sampleText:
                'Ito ay isang halimbawa ng regular na teksto na makikita mo sa aplikasyon.',
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.normal,
            fontProvider: fontProvider,
          ),
          const SizedBox(height: 12),
          _buildPreviewRow(
            label: 'Caption',
            sampleText: 'Maliit na detalye at helper text',
            fontSize: fontProvider.header4Size,
            fontWeight: FontWeight.normal,
            color: Colors.grey[600],
            fontProvider: fontProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({
    required String label,
    required String sampleText,
    required double fontSize,
    required FontWeight fontWeight,
    required FontProvider fontProvider,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontProvider.header4Size,
                color: const Color(0xFFFFDF00),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${fontSize.toInt()}px',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[700],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? Colors.black87,
          ),
          child: Text(sampleText),
        ),
      ],
    );
  }
}
