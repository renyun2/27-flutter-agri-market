import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class GroupBuysPage extends ConsumerWidget {
  const GroupBuysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(_gbListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('拼团列表')),
      body: list.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final g = items[i];
            return ListTile(
              title: Text(g['product_name'] as String? ?? ''),
              subtitle: Text('${g['member_count']}/${g['target_count']} 人 · ${g['status']}'),
              trailing: Text('¥${g['group_price']}'),
              onTap: () => context.push('/group-buy/${g['id']}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _gbListProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).groupBuys());
