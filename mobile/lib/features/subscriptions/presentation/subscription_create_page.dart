import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class SubscriptionCreatePage extends ConsumerStatefulWidget {
  const SubscriptionCreatePage({super.key});

  @override
  ConsumerState<SubscriptionCreatePage> createState() => _SubscriptionCreatePageState();
}

class _SubscriptionCreatePageState extends ConsumerState<SubscriptionCreatePage> {
  final _name = TextEditingController(text: '每周蔬菜箱');
  String _freq = 'weekly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建订阅')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: '订阅名称')),
            DropdownButton<String>(
              value: _freq,
              items: const [
                DropdownMenuItem(value: 'weekly', child: Text('每周')),
                DropdownMenuItem(value: 'monthly', child: Text('每月')),
              ],
              onChanged: (v) => setState(() => _freq = v ?? 'weekly'),
            ),
            FilledButton(
              onPressed: () async {
                await ref.read(agriRepositoryProvider).createSubscription({
                  'name': _name.text,
                  'frequency': _freq,
                  'items': [{'name': '时令蔬菜组合', 'qty': 1}],
                });
                if (context.mounted) context.pop();
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
