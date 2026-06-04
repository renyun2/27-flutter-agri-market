import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class SubscriptionsPage extends ConsumerWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(_subsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅箱'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/subscription/create')),
        ],
      ),
      body: subs.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final s = items[i];
            return ListTile(
              title: Text(s['name'] as String? ?? ''),
              subtitle: Text('${s['frequency']} · 下次配送 ${s['next_delivery_at']}'),
              trailing: Text(s['status'] as String? ?? ''),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _subsProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).subscriptions());
