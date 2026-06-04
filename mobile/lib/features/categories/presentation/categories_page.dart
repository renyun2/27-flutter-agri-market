import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/agri_repository.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(_catsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('分类')),
      body: cats.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final c = items[i];
            return ListTile(
              title: Text(c.name),
              subtitle: c.coldChain ? const Text('含冷链商品') : null,
              onTap: () => context.push('/products?categoryId=${c.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _catsProvider = FutureProvider<List<Category>>(
  (ref) => ref.read(agriRepositoryProvider).categories(),
);
