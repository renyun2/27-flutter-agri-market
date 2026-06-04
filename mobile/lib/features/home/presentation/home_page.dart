import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/agri_repository.dart';
import '../../shared/presentation/price_chart.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presales = ref.watch(_presalesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('产地直供'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('价格走势 Mock'),
          PriceTrendChart(prices: [12, 11, 13, 10, 14, 12, 15]),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('溯源查询'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/trace'),
          ),
          ListTile(
            title: const Text('季节性预售'),
            onTap: () => context.push('/presales'),
          ),
          ListTile(
            title: const Text('拼团专区'),
            onTap: () => context.push('/group-buys'),
          ),
          const Divider(),
          const Text('预售推荐'),
          presales.when(
            data: (items) => Column(
              children: items.take(5).map((p) {
                return ListTile(
                  title: Text(p['title'] as String? ?? ''),
                  subtitle: Text('¥${p['full_price']}'),
                  onTap: () => context.push('/presale/${p['id']}'),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }
}

final _presalesProvider = FutureProvider((ref) => ref.read(agriRepositoryProvider).presales());
