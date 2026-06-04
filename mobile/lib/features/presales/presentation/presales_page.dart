import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class PresalesPage extends ConsumerWidget {
  const PresalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(_presalesListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('预售列表')),
      body: list.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final p = items[i];
            return ListTile(
              title: Text(p['title'] as String? ?? ''),
              subtitle: Text('定金 ${((p['deposit_rate'] as num) * 100).toInt()}% · 到货 ${p['harvest_date']}'),
              trailing: Text('¥${p['full_price']}'),
              onTap: () => context.push('/presale/${p['id']}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _presalesListProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).presales());
