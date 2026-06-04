import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(_ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('订单列表')),
      body: orders.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final o = items[i];
            return ListTile(
              title: Text('${o.orderType} · ${o.status}'),
              subtitle: Text('¥${o.totalAmount}'),
              onTap: () => context.push('/order/${o.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _ordersProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).orders());
