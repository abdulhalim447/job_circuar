import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Scaffold(
          appBar: AppBar(title: Text('Settings'), titleSpacing: 0),
          body: Column(
            children: [
              SwitchListTile(
                title: Text('Dark Mode'),
                activeThumbColor: Colors.green,
                value: settingsProvider.isDarkMode,
                onChanged: (bool v) {
                  settingsProvider.setDarkMode(v);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
