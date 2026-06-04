import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(_cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('购物车')),
      body: cart.when(
        data: (data) {
          final items = data['items'] as List;
          final subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0;
          if (items.isEmpty) return const Center(child: Text('购物车为空'));
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = Map<String, dynamic>.from(items[i] as Map);
                    return ListTile(
                      title: Text(it['name'] as String),
                      subtitle: Text('¥${it['price']} x ${it['qty']}'),
                    );
                  },
                ),
              ),
              ListTile(title: Text('小计 ¥$subtotal')),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => context.push('/checkout'),
                  child: const Text('去结算'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _cartProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).cart());
