import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';

class FarmPage extends ConsumerWidget {
  const FarmPage({super.key, required this.farmId});
  final String farmId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(_farmProvider(farmId));
    return Scaffold(
      appBar: AppBar(title: const Text('农户店铺')),
      body: farm.when(
        data: (json) {
          final f = Map<String, dynamic>.from(json['farm'] as Map);
          final products = json['products'] as List;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(f['name'] as String, style: Theme.of(context).textTheme.headlineSmall),
              Text(f['origin_region'] as String? ?? ''),
              Text(f['story'] as String? ?? ''),
              if ((f['map_image_url'] as String?)?.isNotEmpty == true)
                Image.network(f['map_image_url'] as String, height: 120, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.map, size: 80)),
              const Divider(),
              ...products.map((p) {
                final m = Map<String, dynamic>.from(p as Map);
                return ListTile(
                  title: Text(m['name'] as String),
                  subtitle: Text('¥${m['price']}'),
                  onTap: () => context.push('/product/${m['id']}'),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

final _farmProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, id) => ref.read(agriRepositoryProvider).farm(id),
);
