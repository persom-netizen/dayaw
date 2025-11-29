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

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

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
              // Navigate back to main/login page, clearing all routes
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FontProvider>(
        builder: (context, fontProvider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: fontProvider.titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mga Kagustuhan',
                        style: TextStyle(
                          fontSize: fontProvider.descriptionSize,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Account Section
                _buildSectionHeader('Account', fontProvider),
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Username',
                  subtitle: widget.username,
                  fontProvider: fontProvider,
                ),

                const Divider(),

                // Mga Nais (Preferences) Section - Font Size
                _buildSectionHeader('Mga Nais', fontProvider),
                _buildFontSizePreference(fontProvider),

                const Divider(),

                // Preferences Section
                _buildSectionHeader('Mga Kagustuhan', fontProvider),
                SwitchListTile(
                  secondary: Icon(Icons.notifications_outlined, color: Colors.blue[600]),
                  title: Text(
                    'Mga Notification',
                    style: TextStyle(fontSize: fontProvider.descriptionSize),
                  ),
                  subtitle: Text(
                    'Tumanggap ng mga abiso',
                    style: TextStyle(fontSize: fontProvider.header4Size),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                SwitchListTile(
                  secondary: Icon(Icons.dark_mode_outlined, color: Colors.blue[600]),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: fontProvider.descriptionSize),
                  ),
                  subtitle: Text(
                    'Gamitin ang madilim na tema',
                    style: TextStyle(fontSize: fontProvider.header4Size),
                  ),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() => _darkModeEnabled = value);
                  },
                ),

                const Divider(),

                // About Section
                _buildSectionHeader('Tungkol sa App', fontProvider),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0',
                  fontProvider: fontProvider,
                ),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Mga Tuntunin ng Serbisyo',
                  fontProvider: fontProvider,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mga Tuntunin ng Serbisyo - Coming Soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Patakaran sa Privacy',
                  fontProvider: fontProvider,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Patakaran sa Privacy - Coming Soon')),
                    );
                  },
                ),

                const Divider(),

                // Logout Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Lumabas',
                        style: TextStyle(fontSize: fontProvider.descriptionSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSectionHeader(String title, FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontProvider.header4Size,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
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
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(
        title,
        style: TextStyle(fontSize: fontProvider.descriptionSize),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(fontSize: fontProvider.header4Size),
            )
          : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  /// Build the font size preference section with slider and preview
  Widget _buildFontSizePreference(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Font size header
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.text_fields, color: Colors.blue[600]),
            title: Text(
              'Laki ng Titik',
              style: TextStyle(fontSize: fontProvider.descriptionSize),
            ),
            subtitle: Text(
              'Ayusin ang laki ng mga titik para sa mas madaling pagbasa',
              style: TextStyle(fontSize: fontProvider.header4Size),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Font size slider
          _FontSizeSlider(fontProvider: fontProvider),
          
          const SizedBox(height: 16),
          
          // Font size preview
          _FontSizePreview(fontProvider: fontProvider),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Font Size Slider Widget
class _FontSizeSlider extends StatelessWidget {
  final FontProvider fontProvider;

  const _FontSizeSlider({required this.fontProvider});

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
          // Level labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: FontSizeLevel.values.map((level) {
              final isSelected = fontProvider.level == level;
              return Column(
                children: [
                  Text(
                    '${level.value}',
                    style: TextStyle(
                      fontSize: isSelected ? 16 : 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue[600] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLevelIcon(level),
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 16,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue[600],
              inactiveTrackColor: Colors.grey[300],
              thumbColor: Colors.blue[600],
              overlayColor: Colors.blue.withAlpha(32),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: fontProvider.level.value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) {
                fontProvider.setFontLevelByValue(value.round());
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Current level label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fontProvider.level.label,
              style: TextStyle(
                fontSize: fontProvider.header4Size,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
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
        return 'A';
      case FontSizeLevel.level2:
        return 'A';
      case FontSizeLevel.level3:
        return 'A';
      case FontSizeLevel.level4:
        return 'A';
      case FontSizeLevel.level5:
        return 'A';
    }
  }
}

/// Font Size Preview Widget
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
          // Preview header
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
          
          // Title preview (Group A)
          _buildPreviewRow(
            label: 'Pamagat',
            sampleText: 'Maligayang Pagdating sa Dayaw',
            fontSize: fontProvider.titleSize,
            fontWeight: FontWeight.bold,
            fontProvider: fontProvider,
          ),
          
          const SizedBox(height: 12),
          
          // Header1 preview (Group B)
          _buildPreviewRow(
            label: 'Header',
            sampleText: 'Matuto ng Baybayin',
            fontSize: fontProvider.header1Size,
            fontWeight: FontWeight.bold,
            fontProvider: fontProvider,
          ),
          
          const SizedBox(height: 12),
          
          // Description preview (Group C)
          _buildPreviewRow(
            label: 'Nilalaman',
            sampleText: 'Ito ay isang halimbawa ng regular na teksto na makikita mo sa aplikasyon.',
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.normal,
            fontProvider: fontProvider,
          ),
          
          const SizedBox(height: 12),
          
          // Header4 preview (Group D)
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
        // Label with size indicator
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontProvider.header4Size,
                color: Colors.blue[600],
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
        // Sample text
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
