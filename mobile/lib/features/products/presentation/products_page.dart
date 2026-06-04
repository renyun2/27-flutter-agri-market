import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/agri_repository.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key, this.categoryId, this.farmId});
  final String? categoryId;
  final String? farmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(_productsProvider((categoryId: categoryId, farmId: farmId)));
    return Scaffold(
      appBar: AppBar(title: const Text('商品列表')),
      body: products.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final p = items[i];
            return ListTile(
              title: Text(p.name),
              subtitle: Text('${p.origin} · ¥${p.price}/${p.unit}'),
              onTap: () => context.push('/product/${p.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _productsProvider = FutureProvider.family<List<Product>, ({String? categoryId, String? farmId})>(
  (ref, q) => ref.read(agriRepositoryProvider).products(
        categoryId: q.categoryId,
        farmId: q.farmId,
      ),
);
