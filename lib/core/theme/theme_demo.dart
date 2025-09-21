import 'package:flutter/material.dart';
import 'style.dart';
import 'app_theme.dart';

/// Demo widget to showcase light and dark theme variations
/// Perfect for testing and development
class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(isDark);
    
    return MaterialApp(
      title: 'MoneyBuddy Theme Demo',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppStyle.getBackground(isDark),
        appBar: AppBar(
          title: const Text('Theme Demo'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDark = !isDark;
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppStyle.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyle.getBorder(isDark)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppStyle.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${isDark ? 'Dark' : 'Light'} Theme Active',
                      style: AppStyle.getHeadingSmall(isDark),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Typography showcase
              Text(
                'Typography Showcase',
                style: AppStyle.getHeadingMedium(isDark),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppStyle.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyle.getBorder(isDark)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heading Large', style: AppStyle.getHeadingLarge(isDark)),
                    const SizedBox(height: 8),
                    Text('Heading Medium', style: AppStyle.getHeadingMedium(isDark)),
                    const SizedBox(height: 8),
                    Text('Heading Small', style: AppStyle.getHeadingSmall(isDark)),
                    const SizedBox(height: 8),
                    Text('Body Large - The quick brown fox jumps over the lazy dog', 
                         style: AppStyle.getBodyLarge(isDark)),
                    const SizedBox(height: 8),
                    Text('Body Medium - The quick brown fox jumps over the lazy dog', 
                         style: AppStyle.getBodyMedium(isDark)),
                    const SizedBox(height: 8),
                    Text('Body Small - The quick brown fox jumps over the lazy dog', 
                         style: AppStyle.getBodySmall(isDark)),
                    const SizedBox(height: 8),
                    Text('Caption - Supporting text and labels', 
                         style: AppStyle.getCaption(isDark)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Color palette showcase
              Text(
                'Color Palette',
                style: AppStyle.getHeadingMedium(isDark),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppStyle.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyle.getBorder(isDark)),
                ),
                child: Column(
                  children: [
                    _buildColorRow('Primary Green', AppStyle.primaryGreen, isDark),
                    _buildColorRow('Green Accent', AppStyle.greenAccent, isDark),
                    _buildColorRow('Success', AppStyle.success, isDark),
                    _buildColorRow('Warning', AppStyle.warning, isDark),
                    _buildColorRow('Error', AppStyle.error, isDark),
                    _buildColorRow('Primary Air', AppStyle.primaryAir100, isDark),
                    _buildColorRow('Primary Light', AppStyle.primaryLight100, isDark),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Button showcase
              Text(
                'Button Styles',
                style: AppStyle.getHeadingMedium(isDark),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppStyle.getCardBackground(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppStyle.getBorder(isDark)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primary Button'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          'Outlined Button',
                          style: TextStyle(color: AppStyle.primaryGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Text Button',
                          style: TextStyle(color: AppStyle.primaryGreen),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Bottom spacing
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              isDark = !isDark;
            });
          },
          backgroundColor: AppStyle.primaryGreen,
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildColorRow(String name, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppStyle.getBorder(isDark),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppStyle.getBodyMedium(isDark)),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: AppStyle.getCaption(isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}