import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: const ListTile(title: Text('通知 Mock'), subtitle: Text('尾款提醒、配送提醒')),
    );
  }
}
